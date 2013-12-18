  # =========================================================================
  # These variables may be set in the client capfile if their default values
  # are not sufficient.
  # =========================================================================

  _cset :download_drush, false
  _cset :drush_cmd, "drush"

  _cset :runner_group, "www-data"
  _cset :group_writable, false

  after 'deploy:setup', 'drupal:setup'

  after "deploy:create_symlink", "drupal:finalize_update"

  set :shared_children, ['files', 'private']

  set :symlinks, {
    "files" => "sites/default/files",
    "private" => "shared/uploads"
  }

  # This is an optional step that can be defined.
  #after "deploy", "git:push_deploy_tag"

  namespace :drupal do
    task :finalize_update, :roles => :app, :except => { :no_release => true} do
      drupal.apply_settings
      drush.site_offline
      drush.updatedb
      drush.cache_clear
      drush.feature_revert
      drush.site_online
      drush.cache_clear
    end

    task :setup, :except => { :no_release => true } do
      p
      sub_dirs = shared_children.map { |d| File.join(shared_path, d) }
      run "mkdir -p #{sub_dirs.join(' ')}"
      run "chmod 2775 #{sub_dirs.join(' ')}"
    end

    task :apply_settings, :roles => :app, :except => { :no_release => true } do
        target = fetch(:target, :latest)

        directory = case target.to_sym
          when :current then current_path
          when :latest  then latest_release
          else raise ArgumentError, "unknown target #{target.inspect}"
          end

        run("if [ -e #{directory}/sites/default/settings.php.#{stage} ]; then " +
            "cp #{directory}/sites/default/settings.php.#{stage} #{directory}/sites/default/settings.php; fi")
    end
  end

  namespace :drush do

    desc "Set the site offline"
    task :site_offline, :on_error => :continue do
      run "#{drush_cmd} -r #{current_path} vset site_offline 1 -y"
      run "#{drush_cmd} -r #{current_path} vset maintenance_mode 1 -y"
    end

    desc "Backup the database"
    task :backupdb, :on_error => :continue do
      run "#{drush_cmd} -r #{current_path}/#{app_path} bam-backup"
    end

    desc "Run Drupal database migrations if required"
    task :updatedb, :on_error => :continue do
      run "#{drush_cmd} -r #{current_path} updatedb -y"
    end

    desc "Clear the drupal cache"
    task :cache_clear, :on_error => :continue do
      run "#{drush_cmd} -r #{current_path} cache-clear all"
    end

    desc "Revert feature"
    task :feature_revert, :on_error => :continue do
      run "#{drush_cmd} -r #{current_path} features-revert-all -y"
    end

    desc "Set the site online"
    task :site_online, :on_error => :continue do
      run "#{drush_cmd} -r #{current_path} vset site_offline 0 -y"
      run "#{drush_cmd} -r #{current_path} vset maintenance_mode 0 -y"
    end

  end

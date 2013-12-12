  # =========================================================================
  # These variables may be set in the client capfile if their default values
  # are not sufficient.
  # =========================================================================

  #_cset :download_drush, false
  #_cset(:drush_cmd) { download_drush ? "#{shared_path}/drush/drush" : "drush" }

  _cset :runner_group, "www-data"
  _cset :group_writable, false


  #after 'deploy:update_code', 'django:setup'

  #before 'django:setup', 'drupal:apply_settings'

  #before 'deploy:migrate', 'drupal:migrate'

  after "deploy:finalize_update", "drupal:finalize_update"

  # This is an optional step that can be defined.
  #after "deploy", "git:push_deploy_tag"
  
  namespace :drupal do
    task :finalize_update, :roles => :app, :except => { :no_release => true} do
      drupal.symlink_shared
      #drush.site_offline
      #drush.updatedb
      #drush.cache_clear
      #drush.feature_revert
      #drush.site_online
      #drush.cache_clear
    end
    desc "Symlinks static directories and static files that need to remain between deployments"
    task :symlink_shared, :roles => :app, :except => { :no_release => true } do
      if shared_children
        # Creating symlinks for shared directories
        shared_children.each do |link|
          run "#{try_sudo} mkdir -p #{shared_path}/#{link}"
          run "#{try_sudo} sh -c 'if [ -d #{release_path}/#{link} ] ; then rm -rf #{release_path}/#{link}; fi'"
          run "#{try_sudo} ln -nfs #{shared_path}/#{link} #{release_path}/#{link}"
        end
      end

      if shared_files
        # Creating symlinks for shared files
        shared_files.each do |link|
          link_dir = File.dirname("#{shared_path}/#{link}")
          run "#{try_sudo} mkdir -p #{link_dir}"
          run "#{try_sudo} touch #{shared_path}/#{link}"
          run "#{try_sudo} ln -nfs #{shared_path}/#{link} #{release_path}/#{link}"
        end
      end
    end
  end

  namespace :drush do

    desc "Gets drush and installs it"
    task :get, :roles => :app, :except => { :no_release => true } do
      run "#{try_sudo} cd #{shared_path} && curl -O -s http://ftp.drupal.org/files/projects/drush-7.x-5.8.tar.gz && tar -xf drush-7.x-5.8.tar.gz && rm drush-7.x-5.8.tar.gz"
      run "#{try_sudo} cd #{shared_path} && chmod u+x drush/drush"
    end

    desc "Set the site offline"
    task :site_offline, :on_error => :continue do
      run "#{drush_cmd} -r #{latest_release}/#{app_path} vset site_offline 1 -y"
      run "#{drush_cmd} -r #{latest_release}/#{app_path} vset maintenance_mode 1 -y"
    end

    desc "Backup the database"
    task :backupdb, :on_error => :continue do
      run "#{drush_cmd} -r #{latest_release}/#{app_path} bam-backup"
    end

    desc "Run Drupal database migrations if required"
    task :updatedb, :on_error => :continue do
      run "#{drush_cmd} -r #{latest_release}/#{app_path} updatedb -y"
    end

    desc "Clear the drupal cache"
    task :cache_clear, :on_error => :continue do
      run "#{drush_cmd} -r #{latest_release}/#{app_path} cache-clear all"
    end

    desc "Revert feature"
    task :feature_revert, :on_error => :continue do
      run "#{drush_cmd} -r #{latest_release}/#{app_path} features-revert-all -y"
    end

    desc "Set the site online"
    task :site_online, :on_error => :continue do
      run "#{drush_cmd} -r #{latest_release}/#{app_path} vset site_offline 0 -y"
      run "#{drush_cmd} -r #{latest_release}/#{app_path} vset maintenance_mode 0 -y"
    end

  end

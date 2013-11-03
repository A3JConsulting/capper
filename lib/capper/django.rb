load "capper/python"

after 'deploy:update_code', 'django:setup'

before 'django:setup', 'django:apply_settings'

before 'deploy:migrate', 'django:migrate'

after "deploy:finalize_update", "django:collectstatic"

_cset(:django_settings) { "#{application}.settings" }

namespace :django do
  desc "Generate django configuration and helpers"
  task :setup, :roles => :app, :except => { :no_release => true } do
    upload_template_file("manage.py",
                         File.join(bin_path, "manage.py"),
                         :mode => "0755")
  end

  desc <<-DESC
    Run the syncdb and migratedb task. By default, it runs this in most recently \
    deployed version of the app. However, you can specify a different release \
    via the migrate_target variable, which must be one of :latest (for the \
    default behavior), or :current (for the release indicated by the \
    `current' symlink). Strings will work for those values instead of symbols, \
    too.
  DESC
  task :migrate, :roles => :db, :only => { :primary => true } do
    migrate_target = fetch(:migrate_target, :latest)

    directory = case migrate_target.to_sym
      when :current then current_path
      when :latest  then latest_release
      else raise ArgumentError, "unknown migration target #{migrate_target.inspect}"
      end

    run "cd #{directory} && #{python} manage.py syncdb --migrate --noinput"
  end

  desc <<-DESC
    Run the collectstatic task.
  DESC
  task :collectstatic, :roles => :app, :except => { :no_release => true } do
    target = fetch(:target, :latest)

    directory = case target.to_sym
      when :current then current_path
      when :latest  then latest_release
      else raise ArgumentError, "unknown target #{target.inspect}"
      end

    run "cd #{directory} && #{python} manage.py collectstatic --noinput"
  end

  desc <<-DESC
    Apply the current stage's settings file.
  DESC
  task :apply_settings, :except => { :no_release => true } do
    target = fetch(:target, :latest)

    directory = case target.to_sym
      when :current then current_path
      when :latest  then latest_release
      else raise ArgumentError, "unknown target #{target.inspect}"
      end

    run("if [ -e #{directory}/#{application}/settings.#{stage}.py ]; then " +
        "cp #{directory}/#{application}/settings.#{stage}.py #{directory}/#{application}/settings.py; fi")
  end
end

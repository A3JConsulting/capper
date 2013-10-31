load "capper/python"

after 'deploy:update_code', 'django:setup'

before 'deploy:migrate', 'django:migrate'

after "deploy:finalize_update", "django:collectstatic"

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
    Run the collectstatic task
  DESC
  task :collectstatic, :roles => :app, :except => { :no_release => true } do
    run "cd #{directory} && #{python} manage.py collectstatic --noinput"
  end
end

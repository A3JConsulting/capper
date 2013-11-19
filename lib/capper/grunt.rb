#after 'deploy:update_code', 'grunt:setup'

after "deploy:finalize_update", 'grunt:run_tasks'
before "grunt:run_tasks", "grunt:setup"

_cset(:grunt_tasks, "dist")
_cset(:grunt_path, "assets")
_cset(:grunt_bin, "grunt") # Should maybe be #{bin_path}/grunt
_cset(:npm_bin, "npm") # Should maybe be #{bin_path}/npm

namespace :grunt do
  desc "Generate django configuration and helpers"
  task :setup, :roles => :app, :except => { :no_release => true } do
    grunt_abs_path = File.join(current_release, grunt_path)
    run "cd #{grunt_abs_path} && #{npm_bin} install"
  end

  desc "Run grunt tasks"
  task :run_tasks, :roles => :app, :except => { :no_release => true } do
    grunt_abs_path = File.join(current_release, grunt_path)
    run "cd #{grunt_abs_path} && #{grunt_bin} #{grunt_tasks}"
  end
end

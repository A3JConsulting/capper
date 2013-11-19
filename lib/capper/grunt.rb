after 'deploy:update_code', 'grunt:setup'

#after "deploy:finalize_update", 'grunt:run_tasks'

_cset(:grunt_tasks, "dist")
_cset(:grunt_path, "assets")
_cset(:grunt_bin, "grunt") # Should maybe be #{bin_path}/grunt
_cset(:npm_bin, "npm") # Should maybe be #{bin_path}/npm

namespace :grunt do
  desc "Generate django configuration and helpers"
  task :setup, :roles => :app, :except => { :no_release => true } do
    target = fetch(:target, :latest)

    directory = case target.to_sym
      when :current then current_path
      when :latest  then latest_release
      else raise ArgumentError, "unknown target #{target.inspect}"
      end

    print :directory

    #run "cd #{directory} && #{npm_bin} install"
  end

  #desc "Run grunt tasks"
  #task :run_tasks, :roles => :app, :except => { :no_release => true } do
  #  target = fetch(:target, :latest)

  #  directory = case target.to_sym
  #    when :current then current_path
  #    when :latest  then latest_release
  #    else raise ArgumentError, "unknown target #{target.inspect}"
  #    end

  #  run "cd #{directory} && #{grunt_bin} #{grunt_tasks}"
  #end
end

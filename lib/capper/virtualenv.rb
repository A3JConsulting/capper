load "capper/python"

_cset(:python_requirements_file, "requirements.txt")

set(:python) { "#{bin_path}/python" }

before "deploy:setup", "virtualenv:setup"

after "deploy:finalize_update", "pip:install"

namespace :virtualenv do
  desc "Create virtualenv for Python packages."
  task :setup, :except => {:no_release => true} do
    run("if [ ! -e #{bin_path}/python ]; then " +
        "virtualenv -q --no-site-packages #{deploy_to}; fi")
  end
end

namespace :pip do
  desc "List installed python packages."
  task :list_packages do
    run("#{bin_path}/pip freeze")
  end

  desc "Install required python packages."
  task :install do
    from_release = fetch(:from_release, :latest)

    directory = case from_release.to_sym
      when :current then current_path
      when :latest  then latest_release
      else raise ArgumentError, "unknown release #{target.inspect}"
      end
    run "cd #{directory} && #{bin_path}/pip install -q -r #{python_requirements_file}"
  end
end

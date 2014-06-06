set(:composer) { "composer" }

after "deploy:finalize_update", "composer:install"

namespace :composer do
  desc "Install required php packages."
  task :install do
    from_release = fetch(:from_release, :latest)

    directory = case from_release.to_sym
      when :current then current_path
      when :latest  then latest_release
      else raise ArgumentError, "unknown release #{target.inspect}"
      end
    run "cd #{directory} && composer install"
  end
end

after 'deploy:setup', 'wordpress:fetch_core'
before "deploy:finalize_update", "wordpress:copy_core"
after "deploy:finalize_update", "wordpress:finalize_update"

_cset :wp_tarball_url, "http://sv.wordpress.org/wordpress-3.8.1-sv_SE.tar.gz"

namespace :wordpress do
    task :finalize_update, :roles => :app, :except => { :no_release => true} do
        wordpress.apply_config
    end

    task :fetch_core, :except => { :no_release => true } do
        # Fetch and install wordpress core (if not disabled)
        if :wp_tarball_url
            run "mkdir -p #{shared_path}/wp-core"
            run "wget #{wp_tarball_url} -O #{shared_path}/wp-core/wp.tgz"
            run "cd #{shared_path}/wp-core && tar xzf wp.tgz --strip-components=1"
            run "rm -f #{shared_path}/wp-core/wp.tgz"
        end
    end

    task :apply_config, :roles => :app, :except => { :no_release => true } do
        target = fetch(:target, :latest)

        directory = case target.to_sym
            when :current then current_path
            when :latest  then latest_release
            else raise ArgumentError, "unknown target #{target.inspect}"
        end

        run("if [ -e #{directory}/wp-config.#{stage}.php ]; then " +
            "cp #{directory}/wp-config.#{stage}.php #{directory}/wp-config.php; fi")
    end

    task :copy_core, :roles => :app, :except => { :no_release => true } do
        target = fetch(:target, :latest)

        directory = case target.to_sym
            when :current then current_path
            when :latest  then latest_release
            else raise ArgumentError, "unknown target #{target.inspect}"
        end

        run("if [ -d #{shared_path}/wp-core ]; then " +
            "cp -nR #{shared_path}/wp-core/* #{directory}/ ; fi")
    end
end

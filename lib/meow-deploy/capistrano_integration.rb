require 'capistrano'
require 'capistrano/version'

module MeowDeploy
  class MeowDeployIntegration
    TASKS = [
      'god:start',
      'god:stop',
      'god:restart',
      'god:reload', 
      'bundle:install'
    ]

    def self.load_into(capistrano_config)
      capistrano_config.load do
        before(MeowDeployIntegration::TASKS) do
          _cset(:rbenv) { "/home/#{user}/.rbenv/bin/rbenv" }
          _cset(:god_sites_path) { "/home/#{user}/sites/god" }
          _cset(:god_app_path) { "#{current_path}/config/god.conf" }
          _cset :bundle_flags, "--deployment --quiet --binstubs --shebang ruby-local-exec"

          env = {'PATH' => 
                 "/home/#{user}/.rbenv/shims:/home/#{user}/.rbenv/bin:$PATH" }

          current_env = fetch(:default_environment)

          if exists?(:default_environment) && 
            !!current_env['PATH'] &&
            !current_env['PATH'].include?('rbenv/shims')

            abort "Make sure to set :default_environment to have PATH include rbenv like this: \n#{env.inspect}" 
          end
        end
        
        namespace :god do
          desc "Reload god config"
          task :reload, :roles => :app, :except => {:no_release => true} do
            run "ln -nfs #{god_app_path} #{god_sites_path}/#{application}.conf"
            sudo "#{rbenv} exec god load #{god_sites_path}/#{application}.conf"
          end

          task :restart, :roles => :app, :except => {:no_release => true} do
            sudo "#{rbenv} exec god restart #{application}"
          end

          task :start, :roles => :app do
            sudo "#{rbenv} exec god start #{application}"
          end

          task :stop, :roles => :app do
            sudo "#{rbenv} exec god stop #{application}"
          end
        end

        namespace :secrets do
          desc "Upload env file"
          task :upload, :roles => :app do
            top.upload(".rbenv-vars", "#{shared_path}/.env")
          end

          desc "Symlink env file."
          task :symlink, :roles => :app do
            run "ln -nfs #{shared_path}/.env #{current_path}/.rbenv-vars"
            run "ln -nfs #{shared_path}/.env #{current_path}/.env"
          end
        end

        namespace :tail do
          desc "Tail production log files" 
          task :production, :roles => :app do
            run "tail -f #{shared_path}/log/production.log" do |channel, stream, data|
              trap("INT") { puts 'Interupted'; exit 0; } 
              puts "#{data}" 
              break if stream == :err
            end
          end

          desc "Tail god log files" 
          task :god, :roles => :app do
            run "tail -f #{shared_path}/log/god.log" do |channel, stream, data|
              trap("INT") { puts 'Interupted'; exit 0; } 
              puts "#{data}" 
              break if stream == :err
            end
          end
        end
      end
    end
  end
end

if Capistrano::Configuration.instance
  MeowDeploy::MeowDeployIntegration.load_into(Capistrano::Configuration.instance)
end

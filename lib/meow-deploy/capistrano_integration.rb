require 'capistrano'
require 'capistrano/version'

module MeowDeploy
  class MeowDeployIntegration
    TASKS = [
      'god:start',
      'god:stop',
      'god:restart',
      'god:reload', 
      'bundle:install',
    ]

    def self.load_into(capistrano_config)
      capistrano_config.load do
        before(MeowDeployIntegration::TASKS) do
          _cset(:rbenv) { "/home/#{fetch(:user)}/.rbenv/bin/rbenv" }
          _cset(:god_sites_path) { "/home/#{fetch(:user)}/sites/god" }
          _cset(:god_app_path) { "#{current_path}/config/god.conf" }
          _cset :bundle_flags, "--deployment --quiet --binstubs --shebang ruby-local-exec"
          _cset(:default_environment) { 
            {'PATH' => "/home/#{fetch(:user)}/.rbenv/shims:/home/#{fetch(:user)}/.rbenv/bin:$PATH"} 
          }
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

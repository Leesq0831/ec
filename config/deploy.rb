require 'bundler/capistrano'
require 'rvm/capistrano'
require 'capistrano/sidekiq'

set :rvm_ruby_string, '2.1.5' # Change to your ruby version
set :rvm_type, :user # :user if RVM installed in $HOME

set :repository, 'git@github.com:Leesq0831/ec.git'
set :scm, :git
set :user, 'deploy'
# set :admin_runner, 'root'
set :use_sudo, false
# set :group_writable, false
set :port, 22

# deployt_via: remote_cache, chechout, export or copy
set :deploy_via, :remote_cache
set :copy_exclude, %w(.git)
ssh_options[:forward_agent] = true
default_run_options[:pty] = true

set :keep_releases, 3

task :production do
  role :app, *%w[59.110.137.84]
  role :db, '59.110.137.84', primary: true

  config_deploy

  # role :whenever, 'wx.91heba.com'
  # set :whenever_roles, 'whenever'
  # deploy_whenever
end

task :staging do
  role :app, *%w[59.110.137.84]
  role :db, '59.110.137.84', primary: true

  config_deploy rails_env: 'staging'

  # role :whenever, 'wx.91heba.com'
  # set :whenever_roles, 'whenever'
  # deploy_whenever
end


after 'deploy:restart', 'deploy:cleanup'
after "deploy:update", 'deploy:migrate'
after 'deploy:finalize_update', 'deploy:custom_symlinks'

namespace :deploy do

  task :start, roles: :app, except: { no_release: true } do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} BUNDLE_GEMFILE=#{deploy_to}/current/Gemfile bundle exec unicorn_rails -c #{unicorn_config} -D"
  end

  task :stop, roles: :app, except: { no_release: true } do
    run "if [ -f #{unicorn_pid} ]; then kill -QUIT `cat #{unicorn_pid}`; fi"
  end

  task :restart, roles: :app, except: { no_release: true } do
    # 用USR2信号来实现无缝部署重启，每隔10秒挨个重启Rails Server
    find_servers.each do |server|
      run "if [ -f #{unicorn_pid} ]; then kill -s USR2 `cat #{unicorn_pid}`; fi", hosts: server.host
      sleep 10
    end
  end

  task :custom_symlinks, roles: :app do
    if %w[ec].include?(application)
      assets_suffix = %w[ec].include?(application) ? 'ec' : application
      run "ln -nfs /opt/apps/shared/ec/assets/#{assets_suffix} #{release_path}/public/assets"
    end

    run "ln -nfs /opt/apps/shared/ec/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs /opt/apps/shared/ec/uploads #{release_path}/public/uploads"
    run "ln -nfs /opt/apps/shared/ec/logs #{release_path}/public/logs"

    run "ln -nfs #{shared_path}/sockets #{release_path}/tmp/sockets"
    run "ln -nfs /opt/apps/shared/ec/config/unicorn.rb #{release_path}/config/unicorn.rb"
  end

end

desc 'Precompile assets locally and then rsync to app servers'
task :precompile do
  if %w[ec].include?(application)
    assets_suffix = application
    tmp_assets_dir = "__assets_#{assets_suffix}"
    shared_assets_dir = "/opt/apps/shared/ec/assets/#{assets_suffix}/"

    run_locally "mkdir -p public/#{tmp_assets_dir}; mv public/#{tmp_assets_dir} public/assets;"
    run_locally 'bundle exec rake assets:clean_expired; RAILS_ENV=production bundle exec rake assets:precompile;'

    run "mkdir -p #{shared_assets_dir}"
    run_locally %Q(rsync -avz -e "ssh -p #{port}" ./public/assets/ deploy@#{find_servers.first}:#{shared_assets_dir};)
    # run_locally %Q(rsync -avz ./public/assets/ deploy@#{find_servers.first}:#{shared_assets_dir};)
    run_locally "mv public/assets public/#{tmp_assets_dir}"
  else
    puts '****** Nothing'
  end
end

def config_deploy(application: 'ec', rails_env: 'production', branch: 'master', use_unicorn: true, releases: 3)
  set :keep_releases, releases
  set :application, application
  set :deploy_to, "/opt/apps/#{application}"
  set :rails_env, rails_env
  set :deploy_env, rails_env
  set :branch, branch

  if use_unicorn
    set :unicorn_config, "#{current_path}/config/unicorn.rb"
    set :unicorn_pid, -> { "#{current_path}/tmp/pids/unicorn.pid" }
  end
end

def deploy_whenever
  set :whenever_command, 'bundle exec whenever'
  set :whenever_environment, defer { deploy_env }
  set :whenever_identifier, defer { "#{application}_#{deploy_env}" }
  require 'whenever/capistrano'
end

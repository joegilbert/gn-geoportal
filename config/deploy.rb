set :application, "geoportal"
set :repository,  "git://github.com/joegilbert/gn-geoportal.git"
set :domain, ""

set :deploy_to, "/usr/local/projects/#{application}"
set :user, ''
set :runner, user
set :run_method, :run

set :scm, :git
set :branch, "master"
set :deploy_via, :remote_cache
set :copy_exclude, [".git", '.gitignore', 'README.rdoc', 'spec/*', "doc/*", "test/*"]

role :web, domain  # Your HTTP server, Apache/etc
role :app, domain  # This may be the same as your `Web` server
role :db,  domain  # This is where Rails migrations will run

default_run_options[:pty] = true
set :ssh_options, {:forward_agent => true}

set :keep_releases, 3 

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

after 'deploy', 'deploy:cleanup'

require 'capistrano-deploy'
use_recipes :git, :rails, :bundle, :unicorn, :multistage

set :repository, 'git@gitlab.tsdv.net:redmine.git'

stage :production do
  server 'tsdv.net', :web, :app, :db, :primary => true
  set :user, 'redmine'
  set :deploy_to, '/home/redmine/production'
  set :branch, 'master'
end

stage :staging do
  server 'tsdv.net', :web, :app, :db, :primary => true
  set :user, 'redmine-staging'
  set :deploy_to, '/home/redmine-staging/staging'
  set :branch, 'staging-4.0'
end

# after 'deploy:migrate', 'deploy:migrate_plugins'
#after 'deploy:update',  'bundle:install'
after 'deploy:restart', 'unicorn:stop'

# namespace :deploy do
#   desc 'Run plugin migrations'
#   task :migrate_plugins do
#     rake = fetch(:rake, 'rake')
#     rails_env = fetch(:rails_env, 'production')
#     run 'cd #{deploy_to} && rbenv shell 2.5.1 && bundle exec rake redmine:plugins:migrate RAILS_ENV=production'
#   end
# end

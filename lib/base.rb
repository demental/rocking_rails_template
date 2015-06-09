gem 'simple_form'
gem 'slim-rails'
# gem 'refile'

gem_group :development, :test do
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'launchy'
end

gem_group :development do
  gem 'html2slim'
end

gem_group :test do
  gem 'database_cleaner'
  gem 'capybara'
end

environment nil, env: 'development' do <<-CFG
  config.generators do |g|
    g.view_specs false
    g.helper_specs false
  end
CFG
end

run 'bundle'

generate 'rspec:install'
generate 'simple_form:install --bootstrap'

generate :controller, 'home index'
run 'rm app/assets/stylesheets/home.scss'
run 'rm app/assets/javascripts/home.coffee'
run 'rm app/helpers/home_helper.rb'

route 'root to: "home#index"'

git :init
git add: "."
git commit: "-a -m 'Base install with rspec and simple_form'"

rakefile 'erb2slim.rake' do <<-'RUBY'
require File.expand_path(File.dirname(__FILE__) + "/../../config/environment")
namespace :convert do
  namespace :erb_to do
    ERBS = FileList["#{Rails.root}/app/views/**/*.erb"]
    #generate tasks for slim files
    slims = []
    ERBS.each do |erb|
      slim = erb.sub(/\.erb$/, ".slim")
      slims << slim
      file slim => [erb] do |task|
        puts "conventing #{erb} .."
        File.open erb, 'r' do |f|
          content = HTML2Slim.convert! f, :erb
          IO.write slim, content
        end
        puts "convented to #{slim} ."

        File.delete(erb)
        puts "deleted #{erb} ."
      end
    end
    desc "convert erb templates to slim [delete=true to delete source erb files]"
    task :slim => slims
  end
end
RUBY
end

rake 'convert:erb_to:slim'

git add: "."
git commit: "-a -m 'slimify views'"

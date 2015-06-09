file '.bowerrc' do <<-JSON
{
  "directory": "vendor/assets/components",
  "interactive": false
}
JSON
end

file 'bower.json' do <<-JSON
{
  "name": "#{app_name}",
  "version": "0.0.0",
  "authors": [
    "arnaud sellenet <arnodmental@gmail.com>"
  ],
  "description": "#{app_name.humanize.capitalize}",
  "moduleType": [
    "globals"
  ],
  "keywords": [
    "rails"
  ],
  "license": "MIT",
  "homepage": "",
  "ignore": [
    "**/.*",
    "node_modules",
    "bower_components",
    "test",
    "tests"
  ],
  "devDependencies": {
  },
  "dependencies": {
  }
}
JSON
end

run 'bower install jquery-ujs --save'
run 'bower install bootstrap-sass --save'
run 'bower install components-font-awesome --save'

application <<-RUBY
Proc.new { |path| path =~ /font-awesome\\/fonts/ and File.extname(path).in?(['.otf', '.eot', '.svg', '.ttf', '.woff']) }
RUBY


run 'echo "vendor/assets/components" >> .gitignore'

remove_gem 'jquery-rails'
remove_gem 'jquery_ujs'

run 'bundle'
run 'rm app/assets/javascripts/application.js'
file 'app/assets/javascripts/application.js' do <<-COFFEE
//= require jquery
//= require jquery-ujs
//= require bootstrap-sass/assets/javascripts/bootstrap-sprockets
COFFEE
end

run 'rm app/assets/stylesheets/application.css'

file 'app/assets/stylesheets/application.scss' do <<-COFFEE
 /*
 *= require_self
 *= require components-font-awesome
 */

$icon-font-path: "bootstrap-sass/assets/fonts/bootstrap/";
@import "bootstrap-sass/assets/stylesheets/bootstrap-sprockets";
@import "bootstrap-sass/assets/stylesheets/bootstrap";

main {
  @extend .container;
  background-color: #fff;
  padding-bottom: 80px;
  width: 100%;
  margin-top: 51px; // accommodate the navbar
}
COFFEE
end

run 'rm app/views/layouts/application.html.slim'
file 'app/views/layouts/application.html.slim' do <<-SLIM
doctype html
html
  head
    meta[name="viewport" content="width=device-width, initial-scale=1.0"]
    title
      = content_for?(:title) ? yield(:title) : 'App'
    meta name="description" content="\#{content_for?(:description) ? yield(:description) : 'Jobrm2'}"
    = stylesheet_link_tag    'application', media: 'all', 'data-turbolinks-track' => true
    = javascript_include_tag 'application', 'data-turbolinks-track' => true
    = csrf_meta_tags
  body data-action="\#{controller.action_name}" data-view="\#{controller.controller_name}"
    header
      nav.navbar.navbar-inverse.navbar-fixed-top
        .container
          .navbar-header
            button.navbar-toggle[type="button" data-toggle="collapse" data-target=".navbar-collapse"]
              span.sr-only Toggle navigation
              span.icon-bar
              span.icon-bar
              span.icon-bar
            = link_to 'Home', root_path, class: 'navbar-brand'
          = render 'layouts/user_nav'
    main.container[role="main"]
      - flash.each do |name, msg|
        - if msg.is_a?(String)
          div class="alert alert-\#{name == :notice ? "success" : "danger"}"
            button.close[type="button" data-dismiss="alert" aria-hidden="true"] ×
            = content_tag :div, msg, :id => "flash_\#{name}"
      == yield
SLIM
end

if recipes.include? 'devise'
  file 'app/views/layouts/_user_nav.html.slim' do <<-SLIM
    .collapse.navbar-collapse
      ul.nav.navbar-nav
        - if current_user
          li= link_to t(".sign_out", :default => "Sign out"), destroy_session_path(:user), method: :delete

        - else
          li= link_to t(".sign_in", :default => "Sign in"), new_session_path(:user)
          li= link_to t(".sign_up", :default => "Sign up"), new_registration_path(:user)
  SLIM
  end
else
  file 'app/views/layouts/_user_nav.html.slim' do ; end
end

run 'rm config/initializers/assets.rb'

initializer 'assets.rb' do <<-RUBY
Rails.application.config.assets.version = '1.0'

Rails.application.root.join('vendor/assets/components').to_s.tap do |bower_path|
Rails.application.config.sass.load_paths << bower_path
Rails.application.config.assets.paths << bower_path
end
# Precompile Bootstrap fonts
Rails.application.config.assets.precompile << %r(bootstrap-sass/assets/fonts/bootstrap/[\\w-]+\\.(?:eot|svg|ttf|woff2?)$)
Rails.application.config.assets.precompile << %r(components-font-awesome/fonts/[\\w-]+\\.(?:eot|svg|ttf|woff)$)
# Minimum Sass number precision required by bootstrap-sass
::Sass::Script::Value::Number.precision = [8, ::Sass::Script::Value::Number.precision].max

RUBY
end


git add: "."
git commit: "-a -m 'install bootstrap with bower'"

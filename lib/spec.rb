
file 'spec/support/factory_girl.rb' do <<-'RUBY'
RSpec.configure do |config|
  config.before(:suite) do
    FactoryGirl.lint
  end
  config.include FactoryGirl::Syntax::Methods
end
RUBY
end

file 'spec/features/features_helper.rb' do <<-'RUBY'
require 'rails_helper'
require 'capybara/rails'
require 'capybara/rspec'

Dir[Rails.root.join('spec/features/support/**/*.rb')].each { |f| require f }
RUBY
end

file 'spec/support/database_cleaner.rb' do <<-'RUBY'
RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.clean_with :truncation
    DatabaseCleaner.strategy = :transaction
  end
  config.before(:each) do
    DatabaseCleaner.start
  end
  config.after(:each) do
    DatabaseCleaner.clean
  end
end
RUBY
end

run 'mkdir spec/acceptance/page'
run 'touch spec/acceptance/page/.keep'

gsub_file 'spec/rails_helper.rb',
  "# Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }",
  "Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }"

inject_into_file 'spec/spec_helper.rb', after: "RSpec.configure do |config|\n" do <<-RUBY
    config.disable_monkey_patching!
  RUBY
end

git add: "."
git commit: "-a -m 'add spec support files'"

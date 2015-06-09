gem 'devise'

run 'bundle'

generate 'devise:install'
generate :devise, 'user'

git add: "."
git commit: " -m 'install devise'"

inject_into_file 'spec/factories/users.rb', after: "factory :user do\n" do <<-'RUBY'
    email { generate :email }
    password 'sup3rsecr3t'
    password_confirmation 'sup3rsecr3t'
RUBY
end

file 'spec/factories/sequences.rb', <<-'RUBY'
FactoryGirl.define do
    sequence(:email) { |n| "mail#{n}@example.wtf" }
end
RUBY

file 'spec/support/devise.rb' do <<-'RUBY'
RSpec.configure do |config|
  config.include Devise::TestHelpers, type: :controller
end
RUBY
end

file 'spec/features/support/authentication.rb' do <<-'RUBY'
RSpec.configure do |config|
  config.include Warden::Test::Helpers, type: :feature
  config.before :suite do
    Warden.test_mode!
  end
end
RUBY
end

git add: "."
git commit: " -m 'devise testing helpers'"

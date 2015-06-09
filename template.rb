def remove_gem gem_name
  gsub_file 'Gemfile',
  /(gem ?('|")#{gem_name}?('|").*$)/, ''
end

def recipes
  %w{git base spec bower_bs}
end

recipes.each do |section|
  file = "#{File.dirname(__FILE__)}/lib/#{section}.rb"
  instance_eval(File.read(file))
end

rake 'db:migrate db:test:prepare'

git add: "."
git commit: "-a -m 'generate schema'"

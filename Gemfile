source 'http://rubygems.org'

branch = ENV.fetch('SPREE_BRANCH', '3-2-stable')
gem "spree", github: "spree/spree", branch: branch
gem "avatax"
gem "codeclimate-test-reporter", group: :test, require: nil

if branch == 'master' || branch >= "3-2-stable"
  gem "rails-controller-testing", group: :test
end

gem 'pry', group: [:test, :development]

gemspec

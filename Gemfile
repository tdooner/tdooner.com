source 'https://rubygems.org'
ruby '2.3.0'

gem "middleman"
# no released version supports middleman 4.x yet:
gem 'middleman-deploy', '>= 2.0.0.pre.alpha'
gem 'middleman-blog'
gem 'middleman-syntax'
gem 'middleman-sprockets', '~> 4.0.0.rc'
gem 'middleman-compass', '>= 4.0.0'
gem 'therubyracer'
gem 'haml'
gem 'compass'
gem 'susy'
gem 'compass-h5bp'
gem 'font-awesome-middleman'
gem 'nokogiri'
gem 'builder'
gem 'github_api'
gem 'wkhtmltopdf'

# Windows does not come with time zone data
gem "tzinfo-data", platforms: [:mswin, :mingw]

group :development do
  # Live-reloading plugin
  gem "middleman-livereload", "~> 3.1.0"

  # For faster file watcher updates on Windows:
  gem "wdm", "~> 0.1.0", :platforms => [:mswin, :mingw]

  gem 'pry'
end

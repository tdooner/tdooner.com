Time.zone = 'Pacific Time (US & Canada)'

require 'susy'
require 'builder'

# Change Compass configuration
# compass_config do |config|
#   config.output_style = :compact
# end

###
# Page options, layouts, aliases and proxies
###
page "/sitemap.xml", layout: false
page "/feed.xml", layout: false
page '/CNAME', layout: false
page '/resume.html', layout: 'resume'

# Per-page layout changes:
#
# With no layout
# page "/path/to/file.html", :layout => false
#
# With alternative layout
# page "/path/to/file.html", :layout => :otherlayout
#
# A path which all have the same layout
# with_layout :admin do
#   page "/admin/*"
# end

# Proxy pages (http://middlemanapp.com/basics/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", :locals => {
#  :which_fake_page => "Rendering a fake page with a local variable" }

###
# Helpers
###

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

# Reload the browser automatically whenever files change
# configure :development do
#   activate :livereload
# end

helpers do
  # Override link_to so that remote links open in new tabs.
  # Conveniently, Kramdown is patched to use this link_to as well.
  def link_to(*args, &block)
    url = block_given? ? args[0] : args[1]
    options = block_given? ? args[1] : args[2]

    if url.start_with?('http')
      options.merge!(target: '_blank')
    end

    super
  end
end

set :base_url, 'https://www.tomdooner.com'

set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'
set :fonts_dir, 'fonts'

set :haml, ugly: true

activate :syntax do |syntax|
  syntax.css_class = 'highlighted-code'
end

# Build-specific configuration
configure :build do
  # For example, change the Compass output style for deployment
  activate :minify_css

  # Minify Javascript on build
  activate :minify_javascript

  # Enable cache buster
  activate :asset_hash

  # Use relative URLs
  activate :relative_assets
  # Or use a different image path
  # set :http_prefix, "/Content/images/"
end

activate :deploy do |deploy|
  deploy.deploy_method = :git
  deploy.remote = "https://#{ENV['GITHUB_AUTH_TOKEN']}@github.com/tdooner/tdooner.com.git"
end

activate :blog do |blog|
  blog.layout = 'layout'
end

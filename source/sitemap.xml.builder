# encoding: utf-8
xml.instruct!

# Remember to exchange www.your-domain.com for your domain (line 64)
# and to set an apropriate update frequency for your site (line 84)

xml.urlset "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9" do
  page_count = 0
  sitemap.resources.each do |page|
    catch :next_page do

      # If all you want the sitemap to cover is normal html pages, use this:
      # throw :next_page unless page.url.end_with?('.html')
      #
      # If you need more detailed control, this is a starting point:
      throw :next_page if page.url.start_with?('/images/')
      throw :next_page if page.url.start_with?('/javascripts/')
      throw :next_page if page.url.start_with?('/stylesheets/')
      throw :next_page if page.url.start_with?('/fonts/')
      throw :next_page if page.url.start_with?('/layouts/')
      throw :next_page if page.url.start_with?('/apple-touch-icon')
      throw :next_page if page.url.end_with?('.xml')
      throw :next_page if page.url.start_with?('/.')   # .htaccess, .DS_Store, .git etc.
      throw :next_page if page.url == '/robots.txt'
      throw :next_page if page.url == '/favicon.ico'
      throw :next_page if page.url == '/humans.txt'
      throw :next_page if page.url == '/CNAME'

      # Exclude drafts
      throw :next_page if defined?(page.data) && page.data['published'] == false
      throw :next_page if defined?(page.data) && page.data['date'] && page.data['date'].to_time > Time.now
      throw :next_page if defined?(page.data) && page.data['externalurl']

      # Count pages
      page_count += 1
      raise "Over 50 000 pages, to much for a single sitemap" if page_count > 50000

      # Build xml of sitemap
      xml.url do
        xml.loc URI.join(config.base_url, page.url)

        # As usual, it's hard to get any solid information on how the search engines are
        # using the information in the site map. lastmod (last modified) and changefreq
        # (change frequency) seams to overlap each other. My guess is that it's best to
        # use lastmod for pages where you know when the file changed, and changefreq for
        # dynamic pages, like the first page of a blog and archive pages, where it's
        # hard to know when the dynamic information was changed.
        #
        # Possible values for changefreq
        # always
        # hourly
        # daily
        # weekly
        # monthly
        # yearly
        # never

        case page.url
          when '/index.html'
            xml.changefreq 'weekly'    # Set this to a suitable value for your site
          else
            if defined?(page.data) && page.data['date']
              frontmatter_date = page.data['date'].to_time.getlocal
              xml.lastmod frontmatter_date.strftime("%Y-%m-%d")
            end
        end

        # Priority (priority)
        #
        # To adjust the priority of a page, set sitemap_priority: in the frontmatter.
        frontmatter_sitemap_priority = page.data['sitemap_priority'].to_f if (defined?(page.data) && page.data['sitemap_priority'])
        if frontmatter_sitemap_priority && frontmatter_sitemap_priority < 0 && frontmatter_sitemap_priority > 1
          raise "Incorrect sitemap_priority #{sitemap_priority} for #{page.destination_path}"
        end
        if frontmatter_sitemap_priority && frontmatter_sitemap_priority >= 0 && frontmatter_sitemap_priority <= 1
          xml.priority frontmatter_sitemap_priority unless frontmatter_sitemap_priority == 0.5 # (No use setting the default priority)
        end

      end
    end
  end
end

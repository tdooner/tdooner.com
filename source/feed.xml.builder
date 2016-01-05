xml.instruct!
# List of fields here:
# http://atomenabled.org/developers/syndication/
xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do
  xml.id URI.join(config.base_url, blog.options.prefix.to_s)
  xml.title "Tom's Blog"
  xml.link "href" => URI.join(config.base_url, blog.options.prefix.to_s)
  xml.link "href" => URI.join(config.base_url, current_page.path), "rel" => "self"
  xml.updated(blog.articles.first.date.to_time.iso8601) unless blog.articles.empty?
  xml.author { xml.name "Tom Dooner" }

  blog.articles[0..50].each do |article|
    xml.entry do
      xml.id URI.join(config.base_url, article.url)
      xml.title article.title
      # If I ever update a post, I'll need to add a new type of metadata that
      # reflects that.
      xml.updated article.date.to_time.iso8601

      xml.link "rel" => "alternate", "href" => URI.join(config.base_url, article.url)
      xml.author { xml.name "Tom Dooner" }
      xml.summary article.summary, "type" => "html"
      xml.content article.body, "type" => "html"
    end
  end
end

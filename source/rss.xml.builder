xml.instruct!
xml.rss 'version' => '2.0' do
  xml.channel do
    xml.title "Tom's Blog"
    xml.link config.base_url
    xml.description "Hello, I'm Tom Dooner and this is my blog."
    xml.language 'en-us'
    xml.lastBuildDate(blog.articles.first.date.to_time.iso8601) unless blog.articles.empty?
    xml.ttl '240'

    blog.articles.first(10).each do |article|
      xml.item do
        xml.title article.title
        xml.link URI.join(config.base_url, article.url)
        xml.author 'tomdooner@gmail.com'
        xml.pubDate article.date.to_time.iso8601
        xml.category article.data.category
        xml.description article.body
      end
    end
  end
end

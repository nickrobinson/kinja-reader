require 'csv'
require 'json'
require 'kinja'
require 'nokogiri'
require 'open-uri'
require 'uri'

doc = Nokogiri::XML(open('http://gizmodo.com/sitemap_bydate.xml?startTime=2014-06-26T00:00:00&endTime=2016-07-02T23:59:59'))

urls = doc.xpath("//xmlns:urlset/xmlns:url/xmlns:loc")

#Remove first element as it points to gizmodo home
urls.shift

#Setup Kinja Client
client = Kinja.new(
  user: ENV["KINJA_USERNAME"],
  password: ENV["KINJA_PASSWORD"]
)
urls.each do |url|
  article_id = url.content[/\d+$/]
  post = client.get_post(article_id)
  post =  JSON.parse(post.body)
  entry = [URI.decode(post['data']['headline']),  post['data']['shortExcerpt']]

  CSV.open("output.csv", "a+") do |csv|
      csv << entry
  end
end

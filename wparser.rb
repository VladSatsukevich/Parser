require "open-uri"
require "nokogiri"
require "byebug"
require "httparty"
require "csv"
require "curb"
 

puts 'Enter url from www.petsonic.com: '
main_page = gets.chomp

puts 'Enter name for your csv file: '
file_name = gets.chomp


def main_page_parser (main_page)
    main_url = Curl.get(main_page)
    unparsed_page = HTTParty.get(main_page)
    parsed_page = Nokogiri::HTML(unparsed_page.body)
    puts 'Scraping main page...'
    url_list = []
    parsed_page.xpath('.//a[@class="product-name"]/@href').each do |url|
    url_list << url
    end
end


def csv_file (url_list, file_name)
    CSV.open(file_name + ".csv", "wb") do |csv|
        csv << ["Name", "Price", "Image"]
        url_list.each do |item_url|
            opening_url = Curl.get(item_url)
            page = Nokogiri::HTML(opening_url.body)

        puts 'Collecting data from inputed url...'
            
        name  = page.xpath('//h1[@class="product_main_name"]').text
        image = page.xpath('//img')[4].attributes.values[1].text
        price = page.xpath('//span[@class="radio_label"]')

        price.each do |attributes|
            quantity = 0
            weight = attributes.xpath('//span[@class="radio_label"]/text()')
            weight.each do |at|
                cost =  attributes.xpath('//span[@class="price_comb"]/text()')


        headerList = ["#{name} - #{weight[quantity]}" , cost[quantity], image]
        csv << headerList

        quantity += 1

                end
            end
        end
    end
end

url_list = main_page_parser(main_page)
csv_file(url_list, file_name)

puts 'Your data is already scraped, you can check your file!!!'



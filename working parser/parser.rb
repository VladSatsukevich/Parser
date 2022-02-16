require "open-uri"
require 'curb'
require 'nokogiri'
require 'csv'
require "byebug"
require_relative 'csv_file'
require_relative 'page_parsing'

def initialization
  puts "Please enter the file's name:"
  filesname = gets.chomp
  puts "Please enter url from www.petsonic.com:"
  main_page = gets.chomp
  puts "Preparing to scrapping!!!"
  csv_create(filesname)
  main_parse(filesname, main_page)
end

def main_page_parser(main_page)
  unparsed_page = Curl.get(main_page)
  parsed_page = Nokogiri::HTML(unparsed_page.body_str)
  puts "Scrapping #{main_page}..."
  return parsed_page
end

def product_parsing(filesname, url)
  parsed_page = main_page_parser(url + '.html')
  name  = parsed_page.xpath('//h1[@class="product_main_name"]').text
  image = parsed_page.xpath('//img')[4].attributes.values[1].text
  price = parsed_page.xpath('//span[@class="radio_label"]')
  price.map do |attributes|
    quantity = 0
    weight = attributes.xpath('//span[@class="radio_label"]/text()')
    weight.each do |at|
      cost = attributes.xpath('//span[@class="price_comb"]/text()')
    csv_add(filesname, "#{name} - #{weight[quantity]} ", cost[quantity], image)
    quantity += 1
    end
  end
end

initialization
puts "Scrapping was finished!"
require 'curb'
require 'nokogiri'
require 'csv'

def initialization
  puts "Please enter the file's name:"
  file_name = gets.chomp
  puts "Please enter url from www.petsonic.com:"
  main_page = gets.chomp
  puts "Preparing to scrapping!!!"
  csv_create(file_name)
  main_parse(file_name, main_page)
end

def download_method(main_page)
  page = Curl.get(main_page)
  download_page = Nokogiri::HTML(page.body_str)
  puts "Scrapping #{main_page}..."
  return download_page
end

def product_parsing(file_name, url)
  download_page = download_method(url + '.html')
  name  = download_page.xpath('//h1[@class = "product_main_name"]/text()')
  image = download_page.xpath('//img[@class = "replace-2x img-responsive"]/@src')
  variations = download_page.xpath('//div[contains(@class, "attribute_list")]/ul/li')
  variations.each do |variation|
    price = variation.xpath('.//span[@class = "price_comb"]/text()')
    weigth = variation.xpath('.//span[@class = "radio_label"]/text()')
    csv_add(file_name, "#{name} - #{weigth}", price, image)
  end
end

def csv_add (file_name, name, price, image)
  CSV.open(file_name + ".csv", 'a') do |csv|
    csv << [name, price, image]
  end
end
  
def csv_create (file_name)
  CSV.open(file_name + ".csv", 'w') do |csv|
    csv << ["Name", "Price", "Image"]
    puts "File #{file_name} was created!"
  end
end

def main_parse(file_name, category)
  number_of_products = download_method(category).xpath('//input[@id="nb_item_bottom"]/@value').text.to_i
  number_of_pages = (number_of_products / 25.0).ceil
  page_parsing(file_name, category)
  (2..number_of_pages).each do |page_number|
    result = category + "?p=#{page_number}"
    page_parsing(file_name, result)
  end
end

def page_parsing(file_name, main_page)
  download_page = download_method(main_page)
  link = download_page.xpath("//*[@class = 'product_img_link pro_img_hover_scale product-list-category-img']/@href")
  link_list = link.to_s.split(/.html/)
  puts "Start parsing products page:"
  link_list.each { |url_link| product_parsing(file_name, url_link)}
end

initialization
puts "Scrapping was finished!"

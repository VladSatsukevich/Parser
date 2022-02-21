require 'curb'
require 'nokogiri'
require 'csv'

def initialization
  puts "Please enter the file's name:"
  file_name = gets.chomp
  puts "Please enter url from www.petsonic.com:"
  inputted_page = gets.chomp
  puts "Preparing to scrapping!!!"
  csv_create(file_name)
  parse_category(file_name, inputted_page)
end

def get_page(inputted_page)
  page = Curl.get(inputted_page)
  downloaded_page = Nokogiri::HTML(page.body_str)
  puts "Scrapping #{inputted_page}..."
  return downloaded_page
end

def product_parsing(file_name, url)
  downloaded_page = get_page(url + '.html')
  name  = downloaded_page.xpath('//h1[@class = "product_main_name"]/text()')
  image = downloaded_page.xpath('//img[@class = "replace-2x img-responsive"]/@src')
  variations = downloaded_page.xpath('//div[contains(@class, "attribute_list")]/ul/li')
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

def parse_category(file_name, category)
  number_of_products = get_page(category).xpath('//input[@id="nb_item_bottom"]/@value').text.to_i
  number_of_pages = (number_of_products / 25.0).ceil
  page_parsing(file_name, category)
  (2..number_of_pages).each do |page_number|
    result = category + "?p=#{page_number}"
    page_parsing(file_name, result)
  end
end

def page_parsing(file_name, inputted_page)
  downloaded_page = get_page(inputted_page)
  parse_product_url = downloaded_page.xpath("//*[@class = 'product_img_link pro_img_hover_scale product-list-category-img']/@href")
  parse_url_list = parse_product_url.to_s.split(/.html/)
  puts "Start parsing products page:"
  parse_url_list.each { |url_link| product_parsing(file_name, url_link)}
end

initialization
puts "Scrapping was finished!"

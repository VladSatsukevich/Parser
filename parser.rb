require 'curb'
require 'nokogiri'
require 'csv'

def initialization
  puts "Please enter the file's name:"
  filesname = gets.chomp
  puts "Please enter url from www.petsonic.com:"
  main_page = gets.chomp
  puts "Preparing to scrapping!!!"
  csv_create(filesname)
  main_parse(filesname, main_page)
end

def download_method(main_page)
  unparsed_page = Curl.get(main_page)
  download_page = Nokogiri::HTML(unparsed_page.body_str)
  puts "Scrapping #{main_page}..."
  return download_page
end

def product_parsing(filesname, url)
  download_page = download_method(url + '.html')
  name  = download_page.xpath('//h1[@class = "product_main_name"]/text()')
  image = download_page.xpath('//img[@class = "replace-2x img-responsive"]//@src')
  price = download_page.xpath('//ul[@class = "attribute_radio_list pundaline-variations"]')
  @weigths = price.xpath('.//li/label/span[@class="price_comb"]/text()')
  @all_values = price.xpath('.//li/label/span[@class = "radio_label"]/text()')
  @all_values.zip(@weigths).map do |second_price, weigth|  
    csv_add(filesname, "#{name} - #{second_price}", weigth, image)
  end
end

def csv_add (filesname, name, price, image)
  CSV.open(filesname + ".csv", 'a') do |csv|
    csv << [name, price, image]
  end
end
  
def csv_create (filesname)
  CSV.open(filesname + ".csv", 'w') do |csv|
    csv << ["Name", "Price", "Image"]
    puts "File #{filesname} was created!"
  end
end

def main_parse(filesname, category)
  number_of_products = download_method(category).xpath('//input[@id="nb_item_bottom"]/@value').text.to_i
  number_of_pages = (number_of_products / 25.0).ceil
  page_parsing(filesname, category)
  (2..number_of_pages).each do |page_number|
    result = category + "?p=#{page_number}"
    page_parsing(filesname, result)
  end
end

def page_parsing(filesname, main_page)
  download_page = download_method(main_page)
  link = download_page.xpath("//*[@class = 'product_img_link pro_img_hover_scale product-list-category-img']/@href")
  link_list = link.to_s.split(/.html/)
  puts "Start parsing products page:"
  link_list.each { |url_link| product_parsing(filesname, url_link)}
end

initialization
puts "Scrapping was finished!"
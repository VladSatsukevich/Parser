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
  @weigths = price.xpath('//span[@class="price_comb"]/text()')
  @all_values = price.xpath('//span[@class="radio_label"]/text()')
  @method = @all_values.zip(@weigths).map do |second_price, weigth|  
  csv_add(filesname, "#{name} - #{second_price} ", weigth, image)
  end
end

def csv_add (filesname, name, price, image)
  products = Array.new
  products.push name: name, price: price, image: image
  CSV.open(filesname + ".csv", 'a', write_headers: false, headers: products.first.keys) do |csv|
    products.each do |product|
      csv << product.values
    end
  end
end
  
def csv_create (filesname)
  products = Array.new
  products.push name: "Name", price: "Price", image: "Image"
  CSV.open(filesname + ".csv", 'w', write_headers: false, headers: products.first.keys) do |csv|
    products.each do |product|
      csv << product.values
      puts "File #{filesname} was created!"
    end
  end
end

def main_parse(filesname, category)
  number_of_products = main_page_parser(category).xpath('//input[@id="nb_item_bottom"]/@value').text.to_i
  number_of_pages = (number_of_products/25.0).ceil
  page_parsing(filesname, category)
  (2..number_of_pages).each do |page_number|
    res = category + "?p=#{page_number}"
    page_parsing(filesname, res)
  end
end

def page_parsing(filesname, main_page)
  parsed_page = main_page_parser(main_page)
  link = parsed_page.xpath("//*[@class = 'product_img_link pro_img_hover_scale product-list-category-img']/@href")
  link_list = link.to_s.split(/.html/)
  puts "Start parsing products page:"
  link_list.each { |url_link| product_parsing(filesname, url_link)}
end

initialization
puts "Scrapping was finished!"
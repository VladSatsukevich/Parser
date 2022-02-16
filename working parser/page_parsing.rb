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
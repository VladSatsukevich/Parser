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
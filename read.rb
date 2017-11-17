require_relative 'app'

class ApiRead
    require 'open-uri'
    require 'json'

    attr_reader :data

    def initialize(url)
      @data = JSON.parse(open(url).read)
      @data.first
    end

    def seed
      data.each do |record|
        restaurant = Restaurant.create(id_dataset: record['id'], name: record['name'], rating: record['rating'] )
        contact = Contact.create(site: record['contact']['site'], email: record['contact']['email'], phone: record['contact']['phone'], restaurant_id: restaurant['id'])
        address = Address.create(street: record['address']['street'], city: record['address']['city'], state: record['address']['state'], restaurant_id: restaurant['id'])
        location = Location.create(lat: record['address']['location']['lat'], lng: record['address']['location']['lng'], address_id: address['id'])
      end
    end

end

reader = ApiRead.new("http://s3-us-west-2.amazonaws.com/lgoveabucket/data_melp.json")
reader.seed

require 'sinatra'

set :public_folder, File.expand_path('../public', __FILE__)
set :views, settings.root + '/html'

require 'json'
require 'data_mapper'



DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/mydb')

class Restaurant
  include DataMapper::Resource

  property :id, Serial
  property :id_dataset, String
  property :name, String, required: true
  property :rating, Integer

    has 1, :contact, :constraint => :destroy
    has 1, :address, :constraint => :destroy

  def rest_location(location)
    my_location = Restaurant.all.address(state: location)
    restaurant = Restaurant.all(id: my_location)
  end

  def self.top_5
    g = all(:rating.gte => 4, :limit => 5)
    g.each { |x| puts @x }
  end

  def self.search(query)
    h = all(Restaurant.address.state.like => "%#{query}%")
    h = h.each { |x| puts @x }
  end
end

class Contact
  include DataMapper::Resource
  attr_reader :restaurant_id
  attr_reader :email

  property :id, Serial
  property :site, String
  property :email, String
  property :phone, String
  property :restaurant_id, Integer, required: true

  belongs_to :restaurant
end

class Address
  include DataMapper::Resource

  property :id, Serial
  property :street, String
  property :city, String
  property :state, String
  property :restaurant_id, Integer, required: true

  def self.states
    Address.all.pluck(:state).uniq
  end


  belongs_to :restaurant
      has 1, :location, :constraint => :destroy
end

class Location
  include DataMapper::Resource

  property :id, Serial
  property :lat, Float
  property :lng, Float
  property :address_id, Integer, required: true

  belongs_to :address
end

DataMapper.finalize()
DataMapper.auto_upgrade!()

module Enumerable
  def pluck(key)
    map {|obj| obj[key] }
  end
end



get('/') do
  @top5 = Restaurant.top_5

  erb(:index, locals: { restaurants: @top5 })
end


get('/search') do
  @searched = Restaurant.search(params[:query])

  # @searched.search(params[:query])

  erb(:search, locals: { restaurants: @searched })
end

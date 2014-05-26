require 'addressable/uri'
require 'rest-client'
require 'JSON'

location = Addressable::URI.new(
  :scheme => "https",
  :host => "maps.googleapis.com",
  :path => "maps/api/geocode/json",
  :query_values => { :address => "36 Cooper Square", 
                      :sensor => false,
                :key => "AIzaSyDHFATANsi-p7tWhMeiv3s_i8c_daFZFk4"
                }
  ).to_s

geocode_location = RestClient.get(location)

lat_long = JSON.parse(geocode_location)

lat = lat_long["results"][0]["geometry"]["location"]["lat"]
long = lat_long["results"][0]["geometry"]["location"]["lng"]

ice_cream_shop = Addressable::URI.new(
  :scheme => "https",
  :host => "maps.googleapis.com",
  :path => "maps/api/place/nearbysearch/json",
  :query_values => { :location => "#{lat}, #{long}",
                      :rankby => "distance",
                      :sensor => false,
                      :keyword => "Ice Cream Shop",
                      :key => "AIzaSyDHFATANsi-p7tWhMeiv3s_i8c_daFZFk4"    
  }

).to_s

p ice_cream_shop
p RestClient.get(ice_cream_shop)
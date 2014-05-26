require 'addressable/uri'
require 'rest-client'
require 'JSON'
require 'nokogiri'
require 'debugger'
def get_location(location)
  location = Addressable::URI.new(
    :scheme => "https",
    :host => "maps.googleapis.com",
    :path => "maps/api/geocode/json",
    :query_values => { :address => location, 
                        :sensor => false,
                  :key => "AIzaSyDHFATANsi-p7tWhMeiv3s_i8c_daFZFk4"
                  }
    ).to_s
    
  geocode_location = RestClient.get(location)

  lat_long = JSON.parse(geocode_location)

  origin_lat = lat_long["results"][0]["geometry"]["location"]["lat"]
  origin_long = lat_long["results"][0]["geometry"]["location"]["lng"]
  origin = [origin_lat, origin_long]
end

def find_nearby_locations(origin, destination)
  
  ice_cream_shop = Addressable::URI.new(
    :scheme => "https",
    :host => "maps.googleapis.com",
    :path => "maps/api/place/nearbysearch/json",
    :query_values => { :location => "#{origin[0]}, #{origin[1]}",
                        :rankby => "distance",
                        :sensor => false,
                        :keyword => destination,
                        :key => "AIzaSyDHFATANsi-p7tWhMeiv3s_i8c_daFZFk4"    
    }

  ).to_s

  shops = JSON.parse RestClient.get(ice_cream_shop)
  dest_lat = shops["results"].first["geometry"]["location"]["lat"]
  dest_long = shops["results"].first["geometry"]["location"]["lng"]
  
  end_point = [dest_lat, dest_long]
end

def find_directions(user_location, destination)
  directions = Addressable::URI.new(
  scheme: "https",
  host: "maps.googleapis.com",
  path: "maps/api/directions/json",
  query_values:  { origin: "#{user_location[0]}, #{user_location[1]}", 
                   destination: "#{destination[0]}, #{destination[1]}",
                   mode: "walking",
                   sensor: false,
                   key: "AIzaSyDHFATANsi-p7tWhMeiv3s_i8c_daFZFk4" 
                 }
          ).to_s
  path = JSON.parse RestClient.get(directions)

  steps = path["routes"].first["legs"][0]["steps"].map do |step|
    [step["html_instructions"], step["distance"]["text"]]
  end
  
end

def print_path(path)
  path.each do |step|
    print Nokogiri::HTML(step[0]).text
    puts " for #{step[1]}."
  end 
end

def prompt
  puts "Enter your address:"
  user_add = gets.chomp
  user_location = get_location(user_add)
  puts "Intended destination:"
  user_dest = gets.chomp
  destination = find_nearby_locations(user_location, user_dest)
  path = find_directions(user_location, destination)
  
  print_path(path)
end

prompt #whoo



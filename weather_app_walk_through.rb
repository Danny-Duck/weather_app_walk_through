require "json"
require "httparty"
require "geocoder"
require 'time'
require 'date'

system 'clear'

puts "===> Hello, this is how api's work"
puts '===> Make a get request to whatismyip.com which will return your ip address'

pp ip_address = HTTParty.get('http://whatismyip.akamai.com')

puts "===> press enter to continue"
gets

puts "===> Now use the ip address information to get the necessary GPS coordinates to make a get request to the weather api"
puts "===> These are the approximate gps coordinates of your location"

p gps_coordinates = Geocoder.search(ip_address.body).first.coordinates
puts "===> try google this ^\n"

puts "===> press enter to continue"
gets

puts "===> now lets use the gps coordinates to get some weather data"
pp raw_weather_data = HTTParty.get("https://api.darksky.net/forecast/b90bba0f6d3f8c2e3102c9b691f4803d/#{gps_coordinates[0]},#{gps_coordinates[1]}?exclude=alerts,flags,hourly,minutely")

puts "===> what was returned is a json string that contains an array of 10 hash objects, each hash is day and its weather information for the upcoming week"

puts "===> press enter to continue"
gets

# ===> some data handling 
weather_data_as_a_json_object = JSON.parse(raw_weather_data.body)
# parse json string into a ruby object

def some_unit_conversion(weather_data_as_a_json_object)
# convert UNIX time (which is, seconds since midnight GMT on 1 Jan 1970) into human time ;)
  weather_data_as_a_json_object['daily']['data'].each do |day|
  # init loop for each day
    day.each_key do |key|
      # convert all matching keys
      if key.include?('temperature') && !key.include?('Time')
        day[key] = ((day[key].to_i - 32) * (5.0 / 9.0)).round(2).to_i.to_s + '°'
      end
      if key.include?('time')
        day[key] = Time.at(day[key]).strftime('%A, %d/%m')
      end
      if key.include?('Time')
        day[key] = Time.at(day[key]).strftime('%I:%M %p')
      end
    end 
  end
end

pp converted_weather_data = some_unit_conversion(weather_data_as_a_json_object)
# call method on data and save as a variable


puts "===> we can save it to a json file or we can keep it in memory to use only when the program is running"
puts "===> 1. save to file"
puts "===> 2. print todays weather"

input = gets.chomp.to_i

def save_to_file(converted_weather_data)
  File.write('this_weeks_weather_data.json', converted_weather_data.to_json)
  puts "Saved file to current directory :)"
end


def print_todays_weather(converted_weather_data)
  pp todays_weather = converted_weather_data[1]
end

input == 1? save_to_file(converted_weather_data) : print_todays_weather(converted_weather_data)

puts "thanks for tuning in :)"
puts "made by Danny_knows 🦆"
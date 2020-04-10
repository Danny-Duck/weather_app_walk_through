# frozen_string_literal: true

require 'json'
require 'httparty'
require 'geocoder'
require 'time'
require 'date'

system 'clear'

puts '===> Hello, this is how the weather app works'
puts '===> It starts by making a get request to whatismyip.com expecting your ip address in return'

pp ip_address = HTTParty.get('http://whatismyip.akamai.com')

puts '===> press enter to continue'
gets

puts '===> Using your ip address we get the necessary GPS coordinates for the weather api'
p gps_coordinates = Geocoder.search(ip_address.body).first.coordinates
puts '===> Try google this ^'
puts '===> These are the approximate gps coordinates relative to your ip address'


puts '===> press enter to continue'
gets

pp raw_weather_data = HTTParty.get("https://api.darksky.net/forecast/b90bba0f6d3f8c2e3102c9b691f4803d/#{gps_coordinates[0]},#{gps_coordinates[1]}?exclude=alerts,flags,hourly,minutely")

puts '===> What has returned is a json string that contains an array of 10 hash objects, each hash is day and its weather information for the upcoming week'

puts '===> press enter to continue'
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
      day[key] = Time.at(day[key]).strftime('%A, %d/%m') if key.include?('time')
      day[key] = Time.at(day[key]).strftime('%I:%M %p') if key.include?('Time')
    end
  end
end

converted_weather_data = some_unit_conversion(weather_data_as_a_json_object)
# call method on data and save as a variable

puts '===> You can save it to as a json file or keep it in memory to use only when the program is running'
puts '===> 1. save to file'
puts '===> 2. print todays weather'

input = gets.chomp.to_i

def save_to_file(converted_weather_data)
  system 'clear'
  File.write('this_weeks_weather_data.json', converted_weather_data.to_json)
  puts 'Saved file to current directory :)'
end

def print_todays_weather(converted_weather_data)
  system 'clear'
  date = converted_weather_data[1]['time']
  summary = converted_weather_data[1]['summary']
  max_temp = converted_weather_data[1]['temperatureMax']
  min_temp = converted_weather_data[1]['temperatureMin']
  puts "Today is #{date} and we can expect #{summary.downcase} With a high of #{max_temp} and a low of #{min_temp}."
end

input == 1 ? save_to_file(converted_weather_data) : print_todays_weather(converted_weather_data)

puts 'thanks for tuning in :)'
puts 'made by Danny_knows 🦆'

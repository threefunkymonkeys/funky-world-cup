require './app.rb'

ENV["RACK_ENV"] ||= :development

run Cuba

Sequel::DATABASES.each(&:disconnect)

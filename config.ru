require 'bundler'
Bundler.require

require './app'

# set :environment, ENV['RACK_ENV'].to_sym || :development

run App


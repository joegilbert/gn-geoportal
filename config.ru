require 'rubygems'
require 'bundler'

Bundler.require

require './app.rb'
Sinatra::Application.set :run, false
Sinatra::Application.set :environment, :production
run Sinatra::Application

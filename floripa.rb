require 'rubygems'
require 'sinatra'
require 'erubis'

get '/' do
  erb :index
end

post '/' do
  params.inspect
end

require 'rubygems'
require 'bundler'
Bundler.setup
require 'sinatra'
require 'erubis'
require 'active_record'

ActiveRecord::Base.establish_connection(YAML::load(File.open('database.yml')))

Dir["models/*.rb"].each { |f| require f }

get '/' do
  @posts = Post.limit(6).order('created_at desc')
  erb :index
end

post '/' do
  Post.create(:message => params[:input])
  #redirect to('/obrigado')
  # colocar flash message "obrigado por postar"
  redirect to('/')
end

#get '/obrigado' do
  #"Obrigado por postar!"
#end

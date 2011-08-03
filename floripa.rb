require 'rubygems'
require 'bundler'
Bundler.setup
require 'sinatra'
require 'authlogic'
require 'erubis'
require 'active_record'
require 'rack-flash'

ActiveRecord::Base.establish_connection(YAML::load(File.open('database.yml')))

Dir["models/*.rb"].each { |f| require f }

enable :sessions
use Rack::Flash
  
get '/' do
  @posts = Post.limit(6).order('created_at desc')
  erb :index
end

post '/' do
  Post.create(:message => params[:input])
  flash[:success] = 'Sua mensagem foi postada com sucesso!'
  redirect to('/')
end

get '/signup' do
  erb :signup
end

post '/signup' do
  @user = User.new(:username => params[:username], :password => params[:password], :email => params[:email], :password_confirmation => params[:password_confirmation])

  if @user.save
    flash[:success] = 'Seu cadastro foi realizado com sucesso!'
    redirect to('/')
  else
    flash.now[:error] = 'Seu cadastro não foi salvo. Tente novamente'
    erb :signup
  end
end

get '/login' do
  erb :login
end

post '/login' do
  @session = UserSession.new(:username => params[:username], :password => params[:password], :remember_me => false)

  if @session.save
    flash[:success] = "Bem-vindo, #{current_user.username}!"
    redirect to('/')
  else
    flash.now[:error] = "Não foi possível fazer o seu login!"
    erb :login
  end
end

get '/logout' do
  flash[:notice] = 'Você não está mais logado'
  UserSession.find.destroy
  redirect to('/')
end

get '/contact' do
  erb :contact
end

get '/about' do
  erb :about
end

helpers do
  def current_user
    session = UserSession.find
    session.user if session
  end
end
#O helper serve para poder chamar o método na View

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
  @user = User.new(:username => params[:username], :password => params[:password])
  if params[:password] != params[:repeatpassword]
    flash[:error] = 'Suas senhas não são iguais. Tente novamente'
    redirect to '/signup'
  else

    if @user.save
      flash[:success] = 'Seu cadastro foi realizado com sucesso!'
    else
      flash[:error] = 'Seu cadastro não foi salvo. Tente novamente'
    end
  end
  redirect to('/')
end

get '/login' do
  erb :login
end

post '/login' do
  UserSession.create(:login => params[:login], :password => "params[:password]", :remember_me => false)
end

#get '/logout' do
  #redirect to '/'
  #flash[:notice] = 'Você não está mais logado'
  #UserSession = nil
#end


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

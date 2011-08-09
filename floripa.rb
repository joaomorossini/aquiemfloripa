require 'rubygems'
require 'bundler/setup'
Bundler.require :default
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
  @posts = (if params[:tab].nil? || params[:tab] == 'recent' then Post.recent else Post.featured end).paginate(:page => params[:page], :per_page => 6)
  erb :index
end

post '/' do
  Post.create(:message => params[:input], :user_id => (current_user ? current_user.id : nil))
  flash[:success] = 'Sua mensagem foi postada com sucesso!'
  redirect to('/')
end

get '/signup' do
  erb :signup
end

post '/signup' do
  @user = User.new(:name => params[:name], :username => params[:username], :password => params[:password], :email => params[:email], :password_confirmation => params[:password_confirmation])

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

post '/like' do
  p = Post.find(params[:id])
  p.increment(:likes)
  if p.save
    flash[:success] = "Realizado com sucesso"
  else  
    flash[:error] = "Ação não executada. Tente novamente"
  end
  redirect to('/')
end

post '/dislike' do
  p = Post.find(params[:id])
  p.increment(:dislikes)
  if p.save
    flash[:success] = "Realizado com sucesso"
  else  
    flash[:error] = "Ação não executada. Tente novamente"
  end
  redirect to('/')
end

helpers do
  def current_user
    session = UserSession.find
    session.user if session
  end
  def capitalize_all string
    string.split(' ').map {|t| t.capitalize}.join(' ') unless string.nil? || string.chomp == ''
  end
  def paginate(resources)
    params[:page] ||= 1
    if !resources.next_page.nil? and !resources.previous_page.nil?
      html = "<a href='?page=#{params[:page].to_i-1}'> « Prev </a>"
      html += "#{params[:page]} of #{resources.total_pages} "
      html += "<a href='?page=#{params[:page].to_i+1}'> Next » </a>"
    elsif !resources.next_page.nil? and resources.previous_page.nil?
       html = "<a href='?page=#{params[:page].to_i+1}'> Next » </a>"
    elsif resources.next_page.nil? and !resources.previous_page.nil?
      html = "<a href='?page=#{params[:page].to_i-1}'> « Prev </a>" 
      html += "#{params[:page]} of #{resources.total_pages}"
    end
    return html
  end  
end
#O helper serve para poder chamar o método na View

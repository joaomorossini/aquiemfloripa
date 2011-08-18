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

before do
  @cities = City.all 
end  
  
get '/' do
  
# A condição abaixo define que quando params[tab] NÃO for nulo, o elemento ':page' da session é setado para 1
# Explicação: Quando o usuário acessa outra página da mesma tab, 'params[:tab]' passa a ser nulo. 'params[:tab]' só existe quando o usuário clica em uma tab. Portanto, ao mudar de tab, 'params[:tab]' recebe o valor correspondente àquela tab, deixa de ser nulo, o que aciona a ação 'session[:oage] = '1'

  if !params[:city].nil?
    session[:city] = params[:city]
  end

  if !params[:tab].nil?
    session[:page] = '1'
  end
  
  if params[:tab].nil? && session[:tab].nil?
    session[:tab] = 'recent'
  elsif !params[:tab].nil?
    session[:tab] = params[:tab]
  end

  if params[:page].nil? && session[:page].nil?
    session[:page] = '1'
  elsif !params[:page].nil?
    session[:page] = params[:page]
  end

  @posts = ((session[:tab] == 'recent') ? Post.city("#{session[:city]}").recent : Post.city("#{session[:city]}").featured).paginate(:page => session[:page], :per_page => 6)
  erb :index
end

post '/' do
  Post.create(:message => params[:input], :user_id => (current_user ? current_user.id : nil), :city_id => session[:city])
  flash[:success] = 'Sua mensagem foi postada com sucesso!'
  redirect to('/')  
end

get '/search' do

  if !params[:page].nil?
    session[:page] = params[:page]
  end

  @posts = Post.search(params[:search]).paginate(:page => session[:page], :per_page => 6)
  erb :search
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
    session[:page] ||= 1 #Se params[:page] não possuir um valor, atribuir o valor '1'
    if !resources.next_page.nil? and !resources.previous_page.nil?
      html = "<a href='?page=#{session[:page].to_i-1}'> « Prev </a>"
      html += "#{session[:page]} of #{resources.total_pages} "
      html += "<a href='?page=#{session[:page].to_i+1}'> Next » </a>"
    elsif !resources.next_page.nil? and resources.previous_page.nil?
       html = "<a href='?page=#{session[:page].to_i+1}'> Next » </a>"
    elsif resources.next_page.nil? and !resources.previous_page.nil?
      html = "<a href='?page=#{session[:page].to_i-1}'> « Prev </a>" 
      html += "#{session[:page]} of #{resources.total_pages}"
    end
    return html
  end  
end
# Os helpers servem para poder chamar o método na View

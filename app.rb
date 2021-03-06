require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?

require 'sinatra/activerecord'
require './models'

require 'open-uri'
require 'net/http'
require 'json'

require "sinatra/json"
require './image_uploader.rb'

enable :sessions

helpers do
  def current_user
    User.find_by(id: session[:user])
  end
end

get '/' do
  @posts = Post.all
  erb :index
end

get '/signup' do
  erb :signup
end

post '/signup' do
  user = User.create(
    name: params[:name],
    password: params[:password],
    password_confirmation: params[:password_confirmation],
    profile_image: ""
  )

  if params[:profile_image]
    image_upload(params[:profile_image])
  end

  if user.persisted?
    session[:user] = user.id
  end
  redirect '/'
end

get '/signin' do
  erb :signin
end

post '/signin' do
  user = User.find_by(name: params[:name])
  if user && user.authenticate(params[:password])
    session[:user] = user.id
  end
  redirect '/'
end

get '/signout' do
  session[:user] = nil
  redirect '/'
end

get '/new' do
  erb :new
end

post '/new' do
  Post.create(site_name: params[:site_name],site_url: params[:site_url],site_about: params[:site_about],user_id: current_user.id, post_user: current_user.name)
  redirect '/'
end

get '/search' do
  @posts = Post.all
  keyword = params[:keyword]
  @searchs = Post.where(site_about: keyword)
  erb :search
end

post '/edit/:id' do
  post = Post.find(params[:id])
  post.comment = params[:comment]
  post.save
  redirect "post/:id"
end

get '/post/:id' do
  @post = Post.find(params[:id])
  erb :post
end

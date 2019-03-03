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

#おにく

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

post '/signin' do
  user = User.find_by(name: params[:name])
  if user && user.authenticate(params[:password])
    session[:user] = user.id
  end
  redirect '/'
end

get '/search' do
  erb :search
end

post '/search' do
  keyword = params[:keyword]
  uri = URI("https://itunes.apple.com/search")
  uri.query = URI.encode_www_form({ term: keyword, country: "US", media: "music", limit: 10 })
  res = Net::HTTP.get_response(uri)
  returned_json = JSON.parse(res.body)
  @musics = returned_json["results"]
  erb :search
end

post '/new' do
  Post.create(music_image: params[:music_image],artist: params[:artist],album: params[:album],track: params[:track],sample_music: params[:sample_music],comment: params[:comment],user_id: current_user.id,post_user: current_user.name)
  redirect '/home'
end

get '/signout' do
  session[:user] = nil
  redirect '/'
end

get '/home' do
  if current_user.nil?
    @posts = Post.none
  else
    @posts = current_user.posts
  end
  erb :home
end

get '/edit/:id' do
  @post = Post.find(params[:id])
  erb :edit
end

post '/edit/:id' do
  post = Post.find(params[:id])
  post.comment = params[:comment]
  post.save
  redirect "/home"
end

get '/delete/:id' do
  Post.find(params[:id]).delete
  redirect '/home'
end
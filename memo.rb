# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'

enable :method_override

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end

  def hattr(text)
    Rack::Utils.escape_path(text)
  end

  def load_file
    json_file = File.open('memos.json').read
    json_file = '{}' if json_file.empty?
    JSON.parse(json_file)
  end

  def write_file(hash)
    File.open('memos.json', 'w') do |file|
      JSON.dump(hash, file)
    end
  end
end

get '/' do
  @title = 'トップページ'
  @memos = load_file
  erb :top
end

get '/new' do
  @title = '新規作成'
  erb :new
end

post '/create' do
  id = SecureRandom.uuid
  new_memo = { 'title': params[:title].to_s, 'content': params[:content].to_s }
  hash = load_file
  hash[id.to_s] = new_memo
  write_file(hash)
  redirect to('/')
end

get '/edit/:id' do
  @title = 'メモ編集'
  @memo_id = params[:id]
  @memos = load_file
  if @memos.key?(params[:id].to_s)
    @memo = @memos[params[:id].to_s]
    erb :edit
  else
    @error = '存在するIDを指定してください'
    erb :top
  end
end

patch '/edit/:id' do
  @title = params[:title]
  @content = params[:content]
  hash = load_file
  hash[params[:id].to_s]['title'] = params[:title]
  hash[params[:id].to_s]['content'] = params[:content]
  write_file(hash)
  redirect to("/memos/#{params[:id]}")
end

delete '/destroy/:id' do
  hash = load_file
  hash.delete(params[:id].to_s)
  write_file(hash)
  redirect to('/')
end

get '/memos/:id' do
  @title = 'メモ詳細'
  @memos = load_file
  @memo_id = params[:id].to_s
  if @memos.key?(params[:id].to_s)
    @memo = @memos[params[:id].to_s]
    erb :show
  else
    @error = '存在するIDを指定してください'
    erb :top
  end
end

not_found do
  status 404
  'Not Found 404'
end

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
    File.open('public/memos.json') do |file|
      JSON.parse(file.read)
    end
  end

  def write_file(hash)
    File.open('public/memos.json', 'w') do |file|
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
  @memo = @memos[@memo_id.to_s]
  erb :edit
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

delete '/destroy/*' do |id|
  hash = load_file
  hash.delete(id.to_s)
  write_file(hash)
  redirect to('/')
end

get '/memos/*' do |memo_id|
  @title = 'メモ詳細'
  @memos = load_file
  @memo_id = memo_id
  erb :show
end

not_found do
  status 404
  'Not Found 40432'
end

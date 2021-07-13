# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'securerandom'
require 'pg'

enable :method_override

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

conn = PG.connect(dbname: 'sinatra_memo_app')
# CRUD memos class
class Memo
  def self.all(conn)
    conn.exec('SELECT * FROM memos;')
  end

  def self.create(conn, title: params_title, content: params_content)
    id = SecureRandom.uuid
    conn.exec_params('INSERT INTO memos VALUES ($1, $2, $3);', [id, title, content])
  end

  def self.find(conn, id: params_id)
    conn.exec_params('SELECT * FROM memos WHERE id = $1;', [id]) { |result| result[0] }
  end

  def self.edit(conn, id: params_id, title: params_id, content: params_content)
    conn.exec_params('UPDATE memos SET title = $1, content = $2 WHERE id = $3;', [title, content, id])
  end

  def self.destroy(conn, id: params_id)
    conn.exec_params('DELETE FROM memos WHERE id = $1;', [id])
  end

  def self.exist?(conn, id: params_id)
    ids = conn.exec('SELECT * FROM memos;').column_values(0)
    ids.include?(id)
  end
end

get '/' do
  redirect to('/memos')
end

get '/memos' do
  @title = 'トップページ'
  @memos = Memo.all(conn)
  erb :index
end

get '/memos/new' do
  @title = '新規作成'
  erb :new
end

post '/memos' do
  Memo.create(conn, title: params[:title], content: params[:content])
  redirect to('/')
end

get '/memos/:id/edit' do
  @title = 'メモ編集'
  if Memo.exist?(conn, id: params[:id])
    @memo = Memo.find(conn, id: params[:id])
    erb :edit
  else
    status 404
  end
end

patch '/memos/:id' do
  Memo.edit(conn, id: params[:id], title: params[:title], content: params[:content])
  redirect to("/memos/#{params[:id]}")
end

delete '/memos/:id' do
  Memo.destroy(conn, id: params[:id])
  redirect to('/')
end

get '/memos/:id' do
  @title = 'メモ詳細'
  if Memo.exist?(conn, id: params[:id])
    @memo = Memo.find(conn, id: params[:id])
    erb :show
  else
    status 404
  end
end

not_found do
  status 404
  'Not Found 404'
end

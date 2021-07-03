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

  def hattr(text)
    Rack::Utils.escape_path(text)
  end
end

# CRUD memos class
class Memo
  def self.all
    memos_db = []
    conn = PG.connect(dbname: 'sinatra_memo_app')
    conn.exec('SELECT * FROM memos;') do |result|
      result.each do |row|
        memos_db << row
      end
    end
    memos_db
  end

  def self.create(title: params_title, content: params_content)
    id = SecureRandom.uuid
    conn = PG.connect(dbname: 'sinatra_memo_app')
    conn.exec("INSERT INTO memos VALUES ('#{id}', '#{title}', '#{content}');")
  end

  def self.find(id: params_id)
    target_memo = {}
    conn = PG.connect(dbname: 'sinatra_memo_app')
    conn.exec("SELECT * FROM memos WHERE id = '#{id}';") do |result|
      result.each do |row|
        target_memo = row
      end
    end
    target_memo
  end

  def self.edit(id: params_id, title: params_id, content: params_content)
    conn = PG.connect(dbname: 'sinatra_memo_app')
    conn.exec("UPDATE memos SET title = '#{title}', content = '#{content}' WHERE id = '#{id}';")
  end

  def self.destroy(id: params_id)
    conn = PG.connect(dbname: 'sinatra_memo_app')
    conn.exec("DELETE FROM memos WHERE id = '#{id}';")
  end
end

get '/' do
  @title = 'トップページ'
  @memos = Memo.all
  erb :top
end

get '/new' do
  @title = '新規作成'
  erb :new
end

post '/create' do
  Memo.create(title: params[:title].to_s, content: params[:content].to_s)
  redirect to('/')
end

get '/edit/:id' do
  @title = 'メモ編集'
  @memo = Memo.find(id: params[:id])
  status 404 if @memo.empty?
  erb :edit
end

patch '/edit/:id' do
  Memo.edit(id: params[:id].to_s, title: params[:title].to_s, content: params[:content].to_s)
  redirect to("/memos/#{params[:id]}")
end

delete '/destroy/:id' do
  Memo.destroy(id: params[:id].to_s)
  redirect to('/')
end

get '/memos/:id' do
  @title = 'メモ詳細'
  @memo = Memo.find(id: params[:id].to_s)
  status 404 if @memo.empty?
  erb :show
end

not_found do
  status 404
  'Not Found 404'
end

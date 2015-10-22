require 'pry-byebug'
require 'sinatra'
require 'sinatra/contrib/all' if development?
require 'pg'

before do
  @db = PG.connect(dbname: 'todo', host: 'localhost')
end

after do
  @db.close
end

get '/' do
  redirect to('/items')
end

get '/items' do
  # Hint: Here's the line of code you would need to set a local variable 
  #       with a SQL string to get all the items from the DB, but what are
  #       you going to do with it?..
  #
  sql = "SELECT * FROM items"
  @items = run_sql(sql)
  erb :index
end

get '/items/new' do
  erb :new
end

post '/items' do
  item = params['item']
  details  = params['details']

  sql = "INSERT INTO items (item, details) VALUES ('#{item}', '#{details}')"
  run_sql(sql)
  last_item_id = find_last_item
  redirect to("/items/#{last_item_id.to_i}") # or can you get the id of the record created by the insert, and redirect to that?
end

get '/items/:id' do
  sql = "select * from items where id = #{params['id'].to_i}"
  @item = run_sql(sql).first
  erb :show
end

get '/items/:id/edit' do
  sql = "select * from items where id = #{params['id'].to_i}"
  @item = run_sql(sql).first
  erb :edit
end

post '/items/:id' do
  id = params['id']
  item = params['item']
  details  = params['details']

  # sql = "UPDATE items SET item='#{item}', details='#{details} WHERE id=#{id}"
  sql = "UPDATE items SET details='#{details}', item='#{item}' WHERE id=#{id.to_i}"
  run_sql(sql)
  redirect to("/items/#{params[:id]}")
end

post '/items/:id/delete' do
  id = params['id'].to_i
  sql = "delete from items where id = #{id}"
  run_sql(sql)
  redirect to('/')
  ##must be form with only button
end

def run_sql(sql)
  @db.exec(sql)
end

def find_last_item
  sql = "SELECT * FROM items"
  obj = run_sql(sql)
  listarray = []
  # binding.pry;''
  obj.each {|item| listarray << item['id'] }
  return listarray.last
  end

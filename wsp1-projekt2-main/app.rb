require 'sinatra/base'
require 'sqlite3'

class Seeder
  def self.seed!
    drop_users_table
    create_users_table
    populate_users
  end

  private

  def self.db
    @db ||= begin
      db = SQLite3::Database.new('db/users.sqlite')
      db.results_as_hash = true
      db
    end
  end

  def self.drop_users_table
    db.execute('DROP TABLE IF EXISTS users')
  end

  def self.create_users_table
    db.execute(<<~SQL)
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        password TEXT NOT NULL
      )
    SQL
  end

  def self.populate_users
    db.execute('INSERT INTO users (name, password) VALUES (?, ?)', ['Yad', 'Yad12345.'])
    db.execute('INSERT INTO users (name, password) VALUES (?, ?)', ['Päronmannen', 'Jag_älskar_päron'])
    db.execute('INSERT INTO users (name, password) VALUES (?, ?)', ['John Doe', 'Jag_hatar_inget.21'])
  end
end

class App < Sinatra::Base
  before do
    @db ||= SQLite3::Database.new('db/users.sqlite')
    @db.results_as_hash = true
  end

  get '/' do
    redirect('/users')
  end

  get '/users' do
    @users = @db.execute('SELECT * FROM users ORDER BY id')
    erb :'users/index'
  end

  get '/users/new' do
    erb :'users/new'
  end

  post '/users' do
    @db.execute('INSERT INTO users (name, password) VALUES (?, ?)', 
                [params['user_name'], params['user_password']])
    redirect '/users'
  end

  get '/users/:id' do |id|
    @user = @db.execute('SELECT * FROM users WHERE id = ?', id).first
    erb :'users/show'
  end

  get '/users/:id/edit' do |id|
    @user = @db.execute('SELECT * FROM users WHERE id = ?', id).first
    erb :'users/edit'
  end

  post '/users/:id/update' do |id|
    name = params['user_name']
    password = params['user_password']
  
    if name.nil? || name.strip.empty? || password.nil? || password.strip.empty?
      @error = "Name and password cannot be empty."
      @user = @db.execute('SELECT * FROM users WHERE id = ?', id).first
      return erb :'users/edit'
    end
  
    @db.execute('UPDATE users SET name = ?, password = ? WHERE id = ?', [name, password, id])
    redirect '/users'
  end
  

  post '/users/:id/delete' do |id|
    @db.execute('DELETE FROM users WHERE id = ?', id)
    redirect '/users'
  end
end

Seeder.seed!
require 'sqlite3'

class Seeder
  def self.seed!
    drop_tables
    create_tables
    populate_tables
  end

  def self.drop_tables
    db.execute('DROP TABLE IF EXISTS users')
  end

  def self.create_tables
    db.execute(<<~SQL)
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        password TEXT NOT NULL
      )
    SQL
  end

  def self.populate_tables
    db.execute('INSERT INTO users (name, password) VALUES (?, ?)', 
               ['Yad', 'Yad12345.'])
    db.execute('INSERT INTO users (name, password) VALUES (?, ?)', 
               ['Päronmannen', 'Jag_älskar_päron'])
    db.execute('INSERT INTO users (name, password) VALUES (?, ?)', 
               ['John Doe', 'Jag_hatar_inget.21'])
  end

  private

  def self.db
    @db ||= begin
      db = SQLite3::Database.new('db/users.sqlite')
      db.results_as_hash = true
      db
    end
  end
end

Seeder.seed!

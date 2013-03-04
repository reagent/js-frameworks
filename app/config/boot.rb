require 'data_mapper'
require 'json'
require 'bcrypt'

# If you want the logs displayed you have to do this before the call to setup
# DataMapper::Logger.new($stdout, :debug)

# An in-memory Sqlite3 connection:
DataMapper.setup(:default, 'sqlite::memory:')

require 'models'

DataMapper.auto_upgrade!
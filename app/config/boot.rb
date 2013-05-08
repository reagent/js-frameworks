require 'data_mapper'
require 'active_support/json'
require 'bcrypt'

# If you want the logs displayed you have to do this before the call to setup
# DataMapper::Logger.new($stdout, :debug)

# An in-memory Sqlite3 connection:
# DataMapper.setup(:default, 'sqlite::memory:')

# Persistent Sqlite3 connection
root = File.expand_path(File.dirname(__FILE__) + '/..')
DataMapper.setup(:default, "sqlite:///#{root}/db/js-frameworks.sqlite3")

require 'models'

DataMapper.auto_upgrade!
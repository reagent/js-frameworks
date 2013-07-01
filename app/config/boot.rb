require 'data_mapper'
require 'dm-ar-finders'
require 'active_support/json'
require 'active_support/inflector'
require 'bcrypt'

ENV['APP_ENV'] ||= 'development'

# If you want the logs displayed you have to do this before the call to setup
# DataMapper::Logger.new($stdout, :debug)

# An in-memory Sqlite3 connection:
# DataMapper.setup(:default, 'sqlite::memory:')

# Persistent Sqlite3 connection
root = File.expand_path(File.dirname(__FILE__) + '/..')
DataMapper.setup(:default, "sqlite:///#{root}/db/js-frameworks-#{ENV['APP_ENV']}.sqlite3")

require 'lib/polymorphism'
require 'lib/timestamps'

require 'lib/ext/validation_errors'

require 'models'

DataMapper.auto_upgrade!
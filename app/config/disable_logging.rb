# Rack automatically inserts Rack::CommonLogger into the middleware stack,
# this is the only way to turn it off completely and do custom logging:
#   http://gromnitsky.blogspot.com/2012/04/how-to-disable-rack-logging-in-sinatra.html

module Rack
  class CommonLogger
    def call(env)
      # do nothing
      @app.call(env)
    end
  end
end
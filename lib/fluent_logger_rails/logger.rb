require 'active_support'
require 'active_support/core_ext'
require 'fluent-logger'

module FluentLoggerRails

class Logger < ActiveSupport::BufferedLogger

  CONFIGURATION_FILE = "fluent_logger.yml"
  LOG_LEVEL_MAP      = ['DEBUG', 'INFO', 'WARN', 'ERROR', 'FATAL']

  def initialize(options={}, level=DEBUG)
    @level         = level || DEBUG
    @port          = options[:port]
    @host          = options[:host]
    @appname       = options[:appname]

    @fluent_logger = Fluent::Logger::FluentLogger.new(@appname, { :host => @host, :port => @port })
  end

  def add(severity, message=nil, progname=nil, &block)
    message_level = LOG_LEVEL_MAP[severity] || 'UNKNOWN'
    @fluent_logger.post 'stdout', log = { :text => message, :level => message_level }
  end

  def flush; end

  def close
    @fluent_logger.close
  end
end

end

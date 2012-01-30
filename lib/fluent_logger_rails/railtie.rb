require 'fluent_logger_rails'
require 'erb'

class Railtie < Rails::Railtie

  def create_logger(config, options={})
    level  = ActiveSupport::BufferedLogger.const_get(config.log_level.to_s.upcase)
    logger = FluentLoggerRails::Logger.new(options)
    logger.auto_flushing = false if Rails.env.production?
    logger
  rescue StandardError => e
    logger       = ActiveSupport::BufferedLogger.new(STDERR)
    logger.level = ActiveSupport::BufferedLogger::WARN
    logger.warn("Problem initializing Fluent logger for Rails \n " + e.message + "\n" + e.backtrace.join('\n'))
    logger
  end

  initializer :initialize_fluent_logger, :before => :initialize_logger do
    app_config    = Rails.application.config
    config_file   = Rails.root.join("config", FluentLoggerRails::Logger::CONFIGURATION_FILE)
    begin
      if config_file.file?
        fluent_config = YAML.load(ERB.new(config_file.read).result)[Rails.env]
        settings = { :appname => fluent_config['appname'],
                     :host    => fluent_config['fluent_host'],
                     :port    => fluent_config['fluent_port']}
      else
        settings = { :appname => ENV['APPLICATION_NAME'],
                     :host    => ENV['FLUENTD_HOST'],
                     :port    => ENV['FLUENTD_PORT']  }
      end

      Rails.logger  = config.logger = create_logger(app_config, settings)
    rescue Exception => e
      raise RuntimeError, "Could not resolve fluentd configuration for Rails '#{Rails.env}' environment: #{e}"
    end

  end
end

# frozen_string_literal: true

require_relative "litejob/version"
require_relative "litejob/concern"
require_relative "litejob/server"
require "logger"

module Litejob
  def self.included(klass)
    klass.extend(Concern)
  end
  
  Configuration = Struct.new(:logger)
  
  def self.configuration
    @configuration ||= Configuration.new(
      _logger = Logger.new($stdout),
    )
  end
  
  def self.configure
    yield(configuration)
  end
  
  def self.logger
    configuration.logger
  end
end

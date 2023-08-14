# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "simplecov"
SimpleCov.start do
  enable_coverage :branch
end

require "litejob"
require_relative "../lib/litejob/processor"

require "minitest/autorun"

Litejob.configure do |config|
  config.logger = Logger.new(IO::NULL)
end

$jobqueue = Litequeue.instance

# Setup a class to allow us to track and test whether code has been performed
class Performance
  def self.reset!
    @performances = 0
  end

  def self.performed!
    @performances ||= 0
    @performances += 1
  end

  def self.processed!(item, scope: :default)
    @processed_items ||= {}
    @processed_items[scope] ||= []
    @processed_items[scope] << item
  end

  def self.processed_items(scope = :default)
    @processed_items[scope]
  end

  def self.performances
    @performances || 0
  end
end

class NoOpJob
  include Litejob

  def perform = nil
end

class OpJob
  include Litejob

  def perform = Performance.performed!
end

class RetryJob
  include Litejob

  class RetryableError < StandardError; end

  def perform
    if Performance.performances.zero?
      Performance.performed!
      raise RetryableError
    end
  end
end

class AlwaysFailJob
  include Litejob

  class RetryableError < StandardError; end

  def perform
    Performance.performed!
    raise RetryableError
  end
end

def perform_enqueued_jobs(&block)
  yield # enqueue jobs

  # iterate over enqueued jobs and perform them
  until $jobqueue.empty?
    id, serialized_job = $jobqueue.pop
    next if id.nil?
    Litejob::Processor.new("test", id, serialized_job).process!
  end
end

def perform_enqueued_job
  performed = false
  attempts = 0

  # get first enqueued jobs and perform it
  until performed
    attempts += 1
    id, serialized_job = $jobqueue.pop
    next if id.nil?
    Litejob::Processor.new("test", id, serialized_job).process!
    performed = true
  end
end

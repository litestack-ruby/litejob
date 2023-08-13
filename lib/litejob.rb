# frozen_string_literal: true

require_relative "litejob/version"
require_relative "litejob/client"

# Litejob is responsible for providing an interface to job classes
module Litejob
  def self.included(klass)
    klass.extend(ClassMethods)
  end

  module ClassMethods
    def perform_async(*params)
      @litejob_options ||= {}
      client.push(name, params, @litejob_options.merge(delay: 0, queue: queue_name))
    end

    def perform_at(time, *params)
      @litejob_options ||= {}
      delay = time.to_i - Time.now.to_i
      client.push(name, params, @litejob_options.merge(delay: delay, queue: queue_name))
    end

    def perform_in(delay, *params)
      @litejob_options ||= {}
      client.push(name, params, @litejob_options.merge(delay: delay, queue: queue_name))
    end
    alias_method :perform_after, :perform_in

    def delete(id)
      client.delete(id)
    end

    def queue_as(queue_name)
      @queue_name = queue_name.to_s
    end

    def litejob_options(options)
      @litejob_options = options
    end

    private

    def queue_name
      @queue_name || "default"
    end

    def client
      @client ||= Client.new
    end
  end
end

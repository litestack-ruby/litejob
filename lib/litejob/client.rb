# frozen_string_literal: true

require "json"
require "litequeue"

module Litejob
  # Litejob::Client is responsible for pushing job payloads to the SQLite queue.
  class Client
    def initialize
      @queue = Litequeue.instance
    end

    def push(jobclass, params, options = {})
      delay = options[:delay] || 0
      attempts = options[:attempts] || 5
      queue = options[:queue]
      payload = JSON.dump({class: jobclass, params: params, attempts: attempts, queue: queue})
      job_id, job_queue = atomic_push(payload, delay, queue)
      Litejob.logger.info("[litejob]:[ENQ] queue=#{job_queue} class=#{jobclass} job=#{job_id}")
      [job_id, job_queue]
    end

    def delete(id)
      payload = @queue.delete(id)
      Litejob.logger.info("[litejob]:[DEL] job=#{id}")
      JSON.parse(payload)
    end

    private

    def atomic_push(payload, delay, queue)
      retryable = true
      begin
        @queue.push(payload, queue: queue, delay: delay)
      rescue => exception
        # Retry once retryable exceptions
        # https://github.com/sparklemotion/sqlite3-ruby/blob/master/lib/sqlite3/errors.rb
        if retryable && exception.is_a?(SQLite3::BusyException)
          retryable = false
          retry
        else
          raise exception
        end
      end
    end
  end
end

# frozen_string_literal: true

require "json"
require "litequeue"

module Litejob
  # Litejob::Processor is responsible for processing job payloads
  class Processor
    def initialize(queue, id, serialized_job)
      @queue = queue
      @id = id
      @serialized_job = serialized_job
      @job_hash = JSON.parse(@serialized_job)
      @litequeue = Litequeue.instance
      
      set_log_context!(queue: @queue, class: @job_hash["class"], job: @id)
    end

    def repush(id, job, delay = 0, queue = nil)
      @litequeue.repush(id, JSON.dump(job), queue: queue, delay: delay)
    end

    def process!
      log(:deq)
      klass = Object.const_get(@job_hash["class"])
      instance = klass.new

      begin
        instance.perform(*@job_hash["params"])
        log(:end)
      rescue StandardError => e
        if @job_hash["retries_left"] == 0
          err(e, "retries exhausted, moving to _dead queue")
          repush(@id, @job_hash, 0, "_dead")
        else
          @job_hash["retries_left"] ||= @job_hash["attempts"]
          @job_hash["retries_left"] -= 1
          retry_delay = (@job_hash["attempts"] - @job_hash["retries_left"]) * 0.1
          err(e, "retrying in #{retry_delay} seconds")
          repush(@id, @job_hash, retry_delay, @job_hash["queue"])
        end
      end
    rescue StandardError => e
      # this is an error in the extraction of job info, retrying here will not be useful
      err(e, "while processing job=#{@serialized_job}")
      raise e
    end
    
    private
    
    def set_log_context!(**attributes)
      @log_context = attributes.map { |k, v| [k, v].join('=') }.join(' ')
    end
    
    def log(event, msg: nil)
      prefix = "[litejob]:[#{event.to_s.upcase}]"
      
      Litejob.logger.info [prefix, @log_context, msg].compact.join(" ")
    end
    
    def err(exception, msg = nil)
      prefix = "[litejob]:[ERR]"
      error_context = if exception.class.name == exception.message
        "failed with #<#{exception.class.name}>"
      else
        "failed with #{exception.inspect}"
      end
      
      Litejob.logger.error [prefix, @log_context, error_context, msg].compact.join(" ")
    end
  end
end

# frozen_string_literal: true

require "json"
require "litequeue"

module Litejob
  # Litejob::Processor is responsible for processing job payloads
  class Processor
    def initialize(payload)
      @payload = payload
      @queue = Litequeue.instance
    end

    def repush(id, job, delay = 0, queue = nil)
      @queue.repush(id, JSON.dump(job), queue: queue, delay: delay)
    end

    def process!
      id, serialized_job = @payload
      job_hash = JSON.parse(serialized_job)
      klass = Object.const_get(job_hash["class"])
      instance = klass.new

      begin
        instance.perform(*job_hash["params"])
      rescue
        if job_hash["retries_left"] == 0
          repush(id, job_hash, 0, "_dead")
        else
          job_hash["retries_left"] ||= job_hash["attempts"]
          job_hash["retries_left"] -= 1
          retry_delay = (job_hash["attempts"] - job_hash["retries_left"]) * 0.1
          repush(id, job_hash, retry_delay, job_hash["queue"])
        end
      end
    rescue => exception # standard:disable Lint/UselessRescue
      # this is an error in the extraction of job info, retrying here will not be useful
      raise exception
    end
  end
end

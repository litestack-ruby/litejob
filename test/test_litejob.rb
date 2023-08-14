# frozen_string_literal: true

require "test_helper"

describe Litejob do
  after do
    $jobqueue.clear
    Performance.reset!
    NoOpJob.instance_variable_set :@queue_name, nil
  end

  describe ".perform_async" do
    it "returns job_id and queue" do
      job_id, queue = NoOpJob.perform_async

      assert job_id
      assert_equal "default", queue
    end

    it "successfully pushes job to the queue" do
      assert_equal 0, $jobqueue.count(queue: "default")

      _job_id, queue = NoOpJob.perform_async

      assert_equal "default", queue
      assert_equal 1, $jobqueue.count(queue: "default")
    end

    it "successfully runs the job" do
      assert_equal 0, $jobqueue.count(queue: "default")

      perform_enqueued_jobs do
        _job_id, queue = OpJob.perform_async

        assert_equal "default", queue
        assert_equal 1, $jobqueue.count(queue: "default")
      end

      assert_equal 1, Performance.performances
      assert_equal 0, $jobqueue.count(queue: "default")
    end

    it "retries a job that fails" do
      assert_equal 0, $jobqueue.count(queue: "default")

      _job_id, queue = RetryJob.perform_async

      assert_equal "default", queue
      assert_equal 1, $jobqueue.count(queue: "default")

      perform_enqueued_job

      assert_equal 1, Performance.performances
      assert_equal 1, $jobqueue.count(queue: "default")

      perform_enqueued_job

      assert_equal 1, Performance.performances
      assert_equal 0, $jobqueue.count(queue: "default")
    end

    it "stops retrying a job after max retries" do
      assert_equal 0, $jobqueue.count(queue: "default")

      AlwaysFailJob.litejob_options(attempts: 1)
      _job_id, queue = AlwaysFailJob.perform_async

      assert_equal "default", queue
      assert_equal 1, $jobqueue.count(queue: "default")

      perform_enqueued_job

      assert_equal 1, Performance.performances
      assert_equal 1, $jobqueue.count(queue: "default")

      perform_enqueued_job

      assert_equal 2, Performance.performances
      assert_equal 0, $jobqueue.count(queue: "default")
      assert_equal 1, $jobqueue.count(queue: "_dead")
    end
  end

  describe ".perform_at" do
    it "returns job_id and queue" do
      job_id, queue = NoOpJob.perform_at(Time.now.to_i + 0.1)

      assert job_id
      assert_equal "default", queue
    end

    it "successfully pushes job to the queue" do
      assert_equal 0, $jobqueue.count(queue: "default")

      _job_id, queue = NoOpJob.perform_at(Time.now.to_i + 0.1)

      assert_equal "default", queue
      assert_equal 1, $jobqueue.count(queue: "default")
    end

    it "successfully runs the job" do
      assert_equal 0, $jobqueue.count(queue: "default")

      perform_enqueued_jobs do
        _job_id, queue = OpJob.perform_at(Time.now.to_i + 0.1)

        assert_equal "default", queue
        assert_equal 1, $jobqueue.count(queue: "default")
      end

      assert_equal 1, Performance.performances
      assert_equal 0, $jobqueue.count(queue: "default")
    end

    it "retries a job that fails" do
      assert_equal 0, $jobqueue.count(queue: "default")

      _job_id, queue = RetryJob.perform_at(Time.now.to_i + 0.1)

      assert_equal "default", queue
      assert_equal 1, $jobqueue.count(queue: "default")

      perform_enqueued_job

      assert_equal 1, Performance.performances
      assert_equal 1, $jobqueue.count(queue: "default")

      perform_enqueued_job

      assert_equal 1, Performance.performances
      assert_equal 0, $jobqueue.count(queue: "default")
    end

    it "stops retrying a job after max retries" do
      assert_equal 0, $jobqueue.count(queue: "default")

      AlwaysFailJob.litejob_options(attempts: 1)
      _job_id, queue = AlwaysFailJob.perform_at(Time.now.to_i + 0.1)

      assert_equal "default", queue
      assert_equal 1, $jobqueue.count(queue: "default")

      perform_enqueued_job

      assert_equal 1, Performance.performances
      assert_equal 1, $jobqueue.count(queue: "default")

      perform_enqueued_job

      assert_equal 2, Performance.performances
      assert_equal 0, $jobqueue.count(queue: "default")
      assert_equal 1, $jobqueue.count(queue: "_dead")
    end
  end

  describe ".perform_in" do
    it "returns job_id and queue" do
      job_id, queue = NoOpJob.perform_in(1)

      assert job_id
      assert_equal "default", queue
    end

    it "successfully pushes job to the queue" do
      assert_equal 0, $jobqueue.count(queue: "default")

      _job_id, queue = NoOpJob.perform_in(1)

      assert_equal "default", queue
      assert_equal 1, $jobqueue.count(queue: "default")
    end

    it "successfully runs the job" do
      assert_equal 0, $jobqueue.count(queue: "default")

      perform_enqueued_jobs do
        _job_id, queue = OpJob.perform_in(0.01)

        assert_equal "default", queue
        assert_equal 1, $jobqueue.count(queue: "default")
      end

      assert_equal 1, Performance.performances
      assert_equal 0, $jobqueue.count(queue: "default")
    end

    it "retries a job that fails" do
      assert_equal 0, $jobqueue.count(queue: "default")

      _job_id, queue = RetryJob.perform_in(0.01)

      assert_equal "default", queue
      assert_equal 1, $jobqueue.count(queue: "default")

      perform_enqueued_job

      assert_equal 1, Performance.performances
      assert_equal 1, $jobqueue.count(queue: "default")

      perform_enqueued_job

      assert_equal 1, Performance.performances
      assert_equal 0, $jobqueue.count(queue: "default")
    end

    it "stops retrying a job after max retries" do
      assert_equal 0, $jobqueue.count(queue: "default")

      AlwaysFailJob.litejob_options(attempts: 1)
      _job_id, queue = AlwaysFailJob.perform_in(0.01)

      assert_equal "default", queue
      assert_equal 1, $jobqueue.count(queue: "default")

      perform_enqueued_job

      assert_equal 1, Performance.performances
      assert_equal 1, $jobqueue.count(queue: "default")

      perform_enqueued_job

      assert_equal 2, Performance.performances
      assert_equal 0, $jobqueue.count(queue: "default")
      assert_equal 1, $jobqueue.count(queue: "_dead")
    end
  end

  describe ".perform_after" do
    it "returns job_id and queue" do
      job_id, queue = NoOpJob.perform_after(1)

      assert job_id
      assert_equal "default", queue
    end

    it "successfully pushes job to the queue" do
      assert_equal 0, $jobqueue.count(queue: "default")

      _job_id, queue = NoOpJob.perform_after(1)

      assert_equal "default", queue
      assert_equal 1, $jobqueue.count(queue: "default")
    end

    it "successfully runs the job" do
      assert_equal 0, $jobqueue.count(queue: "default")

      perform_enqueued_jobs do
        _job_id, queue = OpJob.perform_after(0.01)

        assert_equal "default", queue
        assert_equal 1, $jobqueue.count(queue: "default")
      end

      assert_equal 1, Performance.performances
      assert_equal 0, $jobqueue.count(queue: "default")
    end

    it "retries a job that fails" do
      assert_equal 0, $jobqueue.count(queue: "default")

      _job_id, queue = RetryJob.perform_after(0.01)

      assert_equal "default", queue
      assert_equal 1, $jobqueue.count(queue: "default")

      perform_enqueued_job

      assert_equal 1, Performance.performances
      assert_equal 1, $jobqueue.count(queue: "default")

      perform_enqueued_job

      assert_equal 1, Performance.performances
      assert_equal 0, $jobqueue.count(queue: "default")
    end

    it "stops retrying a job after max retries" do
      assert_equal 0, $jobqueue.count(queue: "default")

      AlwaysFailJob.litejob_options(attempts: 1)
      _job_id, queue = AlwaysFailJob.perform_after(0.01)

      assert_equal "default", queue
      assert_equal 1, $jobqueue.count(queue: "default")

      perform_enqueued_job

      assert_equal 1, Performance.performances
      assert_equal 1, $jobqueue.count(queue: "default")

      perform_enqueued_job

      assert_equal 2, Performance.performances
      assert_equal 0, $jobqueue.count(queue: "default")
      assert_equal 1, $jobqueue.count(queue: "_dead")
    end
  end

  describe ".delete" do
    it "removes the job" do
      assert_equal 0, $jobqueue.count(queue: "default")

      job_id, queue = NoOpJob.perform_async

      assert job_id
      assert_equal "default", queue
      assert_equal 1, $jobqueue.count(queue: "default")

      NoOpJob.delete(job_id)

      assert_equal 0, $jobqueue.count(queue: "default")
    end

    it "returns the job hash" do
      assert_equal 0, $jobqueue.count(queue: "default")

      job_id, queue = NoOpJob.perform_async

      assert job_id
      assert_equal "default", queue
      assert_equal 1, $jobqueue.count(queue: "default")

      result = NoOpJob.delete(job_id)

      assert_equal({"class" => "NoOpJob", "params" => [], "attempts" => 5, "queue" => "default"}, result)
    end
  end

  describe ".queue_as" do
    it "sets the queue name for .perform_async" do
      NoOpJob.queue_as("test")
      job_id, queue = NoOpJob.perform_async

      assert job_id
      assert_equal "test", queue
    end

    it "sets the queue name for .perform_at" do
      NoOpJob.queue_as("test")
      job_id, queue = NoOpJob.perform_at(Time.now.to_i + 0.1)

      assert job_id
      assert_equal "test", queue
    end

    it "sets the queue name for .perform_in" do
      NoOpJob.queue_as("test")
      job_id, queue = NoOpJob.perform_in(0.1)

      assert job_id
      assert_equal "test", queue
    end

    it "sets the queue name for .perform_after" do
      NoOpJob.queue_as("test")
      job_id, queue = NoOpJob.perform_after(0.1)

      assert job_id
      assert_equal "test", queue
    end
  end

  describe "exceptions" do
    describe "when trying to push to the Litequeue" do
      before do
        @original_verbose = $VERBOSE
        $VERBOSE = false
        @original_push = Litequeue.instance_method(:push)
      end

      after do
        Litequeue.define_method(@original_push.name, @original_push)
        $VERBOSE = @original_verbose
      end

      it "immediately raises non-retryable exception" do
        Litequeue.define_method(:push) do |value, delay = nil, queue = nil|
          Performance.performed!
          raise StandardError
        end

        assert_raises(StandardError) { NoOpJob.perform_async }
        assert_equal 1, Performance.performances
      end

      it "retries once retryable exception" do
        Litequeue.define_method(:push) do |value, delay = nil, queue = nil|
          Performance.performed!
          raise SQLite3::BusyException
        end

        assert_raises(SQLite3::BusyException) { NoOpJob.perform_async }
        assert_equal 2, Performance.performances
      end
    end

    describe "when processing a job" do
      it "immediately raises when the job class is undefined" do
        processor = Litejob::Processor.new("QUEUE", "ID", JSON.dump({class: "NonExistentClass", params: [], attempts: 5, queue: "default"}))

        assert_raises(NameError, "uninitialized constant NonExistentClass") { processor.process! }
      end
    end
  end
end

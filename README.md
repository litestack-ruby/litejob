# Litejob

[![Gem Version](https://badge.fury.io/rb/litejob.svg)](https://rubygems.org/gems/litejob)
[![Gem Downloads](https://img.shields.io/gem/dt/litejob)](https://rubygems.org/gems/litejob)
![Tests](https://github.com/litestack-ruby/litejob/actions/workflows/main.yml/badge.svg)
![Coverage](https://img.shields.io/badge/code_coverage-100%25-brightgreen)

Litejob is a Ruby module that enables seamless integration of the Litequeue job queueing system into Ruby applications. By including the Litejob module in a class and implementing the `#perform` method, developers can easily enqueue and process jobs asynchronously.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add litejob

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install litejob

## Usage

When a job is enqueued, Litejob creates a new instance of the class and passes it any necessary arguments. The class's `#perform` method is then called asynchronously to process the job. This allows the application to continue running without waiting for the job to finish, improving overall performance and responsiveness.

One of the main benefits of using Litejob is its simplicity. Because it integrates directly with Litequeue, developers do not need to worry about managing job queues or processing logic themselves. Instead, they can focus on implementing the `#perform` method to handle the specific job tasks.

Litejob also provides a number of useful features, including the ability to set job priorities, retry failed jobs, and limit the number of retries. These features can be configured using simple configuration options in the class that includes the Litejob module.

Overall, Litejob is a powerful and flexible module that allows developers to easily integrate Litequeue job queueing into their Ruby applications. By enabling asynchronous job processing, Litejob can help improve application performance and scalability, while simplifying the development and management of background job processing logic.

```ruby
class EasyJob
  include ::Litejob

  def perform(params)
    # do stuff
  end
end
```

Then later you can perform a job asynchronously:

```ruby
EasyJob.perform_async(params) # perform a job synchronously
```

Or perform it at a specific time:

```ruby
EasyJob.perform_at(time, params) # perform a job at a specific time
```

Or perform it after a certain delay:

```ruby
EasyJob.perform_in(delay, params) # perform a job after a certain delay
```

You can also specify a specific queue to be used

```ruby
class EasyJob
  include ::Litejob

  self.queue = :urgent

  def perform(params)
    # do stuff
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/litestack-ruby/litejob. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/litestack-ruby/litejob/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Litejob project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/litestack-ruby/litejob/blob/main/CODE_OF_CONDUCT.md).

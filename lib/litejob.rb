# frozen_string_literal: true

require_relative "litejob/version"
require_relative "litejob/concern"
require_relative "litejob/server"

# Litejob is responsible for providing an interface to job classes
module Litejob
  def self.included(klass)
    klass.extend(Concern)
  end
  end
end

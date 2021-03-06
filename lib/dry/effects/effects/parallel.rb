# frozen_string_literal: true

require 'dry/effects/effect'

module Dry
  module Effects
    module Effects
      class Parallel < ::Module
        Par = Effect.new(type: :parallel, name: :par)
        Join = Effect.new(type: :parallel, name: :join)

        def initialize
          define_method(:par) { |&block| ::Dry::Effects.yield(Par).(&block) }
          define_method(:join) { |xs| ::Dry::Effects.yield(Join.(xs)) }
        end
      end
    end
  end
end

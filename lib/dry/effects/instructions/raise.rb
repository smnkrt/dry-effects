require 'dry/effects/instruction'

module Dry
  module Effects
    module Instructions
      class Raise < Instruction
        attr_reader :error

        def initialize(error)
          @error = error
        end
      end

      def self.Raise(error)
        Raise.new(error)
      end
    end
  end
end
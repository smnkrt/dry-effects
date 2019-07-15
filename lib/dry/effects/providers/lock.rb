# frozen_string_literal: true

require 'dry/equalizer'
require 'dry/effects/provider'
require 'dry/effects/initializer'

module Dry
  module Effects
    module Providers
      class Lock < Provider[:lock]
        class Handle
          include ::Dry::Equalizer(:key)

          extend Initializer

          param :key
        end

        class Backend
          extend Initializer

          param :locks, default: -> { ::Hash.new }

          param :mutex, default: -> { ::Mutex.new }

          def lock(key)
            mutex.synchronize do
              if locked?(key)
                nil
              else
                locks[key] = Handle.new(key)
              end
            end
          end

          def locked?(key)
            locks.key?(key)
          end

          def unlock(handle)
            mutex.synchronize do
              if locked?(handle.key)
                locks.delete(handle.key)
                true
              else
                false
              end
            end
          end
        end

        Locate = Effect.new(type: :lock, name: :locate)

        option :backend, default: -> { parent&.backend || Backend.new }

        attr_reader :parent

        def lock(key)
          locked = backend.lock(key)
          owned << locked if locked
          locked
        end

        def locked?(key)
          backend.locked?(key)
        end

        def unlock(handle)
          backend.unlock(handle)
        end

        def locate
          self
        end

        def call(_)
          @parent = ::Dry::Effects.yield(Locate) { nil }
          super
        ensure
          owned.each { |handle| unlock(handle) }
        end

        def owned
          @owned ||= []
        end
      end
    end
  end
end
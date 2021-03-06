# frozen_string_literal: true

RSpec.describe 'retrying' do
  include Dry::Effects.Retry
  include Dry::Effects::Handler.Retry(:inner, as: :retry_inner)
  include Dry::Effects::Handler.Retry(:outer, as: :retry_outer)

  example 'exhausting all attempts' do
    counter = 0

    result = retry_outer(3) do
      retry_inner(5) do
        counter += 1
        repeat(:inner)
      end
      repeat(:outer)

      :done
    end

    expect(result).to be(nil)
    expect(counter).to be(15)
  end

  example 'exhausting all outer attempts' do
    counter = 0

    result = retry_outer(3) do
      retry_inner(5) do
        counter += 1
        repeat(:outer)
      end
      repeat(:outer)

      :done
    end

    expect(result).to be(nil)
    expect(counter).to be(3)
  end

  it 'returns result if no repeats triggerred' do
    counter = 0

    result = retry_outer(3) do
      retry_inner(5) do
        counter += 1
        :done
      end
      :done
    end

    expect(result).to be(:done)
    expect(counter).to be(1)
  end

  it 'returns result if only inner loop exhausted' do
    counter = 0

    result = retry_outer(3) do
      retry_inner(5) do
        counter += 1
        repeat(:inner)
      end
      :done
    end

    expect(result).to be(:done)
    expect(counter).to be(5)
  end

  describe 'constructors' do
    include Dry::Effects::Constructors

    example 'building retry effects' do
      expect(Retry(:foo)).to eql(
        Dry::Effects::Effects::Retry::Retry.new(
          type: :retry, scope: :foo
        )
      )
    end
  end
end

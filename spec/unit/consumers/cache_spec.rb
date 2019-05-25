require 'dry/effects/consumers/cache'

RSpec.describe Dry::Effects::Consumers::Cache do
  subject(:cache) { described_class.new }

  describe '#fetch_or_store' do
    let(:input) {  }

    it 'returns caches result' do
      expect(cache.fetch_or_store([1, 2, 3], -> { :foo })).to be(:foo)
      expect(cache.fetch_or_store([1, 2, 3], -> { :bar })).to be(:foo)
    end
  end
end

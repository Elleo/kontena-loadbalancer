
describe Kontena::Actors::Message do

  describe '.new' do
    it 'allows to set action and value' do
      message = described_class.new(:foo, 'bar')
      expect(message.action).to eq(:foo)
      expect(message.value).to eq('bar')
    end

    it 'allows to set only action' do
      message = described_class.new(:foo)
      expect(message.action).to eq(:foo)
      expect(message.value).to be_nil
    end
  end
end

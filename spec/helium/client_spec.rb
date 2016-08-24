require 'spec_helper'

describe Helium::Client do
  let(:client) { Helium::Client.new(api_key: API_KEY) }

  it 'has an api key' do
    expect(client.api_key).to eq(API_KEY)
  end

  it 'does not show the api key when inspecting the object' do
    expect(client.inspect).not_to include(API_KEY)
  end

  context 'when in debug mode' do
    let(:client) { Helium::Client.new(api_key: API_KEY, debug: true) }

    use_cassette 'client/debug'

    it 'prints all external api calls' do
      expect(STDOUT).to receive(:puts).with("GET https://api.helium.com/v1/sensor 200 ")
      client.sensors
    end
  end

  context 'when api key is invalid' do
    let(:client) { Helium::Client.new(api_key: 'an invalid key') }

    use_cassette 'client/invalid_api_key'

    it 'raises an InvalidApiKey error' do
      expect {
        client.sensors
      }.to raise_error(Helium::InvalidApiKey)

    end
  end
end

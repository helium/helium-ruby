require 'spec_helper'

describe Helium::Organization do
  let(:client) { Helium::Client.new(api_key: API_KEY) }

  context 'Client#organization' do
    let(:organization) { client.organization }

    around(:each) do |spec|
      VCR.use_cassette 'organization/get' do
        spec.run
      end
    end

    it 'is an Organization' do
      expect(organization).to be_a(Helium::Organization)
    end

    it 'has an id' do
      expect(organization.id).to eq('dev-accounts@helium.co')
    end

    it 'has a name' do
      expect(organization.name).to eq('dev-accounts@helium.co')
    end

    it 'has a timezone' do
      expect(organization.timezone).to eq('UTC')
    end

    it 'has a created_at datetime' do
      expect(organization.created_at).to eq(DateTime.parse("2015-09-10T20:50:18.183896Z"))
    end

    it 'has an updated_at datetime' do
      expect(organization.updated_at).to eq(DateTime.parse("2015-09-10T20:50:18.183896Z"))
    end
  end
end

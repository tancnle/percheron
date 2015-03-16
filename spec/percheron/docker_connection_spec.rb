require 'spec_helper'

describe Percheron::DockerConnection do
  let(:config) { Percheron::Config.new('./spec/support/.percheron_valid.yml') }
  let(:expected_url) { 'https://127.0.0.1:2376' }

  subject { described_class.new(config) }

  before do
    ENV.delete('DOCKER_CERT_PATH')
  end

  describe '#setup!' do
    context "when ENV['DOCKER_CERT_PATH'] is defined" do
      let(:expected_options) { { client_cert: '/tmp/cert.pem', client_key: '/tmp/key.pem', ssl_ca_file: '/tmp/ca.pem', scheme: 'https', read_timeout: 300 } }

      before do
        ENV['DOCKER_CERT_PATH'] = '/tmp'
      end

      it 'sets Docker url' do
        subject.setup!
        expect(Docker.url).to eql(expected_url)
      end

      it 'sets Docker options' do
        subject.setup!
        expect(Docker.options).to eql(expected_options)
      end
    end

    context "when ENV['DOCKER_CERT_PATH'] is not defined" do
      let(:expected_options) { { read_timeout: 300 } }

      it 'sets Docker url' do
        subject.setup!
        expect(Docker.url).to eql(expected_url)
      end

      it 'sets Docker options' do
        subject.setup!
        expect(Docker.options).to eql(expected_options)
      end
    end
  end
end

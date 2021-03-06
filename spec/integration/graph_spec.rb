require 'integration/spec_helper'
require 'tempfile'
require 'filemagic'

describe 'percheron' do
  before do
    $logger = double('Logger').as_null_object
    $metastore = double('Metastore').as_null_object
  end

  before(:all) do
    Dir.chdir(File.expand_path('../support', __FILE__))
    cleanup!
  end

  after do
    $logger = $metastore = nil
    cleanup!
  end

  describe 'graph' do
    let(:file) { Tempfile.new(%w(percheron-graph- .png)) }

    it 'creates a dependancy graph' do
      Percheron::Commands::Graph.run(Dir.pwd, %W(--output #{file.path} percheron-test))
      expect(FileMagic.new(FileMagic::MAGIC_SYMLINK).file(file.path)).to eql('PNG image data, 512 x 267, 8-bit/color RGBA, non-interlaced')
    end
  end
end

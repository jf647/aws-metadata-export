require 'aws/metadata_export'

RSpec.describe Aws::MetadataExport do
  include FakeFS::SpecHelpers

  before do
    ENV.delete('AWS_METADATA_EXPORT_DIR')
    ENV.delete('AWS_METADATA_EXPORT_UMASK')
    allow(Ec2Metadata).to receive(:[])
      .with('instance_id')
      .and_return('i-deadbeef')
    allow(Ec2Metadata).to receive(:[])
      .with('local_ipv4')
      .and_return('10.10.10.10')
    allow(Ec2Metadata).to receive(:[])
      .with('placement')
      .and_return('availability_zone' => 'us-east-1a')
    @ame = Aws::MetadataExport.new
    allow(@ame).to receive(:tags).and_return([
      { 'key' => 'foo', 'value' => 'bar' },
      { 'key' => 'baz', 'value' => 'gzonk' }
    ])
  end

  it 'should export metadata' do
    @ame.export
    expect(File.exist?('/var/run/aws_metadata_export/instance_id'))
      .to be true
    expect(File.read('/var/run/aws_metadata_export/instance_id'))
      .to eq 'i-deadbeef'
    expect(File.exist?('/var/run/aws_metadata_export/local_ipv4'))
      .to be true
    expect(File.read('/var/run/aws_metadata_export/local_ipv4'))
      .to eq '10.10.10.10'
    expect(File.exist?('/var/run/aws_metadata_export/az'))
      .to be true
    expect(File.read('/var/run/aws_metadata_export/az'))
      .to eq 'us-east-1a'
    expect(File.exist?('/var/run/aws_metadata_export/region'))
      .to be true
    expect(File.read('/var/run/aws_metadata_export/region'))
      .to eq 'us-east-1'
  end

  it 'should export tags by default' do
    @ame.export
    expect(File.exist?('/var/run/aws_metadata_export/tags/foo'))
      .to be true
    expect(File.read('/var/run/aws_metadata_export/tags/foo'))
      .to eq 'bar'
    expect(File.exist?('/var/run/aws_metadata_export/tags/baz'))
      .to be true
    expect(File.read('/var/run/aws_metadata_export/tags/baz'))
      .to eq 'gzonk'
  end

  it 'should not export tags when disabled' do
    @ame.export(export_tags: false)
    %w(foo baz).each do |tag|
      expect(File.exist?("/var/run/aws_metadata_export/tags/#{tag}"))
        .to be false
    end
  end

  it 'should respect the umask env var' do
    ENV['AWS_METADATA_EXPORT_UMASK'] = '00022'
    @ame.export
    expect(File.umask).to eq 00022
  end

  it 'should respect the output dir env var' do
    ENV['AWS_METADATA_EXPORT_DIR'] = '/foo'
    @ame.export
    expect(File.exist?('/foo/instance_id'))
      .to be true
    expect(File.exist?('/foo/tags/foo'))
      .to be true
  end
end

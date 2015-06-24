require 'aws-sdk'
require 'ec2_metadata'

module Aws
  class MetadataExport
    def export
      set_umask
      write_metadata
      write_tags
    end

    private

    def set_umask
      if ENV.key?('AWS_METADATA_EXPORT_UMASK')
        File.umask ENV['AWS_METADATA_EXPORT_UMASK'].to_i(8)
      else
        File.umask 00077
      end
    end

    def write_metadata
      %w(instance_id local_ipv4 az region).each do |meta|
        metafile = File.join(output_dir, meta)
        File.open(metafile, 'w') do |fh|
          fh.write send meta.to_sym
        end
      end
    end

    def write_tags
      tags.each do |tag|
        tagfile = File.join(tags_dir, tag['key'])
        File.open(tagfile, 'w') do |fh|
          fh.write tag['value']
        end
      end
    end

    # :nocov:
    def aws_client
      @aws_client ||= Aws::EC2::Client.new(region: region)
    end
    # :nocov:

    def output_dir
      @output_dir ||= begin
        dir = ENV['AWS_METADATA_EXPORT_DIR'] || File.join(
          %w(/ var run aws_metadata_export)
        )
        FileUtils.mkpath(dir)
        dir
      end
    end

    def tags_dir
      @tags_dir ||= begin
        dir = File.join(output_dir, 'tags')
        FileUtils.mkpath(dir)
        dir
      end
    end

    def az
      @az ||= Ec2Metadata['placement']['availability_zone']
    end

    def instance_id
      @instance_id ||= Ec2Metadata['instance_id']
    end

    def local_ipv4
      @local_ipv4 ||= Ec2Metadata['local_ipv4']
    end

    def region
      @region ||= az.chop
    end

    # :nocov:
    def tags
      @tags ||= Aws::EC2::Resource
                .new(aws_client: client)
                .instance(instance_id).tags
    end
    # :nocov:
  end
end

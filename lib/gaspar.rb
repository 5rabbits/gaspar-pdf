require 'gaspar/version'
require 'open-uri'
require 'net/http'
require 'spoon'
require 'pdf-reader'

# Gaspar Gem
module Gaspar
  # Parser
  # This class parses a PDF into a machine-readable format
  class Parser
    def initialize(source:, as: :html, target: nil, options: {})
      @source = determine_source(source)
      @type = determine_type(as)
      @target = determine_target(target, @type)
      @options = options
      @extractor = extractor
    end

    def parse
      @extractor.extract
      @extractor.content
    end

    private

    def default_types
      {
        json: 'cells_json',
        xml: 'cells_xml',
        html: 'table_html',
        csv: 'table_csv'
      }
    end

    def determine_type(type)
      default_types[type]
    end

    def determine_target(target, type)
      return target if target

      path = Dir.tmpdir.to_s
      "#{path}/output_#{type}"
    end

    def extractor
      page_count = Reader.new(@source).page_count

      Extractor.new(
        @source, @target, page_count, @type, @options
      )
    end

    def random_source_name
      rand(16**16).to_s(16)
    end

    def download_file(source)
      path = Dir.tmpdir.to_s
      tmp_file = "#{path}/#{random_source_name}.pdf"
      File.open(tmp_file, 'wb') do |saved_file|
        open(source, 'rb') do |read_file|
          saved_file.write(read_file.read)
        end
      end

      tmp_file
    end

    def determine_source(source)
      is_file = File.exist?(source) && !File.directory?(source)
      is_http = URI(source).scheme == 'http'
      is_https = URI(source).scheme == 'https'

      unless is_file || is_http || is_https
        raise IOError, "Source (#{source}) is neither a file nor an URL."
      end

      is_file ? source : download_file(source)
    end
  end

  # Extract data from all pages of PDF
  class Extractor
    def initialize(source, target, pages, type, options)
      @source = source
      @target = target
      @pages = pages
      @type = type
      @options = options
    end

    def extract
      unless command_available?
        io_error 'Can\'t find pdf-table-extract executable in PATH'
      end

      opts = process_options.split(' ')
      args = [extract_command, opts].flatten

      pid = Spoon.spawnp(*args)
      Process.waitpid(pid)
      io_error("Could not parse #{@source}") unless $?.exitstatus.zero?
    end

    def content
      open(@target, 'rb').read
    end

    private

    def process_options
      opts = []
      opts.push("-i #{@source}") if @source
      opts.push("-o #{@target}") if @target
      @pages.times do |p|
        opts.push("-p #{p + 1}")
      end
      opts.push("-t #{@type}")

      opts.join(' ')
    end

    def command_available?
      extract_command
    end

    def extract_command
      'pdf-table-extract' if which('pdf-table-extract')
    end

    def which(cmd)
      exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
      ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
        exts.each do |ext|
          exe = File.join(path, "#{cmd}#{ext}")
          return exe if File.executable? exe
        end
      end
      nil
    end

    def io_error(error_message)
      raise IOError, error_message
    end
  end

  # Read infor from PDF file usin pdf-reader
  class Reader
    def initialize(source)
      @reader = ::PDF::Reader.new(source)
    end

    def metadata
      @reader.metadata
    end

    def info
      @reader.info
    end

    def page_count
      @reader.page_count
    end
  end

  def self.parse(source:, as: :html, target: nil, options: {})
    Parser.new(source: source,
               as: as,
               target: target,
               options: options).parse
  end
end

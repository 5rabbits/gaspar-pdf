require 'gaspar/version'
require 'open-uri'
require 'net/http'
require 'spoon'

# Gaspar Gem
module Gaspar
  # Parser
  # This class parses a PDF into a machine-readable format
  class Parser
    def initialize(source, target, options = {})
      @source = source
      @target = target
      @options = options
    end

    def parse
      unless command_available?
        io_error 'Can\'t find pdf-table-extract executable in PATH'
      end

      src = determine_source(@source)
      opts = process_options(src).split(' ')
      args = [extract_command, opts].flatten

      pid = Spoon.spawnp(*args)
      Process.waitpid(pid)

      io_error("Could not parse #{src}") unless $?.exitstatus.zero?
    end

    private

    def io_error(error_message)
      raise IOError, error_message
    end

    def process_options(source)
      opts = []
      opts.push("-i #{source}") if source
      opts.push("-o #{@target}") if @target
      opts.push("-p #{@options[:page]}") if @options[:page]
      opts.push("-t #{@options[:format]}") if @options[:format]

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

    def random_source_name
      rand(16**16).to_s(16)
    end

    def download_file(source)
      tmp_file = "/tmp/#{random_source_name}.pdf"
      File.open(tmp_file, 'wb') do |saved_file|
        open(URI.encode(source), 'rb') do |read_file|
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

  # Read infor from PDF file usin pdf-reader
  class Reader
    def initialize(source)
      @reader = PDF::Reader.new(source)
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

  # options[:type]
  # {cells_csv,cells_json,cells_xml,table_csv,table_html,table_chtml,table_list}
  def self.parse(source, target, options = {})
    Parser.new(source, target, options).parse
  end
end

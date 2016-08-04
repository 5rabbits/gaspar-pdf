require "gaspar/version"
require 'open-uri'
require "net/http"
require "spoon"

module Gaspar
  class Converter
    def initialize(source, target, options = {})
      @options = options
      @source = source
      @target = target
    end

    def convert
      raise IOError, "Can't find pdf-table-extract executable in PATH" if not command_available?
      src = determine_source(@source)
      opts = process_options(src).split(" ")
      args = [pdfTableExtract_command, opts].flatten
      pid = Spoon.spawnp(*args)
      Process.waitpid(pid)

      ## TODO: Grab error message from pdf-table-extract and raise a better error
      raise IOError, "Could not convert #{src}" if $?.exitstatus != 0
    end

    private

    def process_options(source)
      opts = []
      opts.push("-i #{source}") if source
      opts.push("-o #{@target}") if @target
      opts.push("-p #{@options[:page]}") if @options[:paget]
      opts.push("-t #{@options[:format]}") if @options[:format]

      opts.join(" ")
    end

    def command_available?
      pdfTableExtract_command
    end

    def pdfTableExtract_command
      cmd = nil
      cmd = "pdf-table-extract" if which("pdf-table-extract")
    end

    def which(cmd)
      exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
        ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
          exts.each do |ext|
            exe = File.join(path, "#{cmd}#{ext}")
            return exe if File.executable? exe
          end
        end
      return nil
    end

    def random_source_name
      rand(16**16).to_s(16)
    end

    def download_file(source)
      tmp_file = "/tmp/#{random_source_name}.pdf"
      File.open(tmp_file, "wb") do |saved_file|
        open(URI.encode(source), 'rb') do |read_file|
          saved_file.write(read_file.read)
        end
      end

      tmp_file
    end

    def determine_source(source)
      is_file = File.exists?(source) && !File.directory?(source)
      is_http = URI(source).scheme == "http"
      is_https = URI(source).scheme == "https"
      raise IOError, "Source (#{source}) is neither a file nor an URL." unless is_file || is_http || is_https

      is_file ? source : download_file(source)
    end
  end

  # options[:type]: {cells_csv,cells_json,cells_xml,table_csv,table_html,table_chtml,table_list}
  def self.convert(source, target, options = {})
    Converter.new(source, target, options).convert
  end
end

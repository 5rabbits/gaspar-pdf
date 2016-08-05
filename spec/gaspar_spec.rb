require 'spec_helper'

describe Gaspar do
  before(:all) do
    @table_pdf = file_path("table.pdf")
    @target_path = "#{Dir::tmpdir}"
    @table_html = @target_path + "/output.html"
  end


  describe '#parse' do
    describe 'with wrong params' do
      it 'should raise error if source file does not exists' do
        c = Gaspar::Parser.new('unknown.pdf', 'unknown.html')
        expect { c.parse }.to raise_error(IOError)
      end

      it 'should raise error if source is not file nor url' do
        c = Gaspar::Parser.new('http://  /.pdf', 'unknown.html')
        expect { c.parse }.to raise_error(URI::InvalidURIError)
      end
    end

    describe 'with write params' do
      it "should be possible to specify one page" do
        Gaspar::Parser.new(@table_pdf, @table_html, {
          page: 2, format: 'table_html'
        }).parse

        doc = Nokogiri::HTML(File.open(@table_html))
        expect(doc.search('//comment()').text).not_to be_empty
      end
    end

  end
end

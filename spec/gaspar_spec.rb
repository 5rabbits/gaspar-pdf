require 'spec_helper'
require 'json'

describe Gaspar do
  before(:all) do
    @table_pdf = file_path('table.pdf')
    @target_path = Dir.tmpdir.to_s
    @table_html = @target_path + '/output.html'
    @cell_json = @target_path + '/output.json'
    @table_csv = @target_path + '/output.csv'
  end

  describe '#parse' do
    describe 'with wrong params' do
      it 'should raise error if source file does not exists' do
        expect do
          c = Gaspar::Parser.new('unknown.pdf', 'unknown.html')
          c.parse
        end.to raise_error(IOError)
      end

      it 'should raise error if source is not file nor url' do
        expect do
          c = Gaspar::Parser.new('http://  /.pdf', 'unknown.html')
          c.parse
        end.to raise_error(URI::InvalidURIError)
      end
    end

    describe 'with write params' do
      it 'should be parsed' do
        Gaspar::Parser.new(@table_pdf, @table_html,
                           format: 'table_html').parse

        doc = Nokogiri::HTML(File.open(@table_html))
        expect(doc.search('//comment()').text).not_to be_empty
      end

      it 'should get content' do
        content = Gaspar::Parser.new(@table_pdf, @table_html,
                                     format: 'table_html').parse_with_content
        expect(content).not_to be_empty
      end

      describe 'without format' do
        context 'should be parsed with target extension format' do
          it 'JSON' do
            Gaspar::Parser.new(@table_pdf, @cell_json).parse_with_content
            expect(JSON.parse(File.read(@cell_json))).not_to raise_error
          end
        end
      end
    end
  end
end

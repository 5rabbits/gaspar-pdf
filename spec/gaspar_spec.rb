require 'spec_helper'

describe Gaspar do

  before(:all) do

  end

  before(:each) do

  end

  after(:each) do

  end

  describe "#convert" do
    describe "with no options" do
      it "should raise error if source file does not exists" do
        c = Gaspar::Converter.new("nonsense.pdf", "nonsense.html")
        lambda { c.convert }.should raise_error(IOError)
      end
  end
end

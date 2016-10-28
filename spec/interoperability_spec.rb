# encoding: UTF-8
require_relative "./spec_helper"

if ENV["RUN_INTEROPERABILITY_TESTS"]
  RSpec.describe 'ActiveSupport interoperability' do
    it "encodes active support safe buffer" do
      require 'active_support'
      string = "<p>This is a test</p>"
      buffer = ActiveSupport::SafeBuffer.new(string)
      coder = HTMLEntities.new
      expect(coder.encode(buffer, :named)).to eq(coder.encode(string, :named))
    end
  end
end

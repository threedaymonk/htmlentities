# encoding: UTF-8
require_relative "./spec_helper"

describe 'Entities' do
  it "raises exception when unknown flavor specified" do

    expect {
      HTMLEntities.new('foo')
    }.to raise_exception(HTMLEntities::UnknownFlavor)
  end

  it "allows symbol for flavor" do
    expect {
      HTMLEntities.new(:xhtml1)
    }.not_to raise_exception
  end

  it "allows upper case flavor" do
    expect {
      HTMLEntities.new('XHTML1')
    }.not_to raise_exception
  end
end

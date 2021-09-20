# encoding: UTF-8
require_relative "./spec_helper"

describe 'XHTML1' do
  let(:html_entities) { HTMLEntities.new('xhtml1') }

  it "encodes &apos;" do
    expect(html_entities.encode("'", :basic)).to eq("&apos;")
  end

  it "decodes &apos;" do
    expect(html_entities.decode("&eacute;&apos;")).to eq("é'")
  end

  it "does not decode dotted entity" do
    expect(html_entities.decode("&b.Theta;")).to eq("&b.Theta;")
  end
end

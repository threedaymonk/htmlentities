# encoding: UTF-8
require_relative "./spec_helper"

describe 'HTML4' do
  let (:html_entities) { HTMLEntities.new('html4') }

  # Found by Marcos Kuhns
  it "does not encode &apos;" do
    expect(html_entities.encode("'", :basic)).to eq("'")
  end

  it "does not decode &apos;" do
    expect(html_entities.decode("&eacute;&apos;")).to eq("é&apos;")
  end

  it "does not decode dotted entity" do
    expect(html_entities.decode("&b.Theta;")).to eq("&b.Theta;")
  end
end

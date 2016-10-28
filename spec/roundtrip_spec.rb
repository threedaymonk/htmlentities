# encoding: UTF-8
require_relative "./spec_helper"

RSpec.describe 'Round trip conversion' do
  let(:xhtml1_entities) { HTMLEntities.new('xhtml1') }
  let(:html4_entities) { HTMLEntities.new('html4') }

  it "roundtrips xhtml1 entities via named encoding" do
    each_mapping 'xhtml1' do |name, string|
      expect(xhtml1_entities.decode(xhtml1_entities.encode(string, :named))).to eq(string)
    end
  end

  it "roundtrips xhtml1 entities via basic and named encoding" do
    each_mapping 'xhtml1' do |name, string|
      expect(xhtml1_entities.decode(xhtml1_entities.encode(string, :basic, :named))).to eq(string)
    end
  end

  it "roundtrips xhtml1 entities via basic named and decimal encoding" do
    each_mapping 'xhtml1' do |name, string|
      expect(xhtml1_entities.decode(xhtml1_entities.encode(string, :basic, :named, :decimal))).to eq(string)
    end
  end

  it "roundtrips xhtml1 entities via hexadecimal encoding" do
    each_mapping 'xhtml1' do |name, string|
      expect(xhtml1_entities.decode(xhtml1_entities.encode(string, :hexadecimal))).to eq(string)
    end
  end

  it "roundtrips html4 entities via named encoding" do
    each_mapping 'html4' do |name, string|
      expect(html4_entities.decode(html4_entities.encode(string, :named))).to eq(string)
    end
  end

  it "roundtrips html4 entities via basic and named encoding" do
    each_mapping 'html4' do |name, string|
      expect(html4_entities.decode(html4_entities.encode(string, :basic, :named))).to eq(string)
    end
  end

  it "roundtrips html4 entities via basic named and decimal encoding" do
    each_mapping 'html4' do |name, string|
      expect(html4_entities.decode(html4_entities.encode(string, :basic, :named, :decimal))).to eq(string)
    end
  end

  it "roundtrips html4 entities via hexadecimal encoding" do
    each_mapping 'html4' do |name, string|
      expect(html4_entities.decode(html4_entities.encode(string, :hexadecimal))).to eq(string)
    end
  end

  def each_mapping(flavor)
    HTMLEntities::MAPPINGS[flavor].each do |name, codepoint|
      yield name, [codepoint].pack('U')
    end
  end
end

# encoding: UTF-8
require_relative "./spec_helper"

describe 'Expanded entities' do
  let(:html_entities) { HTMLEntities.new(:expanded) }

  TEST_ENTITIES_SET = [
    ['sub',      0x2282,   "xhtml", nil,      "⊂", ],
    ['sup',      0x2283,   "xhtml", nil,      "⊃", ],
    ['nsub',     0x2284,   "xhtml", nil,      "⊄", ],
    ['subE',     0x2286,   nil,     "skip",   "⊆", ],
    ['sube',     0x2286,   "xhtml", nil,      "⊆", ],
    ['supE',     0x2287,   nil,     "skip",   "⊇", ],
    ['supe',     0x2287,   "xhtml", nil,      "⊇", ],
    ['bottom',   0x22a5,   nil,     "skip",   "⊥", ],
    ['perp',     0x22a5,   "xhtml", nil,      "⊥", ],
    ['models',   0x22a7,   nil,     nil,      "⊧", ],
    ['vDash',    0x22a8,   nil,     nil,      "⊨", ],
    ['Vdash',    0x22a9,   nil,     nil,      "⊩", ],
    ['Vvdash',   0x22aa,   nil,     nil,      "⊪", ],
    ['nvdash',   0x22ac,   nil,     nil,      "⊬", ],
    ['nvDash',   0x22ad,   nil,     nil,      "⊭", ],
    ['nVdash',   0x22ae,   nil,     nil,      "⊮", ],
    ['nsubE',    0x2288,   nil,     nil,      "⊈", ],
    ['nsube',    0x2288,   nil,     "skip",   "⊈", ],
    ['nsupE',    0x2289,   nil,     nil,      "⊉", ],
    ['nsupe',    0x2289,   nil,     "skip",   "⊉", ],
    ['subnE',    0x228a,   nil,     nil,      "⊊", ],
    ['subne',    0x228a,   nil,     "skip",   "⊊", ],
    ['vsubnE',   0x228a,   nil,     "skip",   "⊊", ],
    ['vsubne',   0x228a,   nil,     "skip",   "⊊", ],
    ['nsc',      0x2281,   nil,     nil,      "⊁", ],
    ['nsup',     0x2285,   nil,     nil,      "⊅", ],
    ['b.alpha',  0x03b1,   nil,     "skip",   "α", ],
    ['b.beta',   0x03b2,   nil,     "skip",   "β", ],
    ['b.chi',    0x03c7,   nil,     "skip",   "χ", ],
    ['b.Delta',  0x0394,   nil,     "skip",   "Δ", ],
  ]

  it "encodes apos entity" do
    # note: the normal ' 0x0027, not ʼ 0x02BC
    expect(html_entities.encode("'", :named)).to eq("&apos;")
  end

  it "decodes apos entity" do
    expect(html_entities.decode("&eacute;&apos;")).to eq("é'")
  end

  it "decodes dotted entity" do
    expect(html_entities.decode("&b.Theta;")).to eq("Θ")
  end

  it "encodes from test set" do
    TEST_ENTITIES_SET.each do |ent, _, _, skip, decoded|
      next if skip
      expect(html_entities.encode(decoded, :named)).to eq("&#{ent};")
    end
  end

  it "decodes from test set" do
    TEST_ENTITIES_SET.each do |ent, _, _, _, decoded|
      expect(html_entities.decode("&#{ent};")).to eq(decoded)
    end
  end

  it "round trips preferred entities" do
    TEST_ENTITIES_SET.each do |ent, _, _, skip, decoded|
      next if skip
      expect(html_entities.encode(html_entities.decode("&#{ent};"), :named)).to eq("&#{ent};")
      expect(html_entities.decode(html_entities.encode(decoded, :named))).to eq(decoded)
    end
  end

  it "does not round trip decoding skipped entities" do
    TEST_ENTITIES_SET.each do |ent, _, _, skip, decoded|
      next unless skip
      expect(html_entities.encode(html_entities.decode("&#{ent};"), :named)).not_to eq("&#{ent};")
    end
  end

  it "round trips encoding skipped entities" do
    TEST_ENTITIES_SET.each do |ent, _, _, skip, decoded|
      next unless skip
      expect(html_entities.decode(html_entities.encode(decoded, :named))).to eq(decoded)
    end
  end

  it "treats all xhtml1 named entities as xhtml does" do
    xhtml_encoder = HTMLEntities.new(:xhtml1)
    HTMLEntities::MAPPINGS['xhtml1'].each do |ent, decoded|
      expect(html_entities.decode("&#{ent};")).to eq(xhtml_encoder.decode("&#{ent};"))
      expect(html_entities.encode(decoded, :named)).to eq(xhtml_encoder.encode(decoded, :named))
    end
  end

  it "does not agree with xhtml1 when not in xhtml" do
    xhtml_encoder = HTMLEntities.new(:xhtml1)
    TEST_ENTITIES_SET.each do |ent, _, xhtml1, skip, decoded|
      next if xhtml1 || skip
      expect(html_entities.decode("&#{ent};")).not_to eq(xhtml_encoder.decode("&#{ent};"))
      expect(html_entities.encode(decoded, :named)).not_to eq(xhtml_encoder.encode(decoded, :named))
    end
  end
end

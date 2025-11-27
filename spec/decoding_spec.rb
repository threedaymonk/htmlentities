require_relative "spec_helper"

RSpec.describe "Decoding" do
  shared_examples "every codec" do
    it "decodes basic entities" do
      expect(codec.decode("&amp;")).to eq("&")
      expect(codec.decode("&lt;")).to eq("<")
      expect(codec.decode("&quot;")).to eq('"')
    end

    it "decodes extended named entities" do
      expect(codec.decode("&plusmn;")).to eq("±")
      expect(codec.decode("&eth;")).to eq("ð")
      expect(codec.decode("&OElig;")).to eq("Œ")
      expect(codec.decode("&oelig;")).to eq("œ")
    end

    it "decodes decimal entities" do
      expect(codec.decode("&#8220;")).to eq("“")
      expect(codec.decode("&#8230;")).to eq("…")
      expect(codec.decode("&#32;")).to eq(" ")
    end

    it "decodes hexadecimal entities" do
      expect(codec.decode("&#x2212;")).to eq("−")
      expect(codec.decode("&#x2014;")).to eq("—")
      expect(codec.decode("&#x0060;")).to eq("`")
      expect(codec.decode("&#x60;")).to eq("`")
    end

    it "does not mutate string being decoded" do
      original = "&lt;&#163;"
      input = original.dup
      HTMLEntities.new.decode(input)

      expect(input).to eq(original)
    end

    it "decodes text with mix of entities" do
      # Just a random headline - I needed something with accented letters.
      expect(codec.decode("Le tabac pourrait bient&ocirc;t &#234;tre banni dans tous les lieux publics en France"))
        .to eq("Le tabac pourrait bientôt être banni dans tous les lieux publics en France")
      expect(codec.decode("&quot;bient&ocirc;t&quot; &amp; &#25991;&#x5b57;"))
        .to eq("\"bientôt\" & 文字")
    end

    it "does nothing with an empty string" do
      expect(codec.decode("")).to eq("")
    end

    it "skips unknown entity" do
      expect(codec.decode("&bogus;")).to eq("&bogus;")
    end

    it "decodes double encoded entity once" do
      expect(codec.decode("&amp;amp;")).to eq("&amp;")
      expect(codec.decode("&amp;#3346;")).to eq("&#3346;")
    end

    # Faults found and patched by Moonwolf
    it "decodes full hexadecimal range" do
      (0..127).each do |codepoint|
        expect(codec.decode("&#x#{codepoint.to_s(16)};")).to eq([codepoint].pack("U"))
      end
    end

    # Reported by Dallas DeVries and Johan Duflost
    it "decodes named entities reported as missing in 3.0.1" do
      expect(codec.decode("&sup2;")).to eq("\u00b2")
      expect(codec.decode("&bull;")).to eq("\u2022")
      expect(codec.decode("&delta;")).to eq("\u03b4")
    end

    it "casts parameter to string before encoding" do
      obj = Object.new
      def obj.to_s
        "foo"
      end
      expect(codec.decode(obj)).to eq("foo")
    end

    it "decodes without semicolon if permissible" do
      expect(codec.decode("&amp;\n\n\n")).to eq("&\n\n\n")
      expect(codec.decode("&amp;\r\n")).to eq("&\r\n")
      expect(codec.decode("&amp<tag>")).to eq("&<tag>")
    end

    it "ignores a semicolon that does not precede a newline or tag" do
      expect(codec.decode("&amp")).to eq("&amp")
      expect(codec.decode("&ampsome text")).to eq("&ampsome text")
    end
  end

  context "with default flavor" do
    let(:codec) { HTMLEntities.new }

    it_behaves_like "every codec"

    it "decodes &apos;" do
      expect(codec.decode("&apos;")).to eq("'")
    end

    it "skips entities from expanded set" do
      expect(codec.decode("&vdash;")).to eq("&vdash;")
      expect(codec.decode("&b.alpha;")).to eq("&b.alpha;")
    end
  end

  context "with xhtml1 flavor" do
    let(:codec) { HTMLEntities.new(:xhtml1) }

    it_behaves_like "every codec"

    it "decodes &apos;" do
      expect(codec.decode("&apos;")).to eq("'")
    end

    it "skips entities from expanded set" do
      expect(codec.decode("&vdash;")).to eq("&vdash;")
      expect(codec.decode("&b.alpha;")).to eq("&b.alpha;")
    end
  end

  context "with html4 flavor" do
    let(:codec) { HTMLEntities.new(:html4) }

    it_behaves_like "every codec"

    it "does not decode &apos;" do
      expect(codec.decode("&apos;")).to eq("&apos;")
    end

    it "skips entities from expanded set" do
      expect(codec.decode("&vdash;")).to eq("&vdash;")
      expect(codec.decode("&b.alpha;")).to eq("&b.alpha;")
    end
  end

  context "with expanded flavor" do
    let(:codec) { HTMLEntities.new(:expanded) }

    it_behaves_like "every codec"

    it "decodes &apos;" do
      expect(codec.decode("&apos;")).to eq("'")
    end

    it "decodes sgml entities" do
      expect(codec.decode("&nvdash;")).to eq("⊬")
      expect(codec.decode("&nsc;")).to eq("⊁")
      expect(codec.decode("&b.alpha;")).to eq("α")
      expect(codec.decode("&b.beta;")).to eq("β")
    end
  end
end

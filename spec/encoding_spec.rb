require_relative "spec_helper"

RSpec.describe "Encoding" do
  shared_examples "every codec" do
    it "encodes basic entities" do
      expect(codec.encode("&", :basic)).to eq("&amp;")
      expect(codec.encode("\"")).to eq("&quot;")
      expect(codec.encode("<", :basic)).to eq("&lt;")
      expect(codec.encode("<")).to eq("&lt;")
    end

    it "encodes basic entities to decimal" do
      expect(codec.encode("&", :decimal)).to eq("&#38;")
      expect(codec.encode("\"", :decimal)).to eq("&#34;")
      expect(codec.encode("<", :decimal)).to eq("&#60;")
      expect(codec.encode(">", :decimal)).to eq("&#62;")
      expect(codec.encode("'", :decimal)).to eq("&#39;")
    end

    it "encodes basic entities to hexadecimal" do
      expect(codec.encode("&", :hexadecimal)).to eq("&#x26;")
      expect(codec.encode("\"", :hexadecimal)).to eq("&#x22;")
      expect(codec.encode("<", :hexadecimal)).to eq("&#x3c;")
      expect(codec.encode(">", :hexadecimal)).to eq("&#x3e;")
      expect(codec.encode("'", :hexadecimal)).to eq("&#x27;")
    end

    it "encodes extended named entities" do
      expect(codec.encode("±", :named)).to eq("&plusmn;")
      expect(codec.encode("ð", :named)).to eq("&eth;")
      expect(codec.encode("Œ", :named)).to eq("&OElig;")
      expect(codec.encode("œ", :named)).to eq("&oelig;")
    end

    it "encodes decimal entities" do
      expect(codec.encode("“", :decimal)).to eq("&#8220;")
      expect(codec.encode("…", :decimal)).to eq("&#8230;")
    end

    it "encodes hexadecimal entities" do
      expect(codec.encode("−", :hexadecimal)).to eq("&#x2212;")
      expect(codec.encode("—", :hexadecimal)).to eq("&#x2014;")
    end

    it "encodes text using mix of entities" do
      expect(codec.encode("\"bientôt\" & 文字", :basic, :named, :hexadecimal))
        .to eq("&quot;bient&ocirc;t&quot; &amp; &#x6587;&#x5b57;")
      expect(codec.encode("\"bientôt\" & 文字", :basic, :named, :decimal))
        .to eq("&quot;bient&ocirc;t&quot; &amp; &#25991;&#23383;")
    end

    it "sorts commands when encoding using mix of entities" do
      expect(codec.encode("\"bientôt\" & 文字", :named, :hexadecimal, :basic))
        .to eq("&quot;bient&ocirc;t&quot; &amp; &#x6587;&#x5b57;")
      expect(codec.encode("\"bientôt\" & 文字", :decimal, :named, :basic))
        .to eq("&quot;bient&ocirc;t&quot; &amp; &#25991;&#23383;")
    end

    it "detects illegal encoding command" do
      expect { HTMLEntities.new.encode("foo", :bar, :baz) }
        .to raise_exception(HTMLEntities::InstructionError)
    end

    it "does not encode normal ASCII" do
      expect(codec.encode("`")).to eq("`")
      expect(codec.encode(" ")).to eq(" ")
    end

    it "doubles encode existing entity" do
      expect(codec.encode("&amp;")).to eq("&amp;amp;")
    end

    it "does not mutate string being encoded" do
      original = "<£"
      input = original.dup
      HTMLEntities.new.encode(input, :basic, :decimal)

      expect(input).to eq(original)
    end

    it "ducktypes parameter to string before encoding" do
      obj = Object.new
      def obj.to_s
        "foo"
      end
      expect(codec.encode(obj)).to eq("foo")
    end
  end

  context "with default flavor" do
    let(:codec) { HTMLEntities.new }

    it_behaves_like "every codec"

    it "encodes &apos;" do
      expect(codec.encode("'")).to eq("&apos;")
    end
  end

  context "with xhtml1 flavor" do
    let(:codec) { HTMLEntities.new(:xhtml1) }

    it_behaves_like "every codec"

    it "encodes &apos;" do
      expect(codec.encode("'")).to eq("&apos;")
    end
  end

  context "with html4 flavor" do
    let(:codec) { HTMLEntities.new(:html4) }

    it_behaves_like "every codec"

    it "does not encode &apos;" do
      expect(codec.encode("'")).to eq("'")
    end
  end

  context "with expanded flavor" do
    let(:codec) { HTMLEntities.new(:expanded) }

    it_behaves_like "every codec"

    it "encodes &apos;" do
      expect(codec.encode("'")).to eq("&apos;")
    end

    it "encodes ambiguous characters" do
      expect(codec.encode("α", :named)).to eq("&alpha;")
    end
  end
end

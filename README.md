HTMLEntities
============

The canonical source for this project can be found at GitHub:
[threedaymonk/htmlentities](https://github.com/threedaymonk/htmlentities).

HTML entity encoding and decoding for Ruby

HTMLEntities is a simple library to facilitate encoding and decoding of named
(`&yacute;` and so on) or numerical (`&#123;` or `&#x12a;`) entities in HTML
and XHTML documents.

## Usage

HTMLEntities works with UTF-8 (or ASCII) strings only.

Please ensure that your system is set to display UTF-8 before running these
examples. In Ruby 1.8, you'll need to set `$KCODE = "u"`.

### Decoding

```ruby
require 'htmlentities'
coder = HTMLEntities.new
string = "&eacute;lan"
coder.decode(string) # => "élan"
```

### Encoding

This is slightly more complicated, due to the various options. The encode
method takes a variable number of parameters, which tell it which instructions
to carry out.

```ruby
require 'htmlentities'
coder = HTMLEntities.new
string = "<élan>🤠"
```

Escape unsafe codepoints only:

```ruby
coder.encode(string) # => "&lt;élan&gt;🤠"
```

Or:

```ruby
coder.encode(string, :basic) # => "&lt;élan&gt;🤠"
```

Escape all entities that have names:

```ruby
coder.encode(string, :named) # => "&lt;&eacute;lan&gt;🤠"
```

Escape all non-ASCII/non-safe codepoints using decimal entities:

```ruby
coder.encode(string, :decimal) # => "&#60;&#233;lan&#62;&#129312;"
```

As above, using hexadecimal entities:

```ruby
coder.encode(string, :hexadecimal) # => "&#x3c;&#xe9;lan&#x3e;&#x1f920;"
```

You can also use several options, e.g. use named entities for unsafe codepoints, then decimal for all other non-ASCII:

```ruby
coder.encode(string, :basic, :decimal) # => "&lt;&#233;lan&gt;&#129312;"
```

You can also restrict encoding to four-byte characters (like emojis):

```ruby
coder.encode(string, :hexadecimal, :four_byte) # => "<élan>&#x1f920;"
```

### Flavours

HTMLEntities knows about three different sets of entities:

* `:xhtml1` – Entities from the XHTML1 doctype
* `:html4` – Entities from the HTML4 doctype. Differs from +xhtml1+ only by the absence of +&apos+
* `:expanded` – Entities from a variety of SGML sets

The default is `:xhtml`, but you can override this:

```ruby
coder = HTMLEntities.new(:expanded)
```

## Licence

This code is free to use under the terms of the MIT licence. See the file
COPYING.txt for more details.

## Contact

Send email to `pbattley@gmail.com`.

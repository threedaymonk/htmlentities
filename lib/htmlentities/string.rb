require 'htmlentities'

#
# This library extends the String class with methods to allow encoding and decoding of
# HTML/XML entities from/to their corresponding UTF-8 codepoints.
#
class String

  def decode_entities
    return HTMLEntities.decode_entities(self)
  end
  
  def encode_entities(*instructions)
    return HTMLEntities.encode_entities(self, *instructions)
  end

end
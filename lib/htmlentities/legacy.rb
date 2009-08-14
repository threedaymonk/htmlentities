class HTMLEntities
  class << self

    #
    # Legacy compatibility class method allowing direct encoding of XHTML1 entities.
    # See HTMLEntities#encode for description of parameters.
    #
    # Deprecated.
    #
    def encode_entities(*args)
      xhtml1_entities.encode(*args)
    end

    #
    # Legacy compatibility class method allowing direct decoding of XHTML1 entities.
    # See HTMLEntities#decode for description of parameters.
    #
    # Deprecated.
    #
    def decode_entities(*args)
      xhtml1_entities.decode(*args)
    end

  private

    def xhtml1_entities
      @xhtml1_entities ||= new('xhtml1')
    end

  end
end

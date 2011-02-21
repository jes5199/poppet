module Poppet
  class Implementor
    class Reader
      def initialize(&blk)
        @rules = instance_eval( &blk )
      end

      def attribute( name )
        [ "attribute", name,
          yield
        ]
      end

      def read( &blk )
        [ "read", lambda( &blk ) ]
      end

      def literal( val )
        [ "literal", val ]
      end

      def within( val )
        [ "within", val, yield ]
      end

    end
  end
end

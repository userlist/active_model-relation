module ActiveModel
  class Relation
    class WhereClause
      attr_reader :predicates

      class Predicate
        def call(record)
          raise NotImplementedError
        end

        def invert
          NotPredicate.new(self)
        end
      end

      class EqualsPredicate < Predicate
        attr_reader :attribute, :value

        def initialize(attribute, value)
          @attribute = attribute
          @value = value
        end

        def call(record)
          record.public_send(attribute) == value
        end
      end

      class BlockPredicate < Predicate
        attr_reader :block

        def initialize(block)
          @block = block
        end

        def call(record)
          block.call(record)
        end
      end

      class NotPredicate < Predicate
        attr_reader :predicate

        def initialize(predicate)
          @predicate = predicate
        end

        def call(record)
          !predicate.call(record)
        end

        def invert
          predicate
        end
      end

      def self.from_hash(attributes = {})
        new(attributes.map { |attribute, value| EqualsPredicate.new(attribute, value) })
      end

      def self.from_block(block)
        new(BlockPredicate.new(block))
      end

      def initialize(*predicates)
        @predicates = predicates.flatten(1)
      end

      def +(other)
        WhereClause.new(predicates + other.predicates)
      end

      def call(record)
        predicates.all? { |predicate| predicate.call(record) }
      end

      def invert
        WhereClause.new(predicates.map(&:invert))
      end

      def to_proc
        ->(record) { call(record) }
      end
    end
  end
end

module ActiveModel
  class Relation
    class WhereChain
      attr_reader :relation

      def initialize(relation)
        @relation = relation
      end

      def not(attributes = {}, &block)
        where_clause = WhereClause.from_hash(attributes)
        where_clause += WhereClause.from_block(block) if block_given?

        relation.where_clause += where_clause.invert
        relation
      end
    end
  end
end

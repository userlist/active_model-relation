module ActiveModel
  class Relation
    class WhereChain
      attr_reader :relation

      def initialize(relation)
        @relation = relation
      end

      def not(...)
        relation.where_clause += WhereClause.build(...).invert
        relation
      end
    end
  end
end

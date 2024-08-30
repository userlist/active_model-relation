module ActiveModel
  class Relation
    module Model
      extend ActiveSupport::Concern

      include ActiveModel::Relation::Scoping
      include ActiveModel::Relation::Querying

      module ClassMethods
        def load(records)
          self.current_scope = ActiveModel::Relation.new(self, records)
        end
      end
    end
  end
end

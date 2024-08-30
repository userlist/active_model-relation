module ActiveModel
  class Relation
    module Querying
      extend ActiveSupport::Concern

      module ClassMethods
        delegate :where, :find, :find_by, :offset, :limit, to: :all

        def all
          current_scope || ActiveModel::Relation.new(self, records)
        end
      end
    end
  end
end

module ActiveModel
  class Relation
    module Querying
      extend ActiveSupport::Concern

      module ClassMethods
        delegate :where, :find, :find_by, :offset, :limit, :first, :last, to: :all

        def all
          current_scope || ActiveModel::Relation.new(self, records)
        end

        def records
          raise NotImplementedError
        end
      end
    end
  end
end

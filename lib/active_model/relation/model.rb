module ActiveModel
  class Relation
    module Model
      extend ActiveSupport::Concern

      include ActiveModel::Relation::Scoping
      include ActiveModel::Relation::Querying

      included do
        class_attribute :records, instance_accessor: false
      end

      module ClassMethods
        def load(records)
          self.records = records

          all
        end
      end
    end
  end
end

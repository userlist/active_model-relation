# frozen_string_literal: true

module ActiveModel
  class Relation
    module Scoping
      extend ActiveSupport::Concern

      module ClassMethods
        def current_scope
          Registry.scopes[name]
        end

        def current_scope=(value)
          Registry.scopes.store(name, value)
        end
      end

      class Registry
        def self.scopes
          ActiveSupport::IsolatedExecutionState[:active_model_relation_scope_registry] ||= {}
        end
      end
    end
  end
end

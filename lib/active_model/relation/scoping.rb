# frozen_string_literal: true

module ActiveModel
  class Relation
    module Scoping
      extend ActiveSupport::Concern

      module ClassMethods
        def current_scope
          ScopeRegistry.current_scope(self)
        end

        def current_scope=(value)
          ScopeRegistry.set_current_scope(self, value)
        end
      end

      class ScopeRegistry
        class << self
          delegate :current_scope, :set_current_scope, to: :instance

          def instance
            ActiveSupport::IsolatedExecutionState[:active_model_scope_registry] ||= new
          end
        end

        def initialize
          @current_scope = {}
        end

        def current_scope(model)
          @current_scope[model.name]
        end

        def set_current_scope(model, value)
          @current_scope[model.name] = value
        end
      end
    end
  end
end

# frozen_string_literal: true

require 'rails'

module ActiveModel
  class Relation
    class Railtie < Rails::Railtie # :nodoc:
      config.action_dispatch.rescue_responses.merge!(
        'ActiveModel::RecordNotFound' => :not_found
      )
    end
  end
end

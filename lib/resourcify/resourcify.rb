require "resourcify/model/filter"
require "resourcify/model/policy_class"
require "resourcify/controller/base"
require "resourcify/controller/actions/index"
require "resourcify/controller/actions/create"
require "resourcify/controller/actions/show"
require "resourcify/controller/actions/update"
require "resourcify/controller/actions/destroy"

module Resourcify
  module Resourcify
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
      def resourcify(options = {})
        # Class method to tag classes using this plugin
        def resourcified?() true end
        
        if self.ancestors.include?(ActiveRecord::Base)        # models
          # Include filter and tag as filterable?
          send :extend,  Model::Filter
          def filterable?() true end

          # Add policy_class method for pundit
          send :extend,  Model::PolicyClass

          # Include instance methods
          send :include, ModelInstanceMethods
        elsif self.ancestors.include?(ActionController::Base) # controllers
          # Turn off layout
          layout false

          # Respond to only json requests
          respond_to :json
          
          # Set before_actions with methods located in base.rb
          before_action :set_response_data
          before_action :set_record, only: [:show, :update, :destroy]
          
          # Set rescue_froms with methods located in base.rb
          rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
          rescue_from Pundit::NotAuthorizedError,   with: :user_not_authorized
          rescue_from UndefinedError, with: :resource_not_resourcified

          # Include base.rb with before_action filters & rescue_from methods
          send :include, Controller::Base

          # Include RESTful actions
          send :include, Controller::Actions::Index
          send :include, Controller::Actions::Create
          send :include, Controller::Actions::Show
          send :include, Controller::Actions::Update
          send :include, Controller::Actions::Destroy
        end
      end
    end

    module ModelInstanceMethods
      def policy_class
        self.class.policy_class
      end
    end
  end
end

ActiveRecord::Base.send :include, Resourcify::Resourcify
ActionController::Base.send :include, Resourcify::Resourcify
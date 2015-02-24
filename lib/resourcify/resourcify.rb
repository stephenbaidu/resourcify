require "resourcify/model/tpl"
require "resourcify/model/filter_by"
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
          # Add tpl methods
          send :extend,  Model::Tpl

          # Add policy_class method for pundit
          send :extend,  Model::PolicyClass

          # Include filter_by
          send :extend,  Model::FilterBy

          # Include instance methods
          send :include, ModelInstanceMethods

          # Set options
          cattr_accessor :resourcify_options
          self.resourcify_options = options

          options.each do |key, val|
            cattr_accessor "resourcify_#{key.to_s}".to_sym
            self.send("resourcify_#{key.to_s}=", val)

            cattr_accessor "rfy_#{key.to_s}".to_sym
            self.send("rfy_#{key.to_s}=", val)
          end

        elsif self.ancestors.include?(ActionController::Base) # controllers
          # Turn off layout
          layout false

          # Respond to only json requests
          respond_to :json
          
          # Set error with set_error method located in base.rb
          before_action :set_error

          # Set record with set_record method located in base.rb
          before_action :set_record, only: [:show, :update, :destroy]
          
          # Set rescue_froms with methods located in base.rb
          rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
          rescue_from Pundit::NotAuthorizedError,   with: :user_not_authorized

          # Include base.rb with before_action filters & rescue_from methods
          send :include, Controller::Base

          # Include RESTful actions
          if !options[:actions] || options[:actions].include?(:index)
            send :include, Controller::Actions::Index
          end

          if !options[:actions] || options[:actions].include?(:create)
            send :include, Controller::Actions::Create
          end

          if !options[:actions] || options[:actions].include?(:show)
            send :include, Controller::Actions::Show
          end

          if !options[:actions] || options[:actions].include?(:update)
            send :include, Controller::Actions::Update
          end

          if !options[:actions] || options[:actions].include?(:destroy)
            send :include, Controller::Actions::Destroy
          end
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
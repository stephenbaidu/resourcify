module Controller
  module Base
    require 'active_record/serializer_override'
    ActiveRecord::Base.send(:include, ActiveRecord::SerializerOverride)

    include Pundit

    private
      # Set JSON response data
      def set_response_data
        @response_data = { 
          success: false,
          data: { total: 0, rows: [] },
          error: { type: '', errors: {}, messages: [] } 
        }
        # raise Resourcify::UndefinedError unless _RC.respond_to? 'resourcified?'
      end
   
      # def resource_not_resourcified
      #   @response_data[:success] = false
      #   @response_data[:error]   = { 
      #     type: 'resource_not_resourcified',
      #     messages: [ 'Resourcify::UndefinedError. Resource route not defined' ]
      #   }
        
      #   render json: @response_data
      # end
   
      def record_not_found
        @response_data[:success] = false
        @response_data[:error]   = { 
          type: 'record_not_found',
          messages: [ 'Sorry, the record was not found.' ]
        }
        
        render json: @response_data
      end
   
      def user_not_authorized
        @response_data[:success] = false
        @response_data[:error]   = { 
          type: 'user_not_authorized',
          messages: [ 'Sorry, you do not have the permission.' ]
        }
        
        render json: @response_data
      end

      def _RC
        controller_name.classify.constantize
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_record
        @record = _RC.includes(belongs_tos).find(params[:id])
      end

      def belongs_tos
        _RC.reflect_on_all_associations(:belongs_to).map {|e| e.name }
      end

      # Only allow a trusted parameter "white list" through.
      def permitted_params
        if self.respond_to? "#{controller_name.singularize}_params", true
          self.send("#{controller_name.singularize}_params")
        else
          param_key        = _RC.name.split('::').last.singularize.underscore.to_sym
          excluded_fields  = ["id", "created_at", "updated_at"]
          permitted_fields = (_RC.column_names - excluded_fields).map { |f| f.to_sym }
          params.fetch(param_key, {}).permit([]).tap do |wl|
            permitted_fields.each { |f| wl[f] = params[param_key][f] if params[param_key].key?(f) }
          end
        end
      end
  end
end
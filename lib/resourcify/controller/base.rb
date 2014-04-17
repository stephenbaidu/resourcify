module Controller
  module Base

    include Pundit

    private
      # Set error response data
      def set_error
        @error = {
          error: true,
          type: 'Error',
          message: 'Sorry, an error occurred.'
        }
      end
   
      def record_not_found
        @error[:type]    = 'RecordNotFound'
        @error[:message] = 'Sorry, the record was not found.'
        
        render json: @error
      end
   
      def user_not_authorized
        @error[:type]    = 'UserNotAuthorized'
        @error[:message] = 'Sorry, you do not have the permission.'
        
        render json: @error
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
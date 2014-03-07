module Controller::Actions
  module Update
    def update
      authorize @record

      if @record.update(permitted_params)
        @response_data[:success] = true
        @response_data[:data]    = @record
      else
        @response_data[:error]   = {
          type: 'validation',
          errors: @record.errors.messages,
          messages: @record.errors.full_messages
        }
      end

      render json: @response_data
    end
  end
end
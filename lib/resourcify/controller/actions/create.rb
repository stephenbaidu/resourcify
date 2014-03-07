module Controller::Actions
  module Create
    def create
      @record = _RC.new(permitted_params)

      authorize @record

      if @record.save
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
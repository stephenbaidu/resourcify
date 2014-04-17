module Controller::Actions
  module Create
    def create
      @record = _RC.new(permitted_params)

      authorize @record

      if @record.save
        render json: @record
      else
        @error[:type]     = 'Validation'
        @error[:message]  = 'Sorry, there were validation errors.'
        @error[:errors]   = @record.errors.messages
        @error[:messages] = @record.errors.full_messages

        render json: @error
      end
    end
  end
end
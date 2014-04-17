module Controller::Actions
  module Update
    def update
      authorize @record

      if @record.update(permitted_params)
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
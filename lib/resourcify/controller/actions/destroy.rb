module Controller::Actions
  module Destroy
    def destroy
      authorize @record

      if @record.destroy
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
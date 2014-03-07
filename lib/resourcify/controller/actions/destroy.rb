module Controller::Actions
  module Destroy
    def destroy
      authorize @record

      if @record.destroy
        @response_data[:success] = true
        @response_data[:data]    = @record
      else
        @response_data[:error]   = {
          type: 'other',
          errors: @record.errors.messages,
          messages: @record.errors.full_messages
        }
      end

      render json: @response_data
    end
  end
end
module Controller::Actions
  module Show
    def show
      authorize @record

      @response_data[:success] = true
      @response_data[:data]    = @record

      render json: @response_data
    end
  end
end
module Controller::Actions
  module Show
    def show
      authorize @record
      
      render json: @record
    end
  end
end
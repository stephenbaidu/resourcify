module Controller::Actions
  module Index
    def index
      authorize _RC.new

      recs = policy_scope(_RC.all)

      # apply filter if query is present
      recs = recs.filter(params[:query]) if params[:query].present?

      recs_total = recs.count

      page = params[:page] || 1
      size = params[:size] || 25
      recs = recs.offset((page.to_i - 1) * size.to_i).limit(size)

      if recs
        @response_data[:success] = true
        @response_data[:data]    = {
          total: recs_total,
          rows:  recs
        }
      end

      render json: @response_data
    end
  end
end
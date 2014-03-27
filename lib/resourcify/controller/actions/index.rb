module Controller::Actions
  module Index
    def index
      authorize _RC.new

      # recs = policy_scope(_RC.all)
      recs = policy_scope(_RC.includes(belongs_tos))
      # recs = policy_scope(_RC.includes([]).all)

      # apply resourcify_filter if present and query param is also present
      if recs.respond_to? "resourcify_filter" and params[:query].present?
        recs = recs.resourcify_filter(params[:query])
      end

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
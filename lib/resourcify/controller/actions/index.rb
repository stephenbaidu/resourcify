module Controller::Actions
  module Index
    def index
      authorize _RC.new
      
      @records = _RC.includes(belongs_tos)

      # apply filter_by if present
      if @records.respond_to? "filter_by"
        @records = @records.filter_by(params.except(:controller, :action, :page, :size))
      end

      @records = policy_scope(@records)
      
      response.headers['_meta_total'] = @records.count.to_s

      page = params[:page] || 1
      size = params[:size] || 20
      @records = @records.offset((page.to_i - 1) * size.to_i).limit(size)

      render json: @records
    end
  end
end
module Model
  module FilterBy
    def filter_by(filters = {})
      records = self
      column_names = self.column_names
      simple_ops = { eq: '=', lt: '<', gt: '>', lte: '<=', gte: '>=' }
      filters.select { |e| column_names.include?(e.split('.').first) }.each do |key, value|
        next if value.blank?
        
        field, operator = key.split('.')
        operator = (operator)? operator.to_sym : :eq

        if simple_ops[operator]
          records = records.where("#{field} #{simple_ops[operator]} ?", value)
        elsif operator == :ne
          records = records.where.not("#{field} = ?", value)
        elsif operator == :in
          records = records.where("#{field} IN (?)", value.split(','))
        elsif operator == :nin
          records = records.where.not("#{field} IN (?)", value.split(','))
        elsif operator == :like
          if ActiveRecord::Base.connection.adapter_name == "PostgreSQL"
            records = records.where("#{field} ILIKE ?", "%#{value}%")
          else
            records = records.where("#{field} LIKE ?", "%#{value}%")
          end
        else
          records = records.where("#{field} = ?", value)
        end
      end
      
      records
    end
  end
end
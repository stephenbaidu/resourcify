module Model
  module ResourcifyFilter
    def resourcify_filter(filter_string)
      records = self
      simple_ops = { eq: '=', lt: '<', gt: '>', lte: '<=', gte: '>=' }
      filter_string = filter_string.split(';;').map { |q| q.split('::') }
      filter_string = filter_string.map { |q| {name: q[0], op: q[1], value: q[2], type: q[3]} }
      filter_string = filter_string.select { |f| self.column_names.include?(f[:name]) }

      filter_string.each do |f|
        next if f[:value].blank?

        operand = f[:op].to_s.to_sym
        
        if simple_ops[operand]
          f[:value] = f[:value].to_time if f[:type] == "date"
          records = records.where("#{f[:name]} #{simple_ops[operand]} ?", f[:value])
        elsif operand == :like
          if ActiveRecord::Base.connection.adapter_name == "PostgreSQL"
            records = records.where("#{f[:name]} ILIKE ?", "%#{f[:value]}%")
          else
            records = records.where("#{f[:name]} LIKE ?", "%#{f[:value]}%")
          end
        elsif operand == :ne
          records = records.where.not("#{f[:name]} = ?", f[:value])
        elsif operand == :in
          records = records.where("#{f[:name]} IN (?)", f[:value].split(','))
        elsif operand == :nin
          records = records.where.not("#{f[:name]} IN (?)", f[:value].split(','))
        end
      end

      records
    end
  end
end
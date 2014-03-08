module Model
  module Filter
    def filter(filters)
      records = self
      simple_ops = { eq: '=', lt: '<', gt: '>', lteq: '<=', gteq: '>=' }
      filters = filters.split(';;').map { |q| q.split('::') }
      filters = filters.map { |q| {name: q[0], op: q[1], value: q[2], type: q[3]} }
      filters = filters.select { |f| self.column_names.include?(f[:name]) }

      filters.each do |f|
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
        elsif operand == :in
          records = records.where("#{f[:name]} IN (?)", f[:value].split(','))
        elsif operand == :notin
          records = records.where.not("#{f[:name]} IN (?)", f[:value].split(','))
        end
      end

      records
    end
  end
end
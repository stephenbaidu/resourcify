module Model
  module FilterBy
    def filter_by(filters = {})
      records = self
      columns_hash = self.columns_hash

      def sanitize_value(field, value)
        field_type = columns_hash[field].type
        if field_type == :datetime
          value = Time.parse(value).to_s(:db)
        elsif field_type == :date
          value = Date.parse(value).to_s(:db)
        end
        value
      end
      
      def query_params(q)
        ops = { eq: '=', lt: '<', gt: '>', lte: '<=', gte: '>=', ne: '!='}
        field, op, value = q[:name], (q[:op] || 'eq').to_sym, q[:value]

        if ops[op]
          ["#{field} #{ops[op]} ?", sanitize_value(field, value)]
        elsif op == :in
          vals = value.split(',')
          vals = vals.map { |e| sanitize_value(field, e) }
          ["#{field} IN (?)", vals]
        elsif op == :nin
          vals = value.split(',')
          vals = vals.map { |e| sanitize_value(field, e) }
          ["#{field} NOT IN (?)", vals]
        elsif op == :between
          vals = value.split('||')
          query_string = '(' + vals.map { |e| "(#{field} >= ? AND #{field} <= ?)" }.join(' OR ') + ')'
          vals = vals.map { |e| e.split('|') }.flatten
          vals = vals.map { |e| sanitize_value(field, e) }
          vals.unshift(query_string)
          vals
        elsif op == :like
          like_key = (ActiveRecord::Base.connection.adapter_name == "PostgreSQL")? 'ILIKE' : 'LIKE'
          vals = value.split('|').map { |val| "%#{val}%" }
          query_string = '(' + vals.map { |e| "#{field} #{like_key} ?" }.join(' OR ') + ')'
          vals.unshift(query_string)
          vals
        else
          ["#{field} = ?", sanitize_value(field, value)]
        end
      end

      filters.map do |key, value|
        name, op = key.to_s.split('.')
        { name: name, op: op, value: value }
      end.group_by do |q|
        q[:name]
      end.select do |key|
        columns_hash.include? key
      end.map do |key, value|
        qparams = value.map { |e| query_params(e) }
        qstring = qparams.map { |e| e.first }.join(' OR ')
        qparams.map { |e| e[1..-1] }.flatten(1).unshift(qstring)
      end.each do |qparam|
        records = records.where(*qparam)
      end
      
      records
    end
  end
end
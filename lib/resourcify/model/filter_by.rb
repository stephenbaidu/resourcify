module Model
  module FilterBy
    def filter_by(filters = {})
      records = self
      column_names = self.column_names
      
      def query_params(q)
        ops = { eq: '=', lt: '<', gt: '>', lte: '<=', gte: '>=', ne: '!='}
        field, op, value = q[:name], (q[:op] || 'eq').to_sym, q[:value]

        if ops[op]
          ["#{field} #{ops[op]} ?", value]
        elsif op == :in
          ["#{field} IN (?)", value.split(',')]
        elsif op == :nin
          ["#{field} NOT IN (?)", value.split(',')]
        elsif op == :between
          vals = value.split('||')
          query_string = '(' + vals.map { |e| "(#{field} >= ? AND #{field} <= ?)" }.join(' OR ') + ')'
          vals = vals.map { |e| e.split('|') }.flatten
          vals.unshift(query_string)
          vals
        elsif op == :like
          like_key = (ActiveRecord::Base.connection.adapter_name == "PostgreSQL")? 'ILIKE' : 'LIKE'
          vals = value.split('|').map { |val| "%#{val}%" }
          query_string = '(' + vals.map { |e| "#{field} #{like_key} ?" }.join(' OR ') + ')'
          vals.unshift(query_string)
          vals
        else
          ["#{field} = ?", value]
        end
      end

      filters.map do |key, value|
        name, op = key.to_s.split('.')
        { name: name, op: op, value: value }
      end.group_by do |q|
        q[:name]
      end.select do |key|
        column_names.include? key
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
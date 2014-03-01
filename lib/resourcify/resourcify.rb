module Resourcify
  module Resourcify
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
      def resourcify(options = {})
        # ...
        send :extend,  LocalClassMethods
        send :include, LocalInstanceMethods
      end
    end

    module LocalClassMethods
      def resourcified?
        true
      end

      def policy_class
        _p = "#{self.name}Policy" and _p.constantize and return _p
      rescue
        "ApiPolicy"
      end

      def filter(filters)
        records = self
        simple_ops = { eq: '=', lt: '<', gt: '>', lteq: '<=', gteq: '>=' }
        filters = filters.split(';;').map { |q| q.split('::') }
        filters = filters.map { |q| {name: q[0], op: q[1], value: q[2], type: q[3]} }
        filters = filters.select { |f| self.column_names.include?(f[:name]) }

        filters.each do |f|
          next if f[:value].empty?

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

    module LocalInstanceMethods
      def policy_class
        self.class.policy_class
      end
    end
  end
end

ActiveRecord::Base.send :include, Resourcify::Resourcify
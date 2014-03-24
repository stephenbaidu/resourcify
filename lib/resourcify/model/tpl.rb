module Model
  module Tpl
    class ResourcifyTpl < Struct.new(:model_class)

      def columns
        fields = []
        foreign_keys = self.model_class.reflections.each_with_object({}) {|(k, v), h| h[v.foreign_key] = v.name.to_s }

        self.model_class.columns.each do |c|
          f = { name: c.name, type: c.type.to_s, label: c.name.titleize }
          if foreign_keys.keys.include?(c.name)
            f[:lookup] = foreign_keys[c.name]
            f[:label]  = c.name[0, c.name.length - 3].titleize if c.name.ends_with?("_id")
            if foreign_keys[c.name] == 'children'
              f[:lookup] = :parent
              f[:label]  = "Parent #{self.model_class.name.singularize.titleize}"
            end
          end
          fields.push f
        end

        fields
      rescue Exception => e
        []
      end

      def lookups
        if _tpl = method_exists?('lookups')
          return _tpl.new.lookups
        end

        lookups = {}
        model_class.reflect_on_all_associations(:belongs_to).each do |association|
          if association.name == "parent"
            lookups[:parent] = association.klass.all
            lookups[:parent].unshift(association.klass.new(id: nil, name: 'N/A'))
          else
            lookups[association.name.to_sym] = association.klass.all.map { |e| {id: e.id, name: e.name} }
          end
        end

        lookups
      rescue Exception => e
        {}
      end

      def form_columns
        if _tpl = method_exists?('form_columns')
          return _tpl.new.form_columns
        end

        excluded_fields  = ["id", "created_at", "updated_at", "lft", "rgt", "depth"]
        fields = self.columns.select { |e| !excluded_fields.include? e[:name] }

      rescue Exception => e
        []
      end

      def grid_columns
        if _tpl = method_exists?('grid_columns')
          return _tpl.new.grid_columns
        end

        excluded_fields  = ["id", "created_at", "updated_at", "lft", "rgt", "depth"]
        fields = self.columns.select { |e| !excluded_fields.include? e[:name] }

      rescue Exception => e
        []
      end

      def options
        if _tpl = method_exists?('options')
          return _tpl.new.options
        end
        {}
      rescue
        {}
      end

      def filters
        if _tpl = method_exists?('filters')
          return _tpl.new.filters
        end
        {}
      rescue
        {}
      end

      private
        def method_exists?(method)
          _tpl = "#{model_class.name}Tpl".constantize

          if _tpl.new.respond_to?(method)
            _tpl
          else
            false
          end
        rescue
          false
        end
    end

    def tpl
      ResourcifyTpl.new(self)
    end
  end
end
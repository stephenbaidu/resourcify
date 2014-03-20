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
              f[:label]  = "Parent #{model.singularize.titleize}"
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
        associations = model_class.reflect_on_all_associations(:belongs_to).map { |a| a.name }
        associations.each do |assoc|
          if assoc.to_s == "parent"
            lookups[:parent] = model_class.all
            lookups[:parent].unshift(model_class.new(id: nil, name: 'N/A'))
          else
            lookups[assoc.to_s.to_sym] = getmodel_class(assoc).all
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
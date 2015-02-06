module Pms
  module Acts
    module Customizable
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def acts_as_customizable(options = {})
          return if self.included_modules.include?(Pms::Acts::Customizable::InstanceMethods)
          cattr_accessor :customizable_options
          self.customizable_options = options
          has_many :custom_values, lambda { includes(:custom_field).order("#{CustomField.table_name}.position") },
                   :as => :customized,
                   :dependent => :delete_all,
                   :validate => false
          send :include, Pms::Acts::Customizable::InstanceMethods
          validate :validate_custom_field_values
          # after_save :save_custom_field_values
        end
      end

      module InstanceMethods
        def self.included(base)
          base.extend ClassMethods
          base.send :alias_method_chain, :reload, :custom_fields
        end

        def method_missing(method_name, *args, &block)
          if /value_\w+/.match(method_name.to_s)
            custom_field_values.detect { |v| v.custom_field.name.downcase== method_name.to_s.sub(/custom_/, '') }.try(:value)
          elsif /field_\w+/.match(method_name.to_s)
            available_custom_fields.detect { |f| f.name==method_name.to_s.sub(/field_/, '') }
          else
            super
          end
        end

        def available_custom_fields
          @available_custom_fields ||= CustomField.where("type = '#{self.custom_field_type}'").sorted.to_a
        end

        # Sets the values of the object's custom fields
        # values is an array like [{'id' => 1, 'value' => 'foo'}, {'id' => 2, 'value' => 'bar'}]
        def custom_fields=(values)
          values_to_hash = values.inject({}) do |hash, v|
            v = v.stringify_keys
            if v['id'] && v.has_key?('value')
              hash[v['id']] = v['value']
            end
            hash
          end
          self.custom_field_values = values_to_hash
        end

        # Sets the values of the object's custom fields
        # values is a hash like {'1' => 'foo', 2 => 'bar'}
        def custom_field_values=(values)
          values = values.stringify_keys

          custom_field_values.each do |custom_field_value|
            key = custom_field_value.custom_field_id.to_s
            if values.has_key?(key)
              value = values[key]
              if value.is_a?(Array)
                value = value.reject(&:blank?).map(&:to_s).uniq
                if value.empty?
                  value << ''
                end
              else
                value = value.to_s
              end
              custom_field_value.value = value
            end
          end
          @custom_field_values_changed = true
        end

        def custom_field_values
          @custom_field_values ||= available_custom_fields.collect do |field|
            x = CustomFieldValue.new
            x.custom_field = field
            x.customized = self
            if field.multiple?
              values = custom_values.select { |v| v.custom_field == field }
              if values.empty?
                values << custom_values.build(:customized => self, :custom_field => field, :value => nil)
              end
              x.value = values.map(&:value)
            else
              cv = custom_values.detect { |v| v.custom_field == field }
              cv ||= custom_values.build(:customized => self, :custom_field => field, :value => nil)
              x.value = cv.value
            end
            x.value_was = x.value.dup if x.value
            x
          end
        end

        def visible_custom_field_values
          custom_field_values.select(&:visible?)
        end

        def custom_field_values_changed?
          @custom_field_values_changed == true
        end

        def custom_value_for(c)
          field_id = (c.is_a?(CustomField) ? c.id : c.to_i)
          custom_values.detect { |v| v.custom_field_id == field_id }
        end

        def custom_field_value(c)
          field_id = (c.is_a?(CustomField) ? c.id : c.to_i)
          custom_field_values.detect { |v| v.custom_field_id == field_id }.try(:value)
        end

        def validate_custom_field_values
          if new_record? || custom_field_values_changed?
            custom_field_values.each(&:validate_value)
          end
        end

        def save_custom_field_values
          target_custom_values = []
          custom_field_values.each do |custom_field_value|
            if custom_field_value.value.is_a?(Array)
              custom_field_value.value.each do |v|
                target = custom_values.detect { |cv| cv.custom_field == custom_field_value.custom_field && cv.value == v }
                target ||= custom_values.build(:customized => self, :custom_field => custom_field_value.custom_field, :value => v)
                target_custom_values << target
              end
            else
              target = custom_values.detect { |cv| cv.custom_field == custom_field_value.custom_field }
              target ||= custom_values.build(:customized => self, :custom_field => custom_field_value.custom_field)
              target.value = custom_field_value.value
              target_custom_values << target
            end
          end
          self.custom_values = target_custom_values
          custom_values.each(&:save)
          @custom_field_values_changed = false
          true
        end

        def reset_custom_values!
          @custom_field_values = nil
          @custom_field_values_changed = true
        end

        def reload_with_custom_fields(*args)
          @custom_field_values = nil
          @custom_field_values_changed = false
          reload_without_custom_fields(*args)
        end

        module ClassMethods
        end
      end
    end
  end
end

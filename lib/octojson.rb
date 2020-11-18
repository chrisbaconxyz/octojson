require 'active_record'

module ActiveRecord
  module Octojson
    extend ActiveSupport::Concern

    class_methods do
      def octojson(json_attribute, schema, schema_key = nil)      
        schema.each do |attribute,data|
          data.each do |key,value|
            define_method(attribute_name(json_attribute, attribute, key)) do 
              self[json_attribute][key.to_s]
            end

            if value[:validates]
              validates attribute_name(json_attribute, attribute, key), value[:validates].merge(if: -> { apply_validatation?(schema_key, attribute) })
            end
          end
        end

        after_initialize do 
          if new_record? && has_attribute?(json_attribute) && schema_key_value(schema, schema_key)
            field_types = schema[schema_key_value(schema, schema_key).to_sym]
            write_attributes(json_attribute, field_types) unless field_types.nil? 
          end
        end

        before_validation do
          if has_attribute?(json_attribute) && schema_key_value(schema, schema_key)
            field_types = schema[schema_key_value(schema, schema_key).to_sym]
            write_attributes(json_attribute, field_types) unless field_types.nil? 
          end
        end

        define_method("#{json_attribute}_strong_params") do 
          if has_attribute?(json_attribute) && schema_key_value(schema, schema_key)
            field_types = schema[schema_key_value(schema, schema_key).to_sym]
            
            return nil if field_types.nil?
            
            field_types.map do |k,v|
              nestable?(v) ? { k => v[:nested_attributes] } : k
            end
          end
        end
      end

      private

      def attribute_name(json_attribute, attribute, key)
        return "#{json_attribute}_#{key}" if attribute == "_default"
        "#{json_attribute}_#{attribute}_#{key}"
      end
    end

    private

    def apply_validatation?(schema_key, attribute)
      return true if attribute.to_s == "_default"
      send(schema_key.to_s) == attribute.to_s
    end

    def schema_key_value(schema, schema_key)
      return "_default" if schema[:_default].present?
      instance_eval(schema_key.to_s)
    end

    def write_attributes(json_attribute, field_types)
      if self.send("#{json_attribute}_changed?") && !self.send("#{json_attribute}_change")[0].blank?
        self[json_attribute] = self.send("#{json_attribute}_change")[0].merge(self[json_attribute])
      end

      self[json_attribute] = {} if self[json_attribute].blank?
      new_settings = {}
      field_types.each do |key,value|
        if self[json_attribute][key.to_s] == nil
          new_settings[key] = value[:default]
        else
          if nestable?(value)
            self[json_attribute][key.to_s].each do |o|
              o.each do |k,v|
                o.delete(k) if value[:nested_attributes].exclude?(k.to_sym)
              end
            end
          end
          
          new_settings[key] = self[json_attribute][key.to_s]        
        end
      end

      self[json_attribute] = new_settings
    end

    def nestable?(value)
      value[:type] == :array || value[:type] == :json
    end
  end
end

ActiveRecord::Base.include(ActiveRecord::Octojson)

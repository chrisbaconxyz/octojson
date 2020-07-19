require 'active_record'

module ActiveRecord
  module Octojson
    extend ActiveSupport::Concern

    class_methods do
      def octojson(json_attribute, schema, schema_key)      
        schema.each do |attribute,data|
          data.each do |key,value|
            define_method("#{json_attribute}_#{attribute}_#{key}") do 
              self[json_attribute][key.to_s]
            end

            if value[:validates]
              validates "#{json_attribute}_#{attribute}_#{key}", value[:validates].merge(if: -> { send(schema_key.to_s) == attribute.to_s })
            end
          end
        end

        after_initialize do 
          if new_record? && has_attribute?(json_attribute) && instance_eval(schema_key.to_s)
            field_types = schema[instance_eval(schema_key.to_s).to_sym]
            write_attributes(json_attribute, field_types) unless field_types.nil?
          end
        end

        before_validation do
          if has_attribute?(json_attribute) 
            field_types = schema[instance_eval(schema_key.to_s).to_sym]
            write_attributes(json_attribute, field_types) unless field_types.nil?
          end
        end

        define_method("#{json_attribute}_strong_params") do 
          if has_attribute?(json_attribute)
            field_types = schema[instance_eval(schema_key.to_s).to_sym]
            
            return nil if field_types.nil?
            
            field_types.map do |k,v|
              v[:type] == :json ? { k => v[:nested_attributes] } : k
            end
          end
        end
      end
    end

    private

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
          new_settings[key] = self[json_attribute][key.to_s]        
        end
      end

      self[json_attribute] = new_settings
    end
  end
end

ActiveRecord::Base.include(ActiveRecord::Octojson)

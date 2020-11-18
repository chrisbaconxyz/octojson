class Post < ActiveRecord::Base
  SCHEMA = { 
    type_one: {
      title: { type: :string, default: 'Title -- one' },
      text_one: { type: :string, default: 'something cool -- one' },
      boolean_one: { type: :boolean, default: false },
      number_one: { type: :integer, default: 3, validates: { numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 } } },
      json_one: { type: :json, default: {}, nested_attributes: [:nested_one, :nested_two, :nested_three] },
    },  
    type_two: {
      title: { type: :string, default: 'Title -- two' },
      text_two: { type: :string, default: 'something cool -- two' },
      boolean_two: { type: :boolean, default: true },
    },
    type_three: {
      title: { type: :string, default: 'Title -- three' },
      text_three: { type: :string, default: 'something cool -- three' }
    }
  }.freeze

  OPTIONS_SCHEMA_AS_DEFAULT = { 
    _default: {
      title: { type: :string, default: 'default title' },
      number_default: { type: :integer, default: 3, validates: { numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 } } },
      sub_options: { type: :array, default: [], nested_attributes: [:name, :type] }
    }
  }.freeze

  octojson :settings, SCHEMA, :post_type
  octojson :options, OPTIONS_SCHEMA_AS_DEFAULT
end

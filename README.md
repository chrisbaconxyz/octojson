# Octojson

Supercharge `jsonb` attributes with defaults and schemas based on another `ActiveRecord` attribute. Inspired by [jsonb_accessor](https://rubygems.org/gems/jsonb_accessor)

## Installation

Add to your Gemfile:

```ruby 
gem 'octojson', git: 'git://github.com/baconck/octojson.git'
```

Then you can add `octojson` to your model(s):

```ruby
class Post < ActiveRecord::Base
  YOUR_SCHEMA = { 
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

  octojson :settings, YOUR_SCHEMA, :post_type
end

post = Post.new(post_type: 'type_one')
post.save
post.settings['title'] # => "Title -- one"
post.settings['text_one'] # => "something cool -- one"
post.settings['boolean_one'] # => false
post.settings['number_one'] # => 3
post.settings['json_one'] # => {}

post = Post.new(post_type: 'type_two')
post.save
post.settings['title'] # => "Title -- two"
post.settings['text_two'] # => "something cool -- two"
post.settings['boolean_two'] # => true
post.settings['text_one'] # => nil
```

## Usage

Validations are cool too! Use Rails validations as you would on directly on record's attributes.

```ruby
class Post < ActiveRecord::Base
  YOUR_SCHEMA = { 
    type_one: {
      count: { type: :integer, default: 3, validates: { numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 } } },
    },  
    type_two: {
      count: { type: :integer, default: 10, validates: { numericality: { only_integer: true, greater_than_or_equal_to: 5, less_than_or_equal_to: 15 } } },
    }
  }.freeze

  octojson :settings, YOUR_SCHEMA, :post_type
end
```

Use `JSONB_ATTRIBUTE_strong_params` with your controller strong params 

```ruby
class PostsController < ActiveController::Base
  
  def set_post
    @post = @post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(settings: @post.settings_strong_params)
  end
end
```

## Dependencies

- ActiveRecord >= 6.0
- Postgres >= 9.4 (in order to use the [jsonb column type](http://www.postgresql.org/docs/9.4/static/datatype-json.html)).


## Tests

Run `bin/setup` to install dependencies.

```shell
$ rake test
```

`** ensure postgres is running`


## Contributing

1. [Fork it](https://github.com/baconck/octojson/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Add tests and changes (run the tests with `rake`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request

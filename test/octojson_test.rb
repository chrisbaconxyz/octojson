require 'test_helper'

class OctojsonTest < ActiveSupport::TestCase
  
  test '#new with defaults' do
    post = Post.new(post_type: 'type_one')

    assert_equal post.settings['title'], 'Title -- one'
    assert_equal post.settings['text_one'], 'something cool -- one'
    assert_equal post.settings['boolean_one'], false
    assert_equal post.settings['number_one'], 3
    assert_equal post.settings['json_one'], {}

    post_two = Post.new(post_type: 'type_two')

    assert_equal post_two.settings['title'], 'Title -- two'
    assert_equal post_two.settings['text_two'], 'something cool -- two'
    assert_equal post_two.settings['boolean_two'], true
    assert_nil post_two.settings['text_one']
  end

  test '#new with attributes' do
    post = Post.new(post_type: 'type_one', settings: { title: 'Not default' })
    assert_equal post.settings['title'], 'Not default'
  end

  test '#new with attributes not in schema' do
    post = Post.new(post_type: 'type_one', settings: { something: 'Not default' })
    assert_nil post.settings['something']
  end

  test '#create' do
    post = Post.create(post_type: 'type_one', settings: { title: 'Created title' })
    assert_equal post.settings['title'], 'Created title'
    assert_equal post.settings['text_one'], 'something cool -- one'
  end

  test '#save with defaults' do
    post = Post.new
    post.post_type = 'type_one'
    post.save

    assert_equal post.settings['title'], 'Title -- one'
    assert_equal post.settings['text_one'], 'something cool -- one'
    assert_equal post.settings['boolean_one'], false
    assert_equal post.settings['number_one'], 3
    assert_equal post.settings['json_one'], {}

    post_two = Post.new
    post_two.post_type = 'type_two'
    post_two.save
    assert_equal post_two.settings['title'], 'Title -- two'
    assert_equal post_two.settings['text_two'], 'something cool -- two'
    assert_equal post_two.settings['boolean_two'], true
    assert_nil post_two.settings['text_one']
  end

  test '#update' do
    post = Post.create(post_type: 'type_one')
    assert_equal post.settings['title'], 'Title -- one'

    post.update(settings: { title: 'testing 123' })
    assert_equal post.settings['title'], 'testing 123'
  end

  test '#update should use default if assigning nil' do
    post = Post.create(post_type: 'type_one', settings: { title: 'testing' })
    assert_equal post.settings['title'], 'testing'

    post.update(settings: { title: nil })
    assert_equal post.settings['title'], 'Title -- one'
  end

  test '#{json_attribute}_strong_params' do
    post = Post.new
    post.post_type = 'type_one'
    post.save

    assert_equal post.settings_strong_params, [
        :title, 
        :text_one, 
        :boolean_one, 
        :number_one, 
        { :json_one=> [:nested_one, :nested_two, :nested_three] }
      ]
  end

  test 'valid on initialize' do
    post = Post.new(post_type: 'type_one')
    assert_equal post.valid?, true
  end

  test 'invalid when settings attribute out of range' do
    post = Post.new(post_type: 'type_one', settings: { number_one: 99 })
    assert_equal post.valid?, false
  end
end

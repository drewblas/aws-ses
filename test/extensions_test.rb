require File.dirname(__FILE__) + '/helper'

class StringExtensionsTest < Test::Unit::TestCase
  def test_previous
    expectations = {'abc' => 'abb', '123' => '122', '1' => '0'}
    expectations.each do |before, after|
      assert_equal after, before.previous
    end
  end
  
  def test_to_header
    transformations = {
      'foo'     => 'foo',
      :foo      => 'foo',
      'foo-bar' => 'foo-bar',
      'foo_bar' => 'foo-bar',
      :foo_bar  => 'foo-bar',
      'Foo-Bar' => 'foo-bar',
      'Foo_Bar' => 'foo-bar'
    }
    
    transformations.each do |before, after|
      assert_equal after, before.to_header
    end
  end
  
  def test_valid_utf8?
    assert !"318597/620065/GTL_75\24300_A600_A610.zip".valid_utf8?
    assert "318597/620065/GTL_75£00_A600_A610.zip".valid_utf8?
  end
  
  def test_remove_extended
    assert "318597/620065/GTL_75\24300_A600_A610.zip".remove_extended.valid_utf8?
    assert "318597/620065/GTL_75£00_A600_A610.zip".remove_extended.valid_utf8?
  end
end

class KerneltExtensionsTest < Test::Unit::TestCase
  class Foo
    def foo
      __method__
    end

    def bar
      foo
    end

    def baz
      bar
    end
  end
  
  class Bar
    def foo
      calling_method
    end
    
    def bar
      calling_method
    end
    
    def calling_method
      __method__(1)
    end
  end
    
  def test___method___works_regardless_of_nesting
    f = Foo.new
    [:foo, :bar, :baz].each do |method|
      assert_equal 'foo', f.send(method)
    end
  end
  
  def test___method___depth
    b = Bar.new
    assert_equal 'foo', b.foo
    assert_equal 'bar', b.bar
  end
end if RUBY_VERSION <= '1.8.7'

class ModuleExtensionsTest < Test::Unit::TestCase
  class Foo
    def foo(reload = false)
      expirable_memoize(reload) do
        Time.now
      end
    end
    
    def bar(reload = false)
      expirable_memoize(reload, :baz) do
        Time.now
      end
    end
    
    def quux
      Time.now
    end
    memoized :quux
  end
  
  def setup
    @instance = Foo.new
  end
  
  def test_memoize
    assert !instance_variables_of(@instance).include?('@foo')
    cached_result = @instance.foo
    assert_equal cached_result, @instance.foo
    assert instance_variables_of(@instance).include?('@foo')
    assert_equal cached_result, @instance.send(:instance_variable_get, :@foo)
    assert_not_equal cached_result, new_cache = @instance.foo(:reload)
    assert_equal new_cache, @instance.foo
    assert_equal new_cache, @instance.send(:instance_variable_get, :@foo)
  end
  
  def test_customizing_memoize_storage
    assert !instance_variables_of(@instance).include?('@bar')
    assert !instance_variables_of(@instance).include?('@baz')
    cached_result = @instance.bar
    assert !instance_variables_of(@instance).include?('@bar')
    assert instance_variables_of(@instance).include?('@baz')
    assert_equal cached_result, @instance.bar
    assert_equal cached_result, @instance.send(:instance_variable_get, :@baz)
    assert_nil @instance.send(:instance_variable_get, :@bar)
  end
  
  def test_memoized
    assert !instance_variables_of(@instance).include?('@quux')
    cached_result = @instance.quux
    assert_equal cached_result, @instance.quux
    assert instance_variables_of(@instance).include?('@quux')
    assert_equal cached_result, @instance.send(:instance_variable_get, :@quux)
    assert_not_equal cached_result, new_cache = @instance.quux(:reload)
    assert_equal new_cache, @instance.quux
    assert_equal new_cache, @instance.send(:instance_variable_get, :@quux)
  end
  
  def test_constant_setting
    some_module = Module.new
    assert !some_module.const_defined?(:FOO)
    assert_nothing_raised do
      some_module.constant :FOO, 'bar'
    end
    
    assert some_module.const_defined?(:FOO)
    assert_nothing_raised do
      some_module::FOO
      some_module.foo
    end
    assert_equal 'bar', some_module::FOO
    assert_equal 'bar', some_module.foo
    
    assert_nothing_raised do
      some_module.constant :FOO, 'baz'
    end
    
    assert_equal 'bar', some_module::FOO
    assert_equal 'bar', some_module.foo
  end
  
  private
    # For 1.9 compatibility
    def instance_variables_of(object)
      object.instance_variables.map do |instance_variable|
        instance_variable.to_s
      end
    end
      
end

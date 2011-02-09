require File.expand_path('../helper', __FILE__)

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
  
  private
    # For 1.9 compatibility
    def instance_variables_of(object)
      object.instance_variables.map do |instance_variable|
        instance_variable.to_s
      end
    end
      
end

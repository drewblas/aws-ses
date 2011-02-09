#:stopdoc:
module Kernel
  def __method__(depth = 0)
    caller[depth][/`([^']+)'/, 1]
  end if RUBY_VERSION <= '1.8.7'
  
  def __called_from__
    caller[1][/`([^']+)'/, 1]
  end if RUBY_VERSION > '1.8.7'
  
  def expirable_memoize(reload = false, storage = nil)
    current_method = RUBY_VERSION > '1.8.7' ? __called_from__ : __method__(1)
    storage = "@#{storage || current_method}"
    if reload 
      instance_variable_set(storage, nil)
    else
      if cache = instance_variable_get(storage)
        return cache
      end
    end
    instance_variable_set(storage, yield)
  end
end

class Module
  def memoized(method_name)
    original_method = "unmemoized_#{method_name}_#{Time.now.to_i}"
    alias_method original_method, method_name
    module_eval(<<-EVAL, __FILE__, __LINE__)
      def #{method_name}(reload = false, *args, &block)
        expirable_memoize(reload) do
          send(:#{original_method}, *args, &block)
        end
      end
    EVAL
  end
end

#:startdoc:

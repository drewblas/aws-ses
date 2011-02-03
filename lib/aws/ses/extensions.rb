#:stopdoc:
class String
  if RUBY_VERSION <= '1.9'
    def previous!
      self[-1] -= 1
      self
    end
  else
    def previous!
      self[-1] = (self[-1].ord - 1).chr
      self
    end
  end
  
  def previous
    dup.previous!
  end
  
  def to_header
    downcase.tr('_', '-')
  end
  
  # ActiveSupport adds an underscore method to String so let's just use that one if
  # we find that the method is already defined
  def underscore
    gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      tr("-", "_").downcase
  end unless public_method_defined? :underscore

  if RUBY_VERSION >= '1.9'
    def valid_utf8?
      dup.force_encoding('UTF-8').valid_encoding?
    end
  else
    def valid_utf8?
      scan(Regexp.new('[^\x00-\xa0]', nil, 'u')) { |s| s.unpack('U') }
      true
    rescue ArgumentError
      false
    end
  end
  
  # All paths in in S3 have to be valid unicode so this takes care of 
  # cleaning up any strings that aren't valid utf-8 according to String#valid_utf8?
  if RUBY_VERSION >= '1.9'
    def remove_extended!
      sanitized_string = ''
      each_byte do |byte|
        character = byte.chr
        sanitized_string << character if character.ascii_only?
      end
      sanitized_string
    end
  else
    def remove_extended!
      gsub!(/[\x80-\xFF]/) { "%02X" % $&[0] }
    end
  end
  
  def remove_extended
    dup.remove_extended!
  end
end

class Symbol
  def to_header
    to_s.to_header
  end
end

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

  def require_library_or_gem(library, gem_name = nil)
    if RUBY_VERSION >= '1.9'
      gem(gem_name || library, '>=0') 
    end
    require library
  rescue LoadError => library_not_installed
    begin
      require 'rubygems'
      require library
    rescue LoadError
      raise library_not_installed
    end
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
  
  def constant(name, value)
    unless const_defined?(name)
      const_set(name, value) 
      module_eval(<<-EVAL, __FILE__, __LINE__)
        def self.#{name.to_s.downcase}
          #{name.to_s}
        end
      EVAL
    end
  end
end


class XmlGenerator < String #:nodoc:
  attr_reader :xml
  def initialize
    @xml = Builder::XmlMarkup.new(:indent => 2, :target => self)
    super()
    build
  end
end
#:startdoc:

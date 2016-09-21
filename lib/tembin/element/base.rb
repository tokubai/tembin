module Tembin::Element
  module FieldDefinationMacros
    AVAILABLE_TYPES = [
      :string, :element, :numeric, :array, :boolean, :time
    ].freeze

    def field(key, type, options = {})
      raise ArgumentError, "Unknown element field type. #{key}, #{type}, #{options}" if !AVAILABLE_TYPES.include?(type)
      define_method(key) do |*args, &block|
        case type
        when :string, :numeric, :boolean
          @attributes[key] = args.first
        when :element
          @attributes[key] = options[:class].build(*args, &block)
        end
      end
    end
  end

  class Base
    extend FieldDefinationMacros

    def self.build(*args, &block)
      new(*args, &block).build
    end

    attr_reader :name, :attributes

    def initialize(*args, &block)
      @name = args[0]
      @block = block
      @attributes = {}
    end

    def build
      instance_exec(&@block)
      self
    end

    def to_params
      raise NotImplementedError
    end
  end
end

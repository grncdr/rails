# frozen_string_literal: true

module ActiveRecord
  module VirtualFunctions
    module_function

    def method_missing(function_name, *args)
      define_singleton_method(function_name) do |*args|
        args = args.map do |arg|
          case arg
          when Arel::Nodes::SqlLiteral, Arel::Nodes::Node, Arel::Attributes::Attribute
            arg
          else
            Arel::Nodes::BindParam.new(arg)
          end
        end
        Arel::Nodes::NamedFunction.new(function_name.to_s, args)
      end
      send(function_name, *args)
    end
  end
end

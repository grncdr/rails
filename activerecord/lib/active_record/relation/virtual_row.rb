# frozen_string_literal: true

require "active_record/relation/virtual_functions"

module ActiveRecord
  # A VirtualRow mirrors the shape of a relation, with attributes corresponding to the columns and
  # associations of the root table. Columns are represented by <tt>Arel::Attribute</tt> instances,
  # which allow constructing a variety of SQL expressions by calling methods, and associations are
  # represented by nested VirtualRow instances.
  #
  # When a supported query method is called with a block, the block receives a VirtualRow as an
  # argument or (if the block takes no arguments) as it's +self+ context. The return value of the
  # block then becomes the new argument(s) to the method.
  #
  # For example, you can use VirtualRow with +#order+ to control ordering of null values.
  #
  #     Post.order { published_at.desc.nulls_first }
  #
  # Or with +#where+ to construct conditions involving multiple columns.
  #
  #     Issue.where { (resolved_at - opened_at).gt(interval(2.days)) }
  #
  # In contrast to +where("(resolved_at - opened_at) > ?", 2.days)+ the above will use fully-
  # qualified column names and respect any table aliases in use by ActiveRecord.
  #
  # The following methods accept a block in place of normal arguments
  #
  #   - #reselect
  #   - #where
  #   - #having
  #   - #group
  #   - #order
  #
  # Note that +#select+ is a special case in order to remain compatible with <tt>Array#select</tt>.
  # If given a block argument, only a zero-argument block will use the VirtualRow behaviour.
  class VirtualRow
    include VirtualFunctions

    def initialize(table)
      @table = table
    end

    def respond_to_missing?(name, *args, **)
      return true if args.any?

      name = name.to_s
      table.has_column?(name) || table.associated_with?(name) || super
    end

    def method_missing(mid, *args)
      name = mid.to_s
      if args.any?
        super
      elsif table.has_column?(name)
        table.has_column?(name)
        attribute = table.arel_table[name]
        define_singleton_method(mid) { attribute }
        attribute
      elsif table.associated_with?(name)
        associated_row = VirtualRow.new(table.associated_table(name))
        define_singleton_method(mid) { associated_row }
        associated_row
      else
        super
      end
    end

    private
      
      attr_reader :table
  end
end

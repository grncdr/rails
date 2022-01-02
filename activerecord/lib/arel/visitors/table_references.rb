# frozen_string_literal: true

module Arel
  module Visitors
    class TableReferences < Arel::Visitors::Visitor
      private
        def visit_Arel_Nodes_Node(*); end

        def visit_Arel_Nodes_Unary(node, references)
          visit(node.expr, references)
        end

        def visit_Arel_Nodes_Binary(node, references)
          visit(node.left, references)
          visit(node.right, references)
        end

        def visit_Arel_Attributes_Attribute(node, references)
          visit(node.relation, references)
        end

        def visit_Arel_Nodes_TableAlias(node, references)
          references << Arel.sql(node.name)
        end

        def visit_Arel_Table(node, references)
          references << Arel.sql(node.name)
        end
    end
  end
end

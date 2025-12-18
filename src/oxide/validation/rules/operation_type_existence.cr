# Validation: Operation Type Existence
# https://spec.graphql.org/September2025/#sec-Operation-Type-Existence
#
# Named operations must only use operation types defined in the schema.
#
# Formal Specification:
# - For each named operation in the document:
#   - Let operationType be the operation type of the operation
#   - If operationType is mutation, the root Mutation type must be defined in the schema
#   - If operationType is subscription, the root Subscription type must be defined in the schema

module Oxide
  module Validation
    class OperationTypeExistence < Rule
      def enter(node : Oxide::Language::Nodes::OperationDefinition, context)
        case node.operation_type
        when "mutation"
          unless context.schema.mutation
            location = node.to_location
            context.errors << ValidationError.new(
              "Schema does not define a mutation type, but the operation is a mutation.",
              [location]
            )
          end
        when "subscription"
          # Subscription type is not yet implemented in the schema
          # This will need to be added when subscriptions are supported
          location = node.to_location
          context.errors << ValidationError.new(
            "Schema does not define a subscription type, but the operation is a subscription.",
            [location]
          )
        end
      end
    end
  end
end

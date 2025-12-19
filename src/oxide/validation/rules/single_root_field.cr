module Oxide
  module Validation
    # SingleRootField validates that subscription operations have exactly one root field.
    #
    # GraphQL Spec Section 5.2.3.1:
    # "Subscription operations must have exactly one root field."
    #
    # This ensures that each subscription operation subscribes to a single event stream.
    # Multiple root fields would create ambiguity about how to combine the streams.
    class SingleRootField < Rule
      def enter(node : Oxide::Language::Nodes::OperationDefinition, context)
        # Only validate subscription operations
        return unless node.operation_type == "subscription"

        # Get the subscription root type from the schema
        subscription_type = context.schema.subscription
        return unless subscription_type

        # Count root fields (excluding __typename and other introspection fields)
        root_fields = node.selection_set.selections.select do |selection|
          if selection.is_a?(Oxide::Language::Nodes::Field)
            # Introspection fields like __typename don't count
            !selection.name.starts_with?("__")
          else
            # FragmentSpread and InlineFragment count as they may contain fields
            true
          end
        end

        if root_fields.size == 0
          context.errors << ValidationError.new(
            "Subscription operation must have exactly one root field.",
            [node.to_location]
          )
        elsif root_fields.size > 1
          field_names = root_fields.map do |selection|
            case selection
            when Oxide::Language::Nodes::Field
              selection.name
            when Oxide::Language::Nodes::FragmentSpread
              "...#{selection.name}"
            when Oxide::Language::Nodes::InlineFragment
              "... on #{selection.type_condition}"
            else
              "unknown"
            end
          end

          locations = root_fields.map(&.to_location)
          context.errors << ValidationError.new(
            "Subscription \"#{node.name || "Anonymous"}\" must have only one root field.",
            locations
          )
        end
      end
    end
  end
end

# Validation: Fragment Spreads Must Not Form Cycles
# https://spec.graphql.org/September2025/#sec-Fragment-spreads-must-not-form-cycles
#
# The graph of fragment spreads must not form any cycles including spreading itself.
# Otherwise an operation could infinitely spread or infinitely execute on cycles in the underlying data.
#
# Formal Specification:
# - For each fragment defined in the document:
#   - Let initial be the first fragment spread in the fragment definition
#   - Recursively follow all fragment spreads from initial
#   - Must not return to the fragment that is being validated

module Oxide
  module Validation
    class FragmentSpreadsMusNotFormCycles < Rule
      def initialize
        @fragment_definitions = {} of String => Oxide::Language::Nodes::FragmentDefinition
        @fragment_spreads = {} of String => Array(String)
      end

      def enter(node : Oxide::Language::Nodes::FragmentDefinition, context)
        @fragment_definitions[node.name] = node
      end

      def leave(node : Oxide::Language::Nodes::Document, context)
        # Build a map of fragment -> spreads within that fragment
        @fragment_definitions.each do |fragment_name, fragment_def|
          spreads = collect_spreads(fragment_def)
          @fragment_spreads[fragment_name] = spreads
        end

        # Check for cycles
        @fragment_definitions.each_key do |fragment_name|
          if has_cycle?(fragment_name, Set(String).new, [] of String)
            context.errors << ValidationError.new(
              "Cannot spread fragment \"#{fragment_name}\" within itself."
            )
          end
        end
      end

      private def collect_spreads(node : Oxide::Language::Nodes::FragmentDefinition) : Array(String)
        spreads = [] of String
        collect_spreads_recursive(node.selection_set, spreads)
        spreads
      end

      private def collect_spreads_recursive(node : Oxide::Language::Nodes::SelectionSet, spreads : Array(String))
        node.selections.each do |selection|
          case selection
          when Oxide::Language::Nodes::FragmentSpread
            spreads << selection.name
          when Oxide::Language::Nodes::Field
            if selection_set = selection.selection_set
              collect_spreads_recursive(selection_set, spreads)
            end
          when Oxide::Language::Nodes::InlineFragment
            if selection_set = selection.selection_set
              collect_spreads_recursive(selection_set, spreads)
            end
          end
        end
      end

      private def has_cycle?(fragment_name : String, visited : Set(String), path : Array(String)) : Bool
        # If we've already visited this fragment in the current path, we have a cycle
        return true if visited.includes?(fragment_name)

        # Mark this fragment as visited
        visited.add(fragment_name)
        path << fragment_name

        # Get all the spreads from this fragment
        spreads = @fragment_spreads[fragment_name]? || [] of String

        # Check each spread for cycles
        spreads.each do |spread_name|
          # Only check if the spread target is defined (another rule handles undefined spreads)
          if @fragment_definitions.has_key?(spread_name)
            if has_cycle?(spread_name, visited.dup, path.dup)
              return true
            end
          end
        end

        false
      end
    end
  end
end

require "spec"
require "../src/graphql"
require "./dummy/schema"

class NullResolver < Graphql::Schema::Resolver
  def resolve(object, context, field_name, argument_values)
    nil
  end
end
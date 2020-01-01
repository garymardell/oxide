require "./type"
require "./directive"

module Graphql
  module Introspection
    Schema = Graphql::Type::Object.new(
      typename: "__Type",
      resolver: SchemaResolver.new
    )

    Schema.add_field(Graphql::Schema::Field.new(
      name: "types",
      type: Graphql::Type::NonNull.new(
        of_type: Graphql::Type::List.new(
          of_type: Graphql::Type::NonNull.new(
            of_type: Introspection::Type
          )
        )
      )
    ))

    Schema.add_field(Graphql::Schema::Field.new(
      name: "queryType",
      type: Graphql::Type::NonNull.new(
        of_type: Introspection::Type
      )
    ))

    Schema.add_field(Graphql::Schema::Field.new(
      name: "mutationType",
      type: Introspection::Type
    ))

    Schema.add_field(Graphql::Schema::Field.new(
      name: "subscriptionType",
      type: Introspection::Type
    ))

    Schema.add_field(Graphql::Schema::Field.new(
      name: "directives",
      type: Graphql::Type::NonNull.new(
        of_type: Graphql::Type::List.new(
          of_type: Graphql::Type::NonNull.new(
            of_type: Introspection::Directive
          )
        )
      )
    ))
  end
end

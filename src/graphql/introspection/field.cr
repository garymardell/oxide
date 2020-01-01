require "./type"
require "./input_value"

module Graphql
  module Introspection
    Field = Graphql::Type::Object.new(
      typename: "__Field",
      resolver: FieldResolver.new
    )

    Field.add_field(Graphql::Schema::Field.new(
      name: "name",
      type: Graphql::Type::NonNull.new(
        of_type: Graphql::Type::String.new
      )
    ))

    Field.add_field(Graphql::Schema::Field.new(
      name: "description",
      type: Graphql::Type::String.new
    ))

    Field.add_field(Graphql::Schema::Field.new(
      name: "args",
      type: Graphql::Type::NonNull.new(
        of_type: Graphql::Type::List.new(
          of_type: Graphql::Type::NonNull.new(
            of_type: Introspection::InputValue
          )
        )
      )
    ))

    Field.add_field(Graphql::Schema::Field.new(
      name: "type",
      type: Graphql::Type::NonNull.new(
        of_type: Introspection::Type
      )
    ))

    Field.add_field(Graphql::Schema::Field.new(
      name: "isDeprecated",
      type: Graphql::Type::NonNull.new(
        of_type: Graphql::Type::Boolean.new
      )
    ))

    Field.add_field(Graphql::Schema::Field.new(
      name: "deprecationReason",
      type: Graphql::Type::String.new
    ))

    #   fields: [
    #     Graphql::Schema::Field.new(
    #       name: "name",
    #       type: Graphql::Type::NonNull.new(
    #         of_type: Graphql::Type::String.new
    #       )
    #     ),
    #     Graphql::Schema::Field.new(
    #       name: "description",
    #       type: Graphql::Type::String.new
    #     ),
    #     Graphql::Schema::Field.new(
    #       name: "args",
    #       type: Graphql::Type::NonNull.new(
    #         of_type: Graphql::Type::List.new(
    #           of_type: Graphql::Type::NonNull.new(
    #             of_type: Introspection::InputValue
    #           )
    #         )
    #       )
    #     ),
    #     Graphql::Schema::Field.new(
    #       name: "type",
    #       type: Graphql::Type::NonNull.new(
    #         of_type: Introspection::Type
    #       )
    #     ),
    #     Graphql::Schema::Field.new(
    #       name: "isDeprecated",
    #       type: Graphql::Type::NonNull.new(
    #         of_type: Graphql::Type::Boolean.new
    #       )
    #     ),
    #     Graphql::Schema::Field.new(
    #       name: "deprecationReason",
    #       type: Graphql::Type::String.new
    #     )
    #   ]
    # )
  end
end
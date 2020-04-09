module Types
  class ChargeType < Graphql::DSL::Object
    field "id", type: Graphql::DSL::Id, null: false

    def resolve(object : Charge, field_name, argument_values)
      case field_name
      when "id"
        object.id
      end
    end
  end
end
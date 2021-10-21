require "spec"
require "../src/graphql"
require "./dummy/schema"

class NullResolver < Graphql::Schema::Resolver
  def resolve(object, context, field_name, argument_values)
    nil
  end
end

# type Query {
#   dog: Dog
# }

# enum DogCommand { SIT, DOWN, HEEL }

# type Dog implements Pet {
#   name: String!
#   nickname: String
#   barkVolume: Int
#   doesKnowCommand(dogCommand: DogCommand!): Boolean!
#   isHousetrained(atOtherHomes: Boolean): Boolean!
#   owner: Human
# }

# interface Sentient {
#   name: String!
# }

# interface Pet {
#   name: String!
# }

# type Alien implements Sentient {
#   name: String!
#   homePlanet: String
# }

# type Human implements Sentient {
#   name: String!
# }

# enum CatCommand { JUMP }

# type Cat implements Pet {
#   name: String!
#   nickname: String
#   doesKnowCommand(catCommand: CatCommand!): Boolean!
#   meowVolume: Int
# }

# union CatOrDog = Cat | Dog
# union DogOrHuman = Dog | Human
# union HumanOrAlien = Human | Alien

DogCommandEnum = Graphql::Type::Enum.new(
  typename: "DogCommand",
  values: [
    Graphql::Type::EnumValue.new(name: "SIT"),
    Graphql::Type::EnumValue.new(name: "DOWN"),
    Graphql::Type::EnumValue.new(name: "HEEL")
  ]
)

class PetTypeResolver < Graphql::Schema::TypeResolver
  def resolve_type(object, context)
    DogObject
  end
end

SentientInterface = Graphql::Type::Interface.new(
  name: "Sentient",
  type_resolver: PetTypeResolver.new,
  fields: [
    Graphql::Schema::Field.new(
      name: "name",
      type: Graphql::Type::NonNull.new(
        of_type: Graphql::Type::String.new
      )
    )
  ]
)

PetInterface = Graphql::Type::Interface.new(
  name: "Pet",
  type_resolver: PetTypeResolver.new,
  fields: [
    Graphql::Schema::Field.new(
      name: "name",
      type: Graphql::Type::NonNull.new(
        of_type: Graphql::Type::String.new
      )
    )
  ]
)

DogObject = Graphql::Type::Object.new(
  typename: "Dog",
  implements: [PetInterface],
  resolver: NullResolver.new,
)

ValidationsSchema = Graphql::Schema.new(
  query: Graphql::Type::Object.new(
    typename: "Query",
    resolver: NullResolver.new,
    fields: [
      Graphql::Schema::Field.new(
        name: "dog",
        type: DogObject
      )
    ]
  )
)
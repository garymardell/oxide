require "spec"
require "../src/graphene"
require "./dummy/schema"

class NullResolver < Graphene::Schema::Resolver
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

DogCommandEnum = Graphene::Type::Enum.new(
  name: "DogCommand",
  values: [
    Graphene::Type::EnumValue.new(name: "SIT"),
    Graphene::Type::EnumValue.new(name: "DOWN"),
    Graphene::Type::EnumValue.new(name: "HEEL")
  ]
)

class PetTypeResolver < Graphene::Schema::TypeResolver
  def resolve_type(object, context)
    DogObject
  end
end

SentientInterface = Graphene::Type::Interface.new(
  name: "Sentient",
  fields: [
    Graphene::Schema::Field.new(
      name: "name",
      type: Graphene::Type::NonNull.new(
        of_type: Graphene::Type::String.new
      )
    )
  ]
)

PetInterface = Graphene::Type::Interface.new(
  name: "Pet",
  fields: [
    Graphene::Schema::Field.new(
      name: "name",
      type: Graphene::Type::NonNull.new(
        of_type: Graphene::Type::String.new
      )
    )
  ]
)

DogObject = Graphene::Type::Object.new(
  name: "Dog",
  implements: [PetInterface],
)

ValidationsSchema = Graphene::Schema.new(
  query: Graphene::Type::Object.new(
    name: "Query",
    fields: [
      Graphene::Schema::Field.new(
        name: "dog",
        type: DogObject
      )
    ]
  )
)
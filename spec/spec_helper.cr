require "spec"
require "../src/graphene"
require "./dummy/schema"

class NullResolver < Graphene::Schema::Resolver
  def resolve(object, context, field_name, argument_values)
    nil
  end
end

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
    DogType
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

AlienType = Graphene::Type::Object.new(
  name: "Alien",
  fields: [
    Graphene::Schema::Field.new(
      name: "name",
      type: Graphene::Type::NonNull.new(
        of_type: Graphene::Type::String.new
      )
    ),
    Graphene::Schema::Field.new(
      name: "homePlanet",
      type: Graphene::Type::String.new
    )
  ]
)

HumanType = Graphene::Type::Object.new(
  name: "Human",
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

CatCommandEnum = Graphene::Type::Enum.new(
  name: "CatCommand",
  values: [
    Graphene::Type::EnumValue.new(name: "JUMP")
  ]
)

CatType = Graphene::Type::Object.new(
  name: "Cat",
  implements: [PetInterface],
  fields: [
    Graphene::Schema::Field.new(
      name: "name",
      type: Graphene::Type::NonNull.new(
        of_type: Graphene::Type::String.new
      )
    ),
    Graphene::Schema::Field.new(
      name: "nickname",
      type: Graphene::Type::String.new
    ),
    Graphene::Schema::Field.new(
      name: "doesKnowCommand",
      arguments: [
        Graphene::Schema::Argument.new(
          name: "catCommand",
          type: Graphene::Type::NonNull.new(
            of_type: CatCommandEnum
          )
        )
      ],
      type: Graphene::Type::NonNull.new(
        of_type: Graphene::Type::Boolean.new
      )
    ),
    Graphene::Schema::Field.new(
      name: "meowVolume",
      type: Graphene::Type::Int.new
    )
  ]
)

CatOrDogUnion = Graphene::Type::Union.new(
  name: "CatOrDog",
  possible_types: [
    CatType.as(Graphene::Type),
    DogType.as(Graphene::Type)
  ]
)

DogOrHumanUnion = Graphene::Type::Union.new(
  name: "DogOrHuman",
  possible_types: [
    DogType.as(Graphene::Type),
    HumanType.as(Graphene::Type)
  ]
)

HumanOrAlienUnion = Graphene::Type::Union.new(
  name: "HumanOrAlien",
  possible_types: [
    AlienType.as(Graphene::Type),
    HumanType.as(Graphene::Type)
  ]
)

DogType = Graphene::Type::Object.new(
  name: "Dog",
  implements: [PetInterface],
  fields: [
    Graphene::Schema::Field.new(
      name: "name",
      type: Graphene::Type::NonNull.new(
        of_type: Graphene::Type::String.new
      )
    ),
    Graphene::Schema::Field.new(
      name: "nickname",
      type: Graphene::Type::String.new
    ),
    Graphene::Schema::Field.new(
      name: "barkVolume",
      type: Graphene::Type::Int.new
    ),
    Graphene::Schema::Field.new(
      name: "doesKnowCommand",
      arguments: [
        Graphene::Schema::Argument.new(
          name: "dogCommand",
          type: Graphene::Type::NonNull.new(
            of_type: DogCommandEnum
          )
        )
      ],
      type: Graphene::Type::NonNull.new(
        of_type: Graphene::Type::Boolean.new
      )
    ),
    Graphene::Schema::Field.new(
      name: "isHousetrained",
      arguments: [
        Graphene::Schema::Argument.new(
          name: "atOtherHomes",
          type: Graphene::Type::Boolean.new
        )
      ],
      type: Graphene::Type::NonNull.new(
        of_type: Graphene::Type::Boolean.new
      )
    ),
    Graphene::Schema::Field.new(
      name: "owner",
      type: HumanType
    )
  ]
)

ValidationsSchema = Graphene::Schema.new(
  query: Graphene::Type::Object.new(
    name: "Query",
    fields: [
      Graphene::Schema::Field.new(
        name: "dog",
        type: DogType
      )
    ]
  ),
  orphan_types: [
    CatOrDogUnion.as(Graphene::Type),
    DogOrHumanUnion.as(Graphene::Type),
    HumanOrAlienUnion.as(Graphene::Type)
  ]
)
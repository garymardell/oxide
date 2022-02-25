require "spec"
require "../src/graphene"
require "./dummy/schema"

class NullResolver < Graphene::Resolver
  def resolve(object, context, field_name, argument_values)
    nil
  end
end

DogCommandEnum = Graphene::Types::Enum.new(
  name: "DogCommand",
  values: [
    Graphene::Types::EnumValue.new(name: "SIT"),
    Graphene::Types::EnumValue.new(name: "DOWN"),
    Graphene::Types::EnumValue.new(name: "HEEL")
  ]
)

class SentientTypeResolver < Graphene::TypeResolver
  def resolve_type(object, context)
    AlienType
  end
end

class CatOrDogTypeResolver < Graphene::TypeResolver
  def resolve_type(object, context)
    CatType
  end
end

class DogOrHumanTypeResolver < Graphene::TypeResolver
  def resolve_type(object, context)
    HumanType
  end
end

class HumanOrAlienTypeResolver < Graphene::TypeResolver
  def resolve_type(object, context)
    HumanType
  end
end

class PetTypeResolver < Graphene::TypeResolver
  def resolve_type(object, context)
    DogType
  end
end

SentientInterface = Graphene::Types::Interface.new(
  name: "Sentient",
  type_resolver: SentientTypeResolver.new,
  fields: [
    Graphene::Field.new(
      name: "name",
      type: Graphene::Types::NonNull.new(
        of_type: Graphene::Types::String.new
      )
    )
  ]
)

AlienType = Graphene::Types::Object.new(
  name: "Alien",
  resolver: NullResolver.new,
  fields: [
    Graphene::Field.new(
      name: "name",
      type: Graphene::Types::NonNull.new(
        of_type: Graphene::Types::String.new
      )
    ),
    Graphene::Field.new(
      name: "homePlanet",
      type: Graphene::Types::String.new
    )
  ]
)

HumanType = Graphene::Types::Object.new(
  name: "Human",
  resolver: NullResolver.new,
  fields: [
    Graphene::Field.new(
      name: "name",
      type: Graphene::Types::NonNull.new(
        of_type: Graphene::Types::String.new
      )
    )
  ]
)


PetInterface = Graphene::Types::Interface.new(
  name: "Pet",
  type_resolver: PetTypeResolver.new,
  fields: [
    Graphene::Field.new(
      name: "name",
      type: Graphene::Types::NonNull.new(
        of_type: Graphene::Types::String.new
      )
    )
  ]
)

CatCommandEnum = Graphene::Types::Enum.new(
  name: "CatCommand",
  values: [
    Graphene::Types::EnumValue.new(name: "JUMP")
  ]
)

CatType = Graphene::Types::Object.new(
  name: "Cat",
  resolver: NullResolver.new,
  interfaces: [PetInterface],
  fields: [
    Graphene::Field.new(
      name: "name",
      type: Graphene::Types::NonNull.new(
        of_type: Graphene::Types::String.new
      )
    ),
    Graphene::Field.new(
      name: "nickname",
      type: Graphene::Types::String.new
    ),
    Graphene::Field.new(
      name: "doesKnowCommand",
      arguments: [
        Graphene::Argument.new(
          name: "catCommand",
          type: Graphene::Types::NonNull.new(
            of_type: CatCommandEnum
          )
        )
      ],
      type: Graphene::Types::NonNull.new(
        of_type: Graphene::Types::Boolean.new
      )
    ),
    Graphene::Field.new(
      name: "meowVolume",
      type: Graphene::Types::Int.new
    )
  ]
)

CatOrDogUnion = Graphene::Types::Union.new(
  name: "CatOrDog",
  type_resolver: CatOrDogTypeResolver.new,
  possible_types: [
    CatType.as(Graphene::Type),
    DogType.as(Graphene::Type)
  ]
)

DogOrHumanUnion = Graphene::Types::Union.new(
  name: "DogOrHuman",
  type_resolver: DogOrHumanTypeResolver.new,
  possible_types: [
    DogType.as(Graphene::Type),
    HumanType.as(Graphene::Type)
  ]
)

HumanOrAlienUnion = Graphene::Types::Union.new(
  name: "HumanOrAlien",
  type_resolver: HumanOrAlienTypeResolver.new,
  possible_types: [
    AlienType.as(Graphene::Type),
    HumanType.as(Graphene::Type)
  ]
)

DogType = Graphene::Types::Object.new(
  name: "Dog",
  resolver: NullResolver.new,
  interfaces: [PetInterface],
  fields: [
    Graphene::Field.new(
      name: "name",
      type: Graphene::Types::NonNull.new(
        of_type: Graphene::Types::String.new
      )
    ),
    Graphene::Field.new(
      name: "nickname",
      type: Graphene::Types::String.new
    ),
    Graphene::Field.new(
      name: "barkVolume",
      type: Graphene::Types::Int.new
    ),
    Graphene::Field.new(
      name: "doesKnowCommand",
      arguments: [
        Graphene::Argument.new(
          name: "dogCommand",
          type: Graphene::Types::NonNull.new(
            of_type: DogCommandEnum
          )
        )
      ],
      type: Graphene::Types::NonNull.new(
        of_type: Graphene::Types::Boolean.new
      )
    ),
    Graphene::Field.new(
      name: "isHousetrained",
      arguments: [
        Graphene::Argument.new(
          name: "atOtherHomes",
          type: Graphene::Types::Boolean.new
        )
      ],
      type: Graphene::Types::NonNull.new(
        of_type: Graphene::Types::Boolean.new
      )
    ),
    Graphene::Field.new(
      name: "owner",
      type: HumanType
    )
  ]
)

ValidationsSchema = Graphene::Schema.new(
  query: Graphene::Types::Object.new(
    name: "Query",
    resolver: NullResolver.new,
    fields: [
      Graphene::Field.new(
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
require "spec"
require "../src/oxide"
require "./dummy/schema"

class NullResolver < Oxide::Resolver
  def resolve(object : Oxide::Resolvable?, field_name, argument_values, context, resolution_info) : Oxide::Result
  end

  def resolve(object, field_name, argument_values, context, resolution_info)
    nil
  end
end

DogCommandEnum = Oxide::Types::EnumType.new(
  name: "DogCommand",
  values: [
    Oxide::Types::EnumValue.new(name: "SIT"),
    Oxide::Types::EnumValue.new(name: "DOWN"),
    Oxide::Types::EnumValue.new(name: "HEEL")
  ]
)

class SentientTypeResolver < Oxide::TypeResolver
  def resolve_type(object, context)
    AlienType
  end
end

class CatOrDogTypeResolver < Oxide::TypeResolver
  def resolve_type(object, context)
    CatType
  end
end

class DogOrHumanTypeResolver < Oxide::TypeResolver
  def resolve_type(object, context)
    HumanType
  end
end

class HumanOrAlienTypeResolver < Oxide::TypeResolver
  def resolve_type(object, context)
    HumanType
  end
end

class PetTypeResolver < Oxide::TypeResolver
  def resolve_type(object, context)
    DogType
  end
end

SentientInterface = Oxide::Types::Interface.new(
  name: "Sentient",
  type_resolver: SentientTypeResolver.new,
  fields: {
    "name" => Oxide::Field.new(
      type: Oxide::Types::NonNullType.new(
        of_type: Oxide::Types::StringType.new
      )
    )
  }
)

AlienType = Oxide::Types::ObjectType.new(
  name: "Alien",
  resolver: NullResolver.new,
  fields: {
    "name" => Oxide::Field.new(
      type: Oxide::Types::NonNullType.new(
        of_type: Oxide::Types::StringType.new
      )
    ),
    "homePlanet" => Oxide::Field.new(
      type: Oxide::Types::StringType.new
    )
  }
)

HumanType = Oxide::Types::ObjectType.new(
  name: "Human",
  resolver: NullResolver.new,
  fields: {
    "name" => Oxide::Field.new(
      type: Oxide::Types::NonNullType.new(
        of_type: Oxide::Types::StringType.new
      )
    )
  }
)


PetInterface = Oxide::Types::InterfaceType.new(
  name: "Pet",
  type_resolver: PetTypeResolver.new,
  fields: {
    "name" => Oxide::Field.new(
      type: Oxide::Types::NonNullType.new(
        of_type: Oxide::Types::StringType.new
      )
    )
  }
)

CatCommandEnum = Oxide::Types::EnumType.new(
  name: "CatCommand",
  values: [
    Oxide::Types::EnumValue.new(name: "JUMP")
  ]
)

CatType = Oxide::Types::ObjectType.new(
  name: "Cat",
  resolver: NullResolver.new,
  interfaces: [PetInterface],
  fields: {
    "name" => Oxide::Field.new(
      type: Oxide::Types::NonNullType.new(
        of_type: Oxide::Types::StringType.new
      )
    ),
    "nickname" => Oxide::Field.new(
      type: Oxide::Types::StringType.new
    ),
    "doesKnowCommand" => Oxide::Field.new(
      arguments: {
        "catCommand" => Oxide::Argument.new(
          type: Oxide::Types::NonNullType.new(
            of_type: CatCommandEnum
          )
        )
      },
      type: Oxide::Types::NonNullType.new(
        of_type: Oxide::Types::BooleanType.new
      )
    ),
    "meowVolume" => Oxide::Field.new(
      type: Oxide::Types::IntType.new
    )
  }
)

CatOrDogUnion = Oxide::Types::UnionType.new(
  name: "CatOrDog",
  type_resolver: CatOrDogTypeResolver.new,
  possible_types: [
    CatType.as(Oxide::Type),
    DogType.as(Oxide::Type)
  ]
)

DogOrHumanUnion = Oxide::Types::UnionType.new(
  name: "DogOrHuman",
  type_resolver: DogOrHumanTypeResolver.new,
  possible_types: [
    DogType.as(Oxide::Type),
    HumanType.as(Oxide::Type)
  ]
)

HumanOrAlienUnion = Oxide::Types::UnionType.new(
  name: "HumanOrAlien",
  type_resolver: HumanOrAlienTypeResolver.new,
  possible_types: [
    AlienType.as(Oxide::Type),
    HumanType.as(Oxide::Type)
  ]
)

DogType = Oxide::Types::ObjectType.new(
  name: "Dog",
  resolver: NullResolver.new,
  interfaces: [PetInterface],
  fields: {
    "name" => Oxide::Field.new(
      type: Oxide::Types::NonNullType.new(
        of_type: Oxide::Types::StringType.new
      )
    ),
    "nickname" => Oxide::Field.new(
      type: Oxide::Types::StringType.new
    ),
    "barkVolume" => Oxide::Field.new(
      type: Oxide::Types::IntType.new
    ),
    "doesKnowCommand" => Oxide::Field.new(
      arguments: {
        "dogCommand" => Oxide::Argument.new(
          type: Oxide::Types::NonNullType.new(
            of_type: DogCommandEnum
          )
        )
      },
      type: Oxide::Types::NonNullType.new(
        of_type: Oxide::Types::BooleanType.new
      )
    ),
    "isHousetrained" => Oxide::Field.new(
      arguments: {
        "atOtherHomes" => Oxide::Argument.new(
          type: Oxide::Types::BooleanType.new
        )
      },
      type: Oxide::Types::NonNullType.new(
        of_type: Oxide::Types::BooleanType.new
      )
    ),
    "owner" => Oxide::Field.new(
      type: HumanType
    ),
  }
)

FindDogInputType = Oxide::Types::InputObjectType.new(
  name: "FindDogInput",
  input_fields: {
    "name" => Oxide::Argument.new(
      type: Oxide::Types::StringType.new
    ),
    "owner" => Oxide::Argument.new(
      type: Oxide::Types::StringType.new
    )
  }
)

ValidationsSchema = Oxide::Schema.new(
  query: Oxide::Types::ObjectType.new(
    name: "Query",
    resolver: NullResolver.new,
    fields: {
      "dog" => Oxide::Field.new(
        type: DogType
      ),
      "findDog" => Oxide::Field.new(
        arguments: {
          "searchBy" => Oxide::Argument.new(
            type: FindDogInputType
          )
        },
        type: DogType
      ),
      # Extended for LeafFieldSelections test
      "human" => Oxide::Field.new(
        type: HumanType
      ),
      "pet" => Oxide::Field.new(
        type: PetInterface
      ),
      "catOrDog" => Oxide::Field.new(
        type: CatOrDogUnion
      ),
      "booleanList" => Oxide::Field.new(
        arguments: {
          "booleanListArg" => Oxide::Argument.new(
            type: Oxide::Types::ListType.new(
              of_type: Oxide::Types::NonNullType.new(of_type: Oxide::Types::BooleanType.new)
            )
          )
        },
        type: Oxide::Types::BooleanType.new
      )
    }
  ),
  orphan_types: [
    CatOrDogUnion.as(Oxide::Type),
    DogOrHumanUnion.as(Oxide::Type),
    HumanOrAlienUnion.as(Oxide::Type)
  ]
)
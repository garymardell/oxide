require "../../spec_helper"

class BuilderResolver < Graphene::Resolver
end

class BuilderTypeResolver < Graphene::TypeResolver
end

describe Graphene::Utils::Builder do
  it "parses schema and builds schema object" do
    input = <<-INPUT
      schema {
        query: Query
      }

      type Query {
        dog: Dog
      }

      enum DogCommand { SIT, DOWN, HEEL }

      type Dog implements Pet {
        name: String!
        nickname: String
        barkVolume: Int
        doesKnowCommand(dogCommand: DogCommand!): Boolean!
        isHousetrained(atOtherHomes: Boolean): Boolean!
        owner: Human
      }

      interface Sentient {
        name: String!
      }

      interface Pet {
        name: String!
      }

      type Alien implements Sentient {
        name: String!
        homePlanet: String
      }

      type Human implements Sentient {
        name: String!
      }

      enum CatCommand { JUMP }

      type Cat implements Pet {
        name: String!
        nickname: String
        doesKnowCommand(catCommand: CatCommand!): Boolean!
        meowVolume: Int
      }

      union CatOrDog = Cat | Dog
      union DogOrHuman = Dog | Human
      union HumanOrAlien = Human | Alien
    INPUT

    builder = Graphene::Utils::Builder.new(
      input,
      resolvers: Hash(String, Graphene::Resolvable).new(default_value: BuilderResolver.new),
      type_resolvers: Hash(String, Graphene::TypeResolver).new(default_value: BuilderTypeResolver.new)
    )
    builder.build
  end

  it "supports field arguments with default values" do
    input = <<-INPUT
      schema {
        query: Query
      }

      type Query {
        isFavouriteNumber(number: Int = 42): Boolean!
      }
    INPUT

    builder = Graphene::Utils::Builder.new(
      input,
      resolvers: Hash(String, Graphene::Resolvable).new(default_value: BuilderResolver.new),
      type_resolvers: Hash(String, Graphene::TypeResolver).new(default_value: BuilderTypeResolver.new)
    )

    schema = builder.build

    field = schema.query.fields.find(&.name.===("isFavouriteNumber"))
    field.should_not be_nil

    argument = field.not_nil!.arguments.find(&.name.===("number"))
    argument.should_not be_nil

    argument.not_nil!.has_default_value?.should be_true
    argument.not_nil!.default_value.should eq(42)
  end
end
require "../../spec_helper"

describe Oxide::Validation::AllVariableUsesDefined do
  it "detects undefined variables in deeply nested fragments" do
    query_string = <<-QUERY
      query QueryWithNestedFragments($var1: Boolean!) {
        dog {
          ...fragmentA
        }
      }

      fragment fragmentA on Dog {
        name
        ...fragmentB
      }

      fragment fragmentB on Dog {
        isHouseTrained(atOtherHomes: $var2)
        ...fragmentC
      }

      fragment fragmentC on Dog {
        owner {
          name
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::AllVariableUsesDefined.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should eq(1)
    runtime.errors.first.message.should match(/Variable "\$var2" is not defined/)
  end

  it "detects undefined variables in three-level nested fragments" do
    query_string = <<-QUERY
      query QueryWithDeeplyNestedFragments($var1: Boolean!) {
        dog {
          ...level1
        }
      }

      fragment level1 on Dog {
        name
        ...level2
      }

      fragment level2 on Dog {
        barkVolume
        ...level3
      }

      fragment level3 on Dog {
        isHouseTrained(atOtherHomes: $undefinedVar)
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::AllVariableUsesDefined.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should eq(1)
    runtime.errors.first.message.should match(/Variable "\$undefinedVar" is not defined/)
  end

  it "validates variables correctly in recursive fragment chains" do
    query_string = <<-QUERY
      query QueryWithAllVariablesDefined($homeVar: Boolean!, $levelVar: Boolean!) {
        dog {
          ...fragmentA
        }
      }

      fragment fragmentA on Dog {
        name
        ...fragmentB
      }

      fragment fragmentB on Dog {
        isHouseTrained(atOtherHomes: $homeVar)
        ...fragmentC
      }

      fragment fragmentC on Dog {
        doesKnowCommand(dogCommand: SIT, level: $levelVar)
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::AllVariableUsesDefined.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should eq(0)
  end

  it "handles multiple fragments at each nesting level" do
    query_string = <<-QUERY
      query QueryWithBranchedFragments($var1: Boolean!) {
        dog {
          ...fragmentA
        }
      }

      fragment fragmentA on Dog {
        name
        ...fragmentB
        ...fragmentC
      }

      fragment fragmentB on Dog {
        barkVolume
        ...fragmentD
      }

      fragment fragmentC on Dog {
        owner {
          name
        }
      }

      fragment fragmentD on Dog {
        isHouseTrained(atOtherHomes: $undefinedVar)
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::AllVariableUsesDefined.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should eq(1)
    runtime.errors.first.message.should match(/Variable "\$undefinedVar" is not defined/)
  end

  it "handles diamond-shaped fragment dependencies" do
    query_string = <<-QUERY
      query QueryWithDiamondFragments($var1: Boolean!) {
        dog {
          ...fragmentA
          ...fragmentB
        }
      }

      fragment fragmentA on Dog {
        name
        ...fragmentC
      }

      fragment fragmentB on Dog {
        barkVolume
        ...fragmentC
      }

      fragment fragmentC on Dog {
        isHouseTrained(atOtherHomes: $undefinedVar)
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::AllVariableUsesDefined.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    # Should detect the undefined variable even though fragmentC is referenced twice
    runtime.errors.size.should eq(1)
    runtime.errors.first.message.should match(/Variable "\$undefinedVar" is not defined/)
  end
end

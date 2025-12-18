require "../../spec_helper"

describe Oxide::Validation::FragmentNameUniqueness do
  describe "example #146" do
    it "accepts unique fragment names" do
      query_string = <<-QUERY
        {
          dog {
            ...fragmentOne
            ...fragmentTwo
          }
        }

        fragment fragmentOne on Dog {
          name
        }

        fragment fragmentTwo on Dog {
          owner {
            name
          }
        }
      QUERY

      query = Oxide::Query.new(query_string)

      runtime = Oxide::Validation::Runtime.new(
        ValidationsSchema,
        query,
        [Oxide::Validation::FragmentNameUniqueness.new.as(Oxide::Validation::Rule)]
      )

      runtime.execute
      runtime.errors.should be_empty
    end
  end

  describe "counter example #147" do
    it "rejects duplicate fragment names" do
      query_string = <<-QUERY
        {
          dog {
            ...fragmentOne
          }
        }

        fragment fragmentOne on Dog {
          name
        }

        fragment fragmentOne on Dog {
          owner {
            name
          }
        }
      QUERY

      query = Oxide::Query.new(query_string)

      runtime = Oxide::Validation::Runtime.new(
        ValidationsSchema,
        query,
        [Oxide::Validation::FragmentNameUniqueness.new.as(Oxide::Validation::Rule)]
      )

      runtime.execute

      runtime.errors.size.should eq(1)
      runtime.errors.first.message.should match(/fragmentOne/)
    end
  end

  it "accepts fragments with different names" do
    query_string = <<-QUERY
      fragment dogName on Dog {
        name
      }

      fragment dogOwner on Dog {
        owner {
          name
        }
      }

      fragment dogNickname on Dog {
        nickname
      }

      {
        dog {
          ...dogName
          ...dogOwner
          ...dogNickname
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::FragmentNameUniqueness.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute
    runtime.errors.should be_empty
  end

  it "rejects multiple fragments with same name" do
    query_string = <<-QUERY
      fragment sameName on Dog {
        name
      }

      fragment sameName on Dog {
        nickname
      }

      fragment sameName on Dog {
        barkVolume
      }

      {
        dog {
          ...sameName
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::FragmentNameUniqueness.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should be > 0
    runtime.errors.first.message.should match(/one fragment named.*sameName|sameName.*unique/i)
  end

  it "allows fragments with similar but different names" do
    query_string = <<-QUERY
      fragment dogInfo on Dog {
        name
      }

      fragment dog_info on Dog {
        nickname
      }

      fragment dogInfo1 on Dog {
        barkVolume
      }

      {
        dog {
          ...dogInfo
          ...dog_info
          ...dogInfo1
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::FragmentNameUniqueness.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute
    runtime.errors.should be_empty
  end
end
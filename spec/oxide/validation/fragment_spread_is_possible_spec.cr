require "../../spec_helper"

describe Oxide::Validation::FragmentSpreadIsPossible do
  describe "object spreads in object scope" do
    it "accepts fragment on same object type" do
      query_string = <<-QUERY
        fragment dogFragment on Dog {
          name
        }

        {
          dog {
            ...dogFragment
          }
        }
      QUERY

      query = Oxide::Query.new(query_string)

      runtime = Oxide::Validation::Runtime.new(
        ValidationsSchema,
        query,
        [Oxide::Validation::FragmentSpreadIsPossible.new.as(Oxide::Validation::Rule)]
      )

      runtime.execute
      runtime.errors.should be_empty
    end

    it "rejects fragment on different object type with no common interface" do
      query_string = <<-QUERY
        fragment catFragment on Cat {
          name
        }

        {
          dog {
            ...catFragment
          }
        }
      QUERY

      query = Oxide::Query.new(query_string)

      runtime = Oxide::Validation::Runtime.new(
        ValidationsSchema,
        query,
        [Oxide::Validation::FragmentSpreadIsPossible.new.as(Oxide::Validation::Rule)]
      )

      runtime.execute

      runtime.errors.size.should be >= 1
      runtime.errors.first.message.should match(/Dog.*Cat|Cat.*Dog/i)
    end
  end

  describe "abstract spreads in object scope" do
    it "accepts fragment on implemented interface" do
      query_string = <<-QUERY
        fragment petFragment on Pet {
          name
        }

        {
          dog {
            ...petFragment
          }
        }
      QUERY

      query = Oxide::Query.new(query_string)

      runtime = Oxide::Validation::Runtime.new(
        ValidationsSchema,
        query,
        [Oxide::Validation::FragmentSpreadIsPossible.new.as(Oxide::Validation::Rule)]
      )

      runtime.execute
      runtime.errors.should be_empty
    end

    it "accepts fragment on union containing the object type" do
      query_string = <<-QUERY
        fragment catOrDogFragment on CatOrDog {
          ... on Dog {
            name
          }
        }

        {
          dog {
            ...catOrDogFragment
          }
        }
      QUERY

      query = Oxide::Query.new(query_string)

      runtime = Oxide::Validation::Runtime.new(
        ValidationsSchema,
        query,
        [Oxide::Validation::FragmentSpreadIsPossible.new.as(Oxide::Validation::Rule)]
      )

      runtime.execute
      runtime.errors.should be_empty
    end

    it "rejects fragment on non-implemented interface" do
      query_string = <<-QUERY
        fragment sentientFragment on Sentient {
          name
        }

        {
          dog {
            ...sentientFragment
          }
        }
      QUERY

      query = Oxide::Query.new(query_string)

      runtime = Oxide::Validation::Runtime.new(
        ValidationsSchema,
        query,
        [Oxide::Validation::FragmentSpreadIsPossible.new.as(Oxide::Validation::Rule)]
      )

      runtime.execute

      runtime.errors.size.should be >= 1
      runtime.errors.first.message.should match(/Dog.*Sentient|Sentient.*Dog/i)
    end
  end

  describe "object spreads in abstract scope" do
    it "accepts object fragment when parent is interface implemented by that object" do
      query_string = <<-QUERY
        fragment dogFragment on Dog {
          name
          barkVolume
        }

        {
          pet {
            ...dogFragment
          }
        }
      QUERY

      query = Oxide::Query.new(query_string)

      runtime = Oxide::Validation::Runtime.new(
        ValidationsSchema,
        query,
        [Oxide::Validation::FragmentSpreadIsPossible.new.as(Oxide::Validation::Rule)]
      )

      runtime.execute
      runtime.errors.should be_empty
    end

    it "accepts object fragment when parent is union containing that object" do
      query_string = <<-QUERY
        fragment dogFragment on Dog {
          name
        }

        {
          catOrDog {
            ...dogFragment
          }
        }
      QUERY

      query = Oxide::Query.new(query_string)

      runtime = Oxide::Validation::Runtime.new(
        ValidationsSchema,
        query,
        [Oxide::Validation::FragmentSpreadIsPossible.new.as(Oxide::Validation::Rule)]
      )

      runtime.execute
      runtime.errors.should be_empty
    end

    it "rejects object fragment when not in union or implementing interface" do
      query_string = <<-QUERY
        fragment humanFragment on Human {
          name
        }

        {
          pet {
            ...humanFragment
          }
        }
      QUERY

      query = Oxide::Query.new(query_string)

      runtime = Oxide::Validation::Runtime.new(
        ValidationsSchema,
        query,
        [Oxide::Validation::FragmentSpreadIsPossible.new.as(Oxide::Validation::Rule)]
      )

      runtime.execute

      runtime.errors.size.should be >= 1
      runtime.errors.first.message.should match(/Pet.*Human|Human.*Pet/i)
    end
  end

  describe "abstract spreads in abstract scope" do
    it "accepts interface fragment when parent interface is implemented by same objects" do
      # Assuming both Pet and Being might be implemented by the same types
      query_string = <<-QUERY
        fragment petFragment on Pet {
          name
        }

        {
          catOrDog {
            ...petFragment
          }
        }
      QUERY

      query = Oxide::Query.new(query_string)

      runtime = Oxide::Validation::Runtime.new(
        ValidationsSchema,
        query,
        [Oxide::Validation::FragmentSpreadIsPossible.new.as(Oxide::Validation::Rule)]
      )

      runtime.execute
      runtime.errors.should be_empty
    end

    it "accepts overlapping union fragments" do
      query_string = <<-QUERY
        fragment catOrDogFragment on CatOrDog {
          ... on Dog {
            name
          }
        }

        {
          pet {
            ...catOrDogFragment
          }
        }
      QUERY

      query = Oxide::Query.new(query_string)

      runtime = Oxide::Validation::Runtime.new(
        ValidationsSchema,
        query,
        [Oxide::Validation::FragmentSpreadIsPossible.new.as(Oxide::Validation::Rule)]
      )

      runtime.execute
      runtime.errors.should be_empty
    end
  end

  describe "inline fragments" do
    it "accepts inline fragment on same object type" do
      query_string = <<-QUERY
        {
          dog {
            ... on Dog {
              name
              barkVolume
            }
          }
        }
      QUERY

      query = Oxide::Query.new(query_string)

      runtime = Oxide::Validation::Runtime.new(
        ValidationsSchema,
        query,
        [Oxide::Validation::FragmentSpreadIsPossible.new.as(Oxide::Validation::Rule)]
      )

      runtime.execute
      runtime.errors.should be_empty
    end

    it "accepts inline fragment on implemented interface" do
      query_string = <<-QUERY
        {
          dog {
            ... on Pet {
              name
            }
          }
        }
      QUERY

      query = Oxide::Query.new(query_string)

      runtime = Oxide::Validation::Runtime.new(
        ValidationsSchema,
        query,
        [Oxide::Validation::FragmentSpreadIsPossible.new.as(Oxide::Validation::Rule)]
      )

      runtime.execute
      runtime.errors.should be_empty
    end

    it "rejects inline fragment on incompatible type" do
      query_string = <<-QUERY
        {
          dog {
            ... on Cat {
              meowVolume
            }
          }
        }
      QUERY

      query = Oxide::Query.new(query_string)

      runtime = Oxide::Validation::Runtime.new(
        ValidationsSchema,
        query,
        [Oxide::Validation::FragmentSpreadIsPossible.new.as(Oxide::Validation::Rule)]
      )

      runtime.execute

      runtime.errors.size.should be >= 1
      runtime.errors.first.message.should match(/Dog.*Cat|Cat.*Dog/i)
    end

    it "accepts inline fragment without type condition" do
      query_string = <<-QUERY
        {
          dog {
            ... {
              name
            }
          }
        }
      QUERY

      query = Oxide::Query.new(query_string)

      runtime = Oxide::Validation::Runtime.new(
        ValidationsSchema,
        query,
        [Oxide::Validation::FragmentSpreadIsPossible.new.as(Oxide::Validation::Rule)]
      )

      runtime.execute
      runtime.errors.should be_empty
    end
  end

  describe "interface implementations" do
    it "accepts fragment on interface when parent implements that interface" do
      query_string = <<-QUERY
        fragment petFragment on Pet {
          name
        }

        {
          dog {
            ...petFragment
          }
        }
      QUERY

      query = Oxide::Query.new(query_string)

      runtime = Oxide::Validation::Runtime.new(
        ValidationsSchema,
        query,
        [Oxide::Validation::FragmentSpreadIsPossible.new.as(Oxide::Validation::Rule)]
      )

      runtime.execute
      runtime.errors.should be_empty
    end
  end

  describe "union type spreads" do
    it "accepts fragment when object is in union" do
      query_string = <<-QUERY
        fragment catOrDogFragment on CatOrDog {
          ... on Dog {
            name
          }
        }

        {
          dog {
            ...catOrDogFragment
          }
        }
      QUERY

      query = Oxide::Query.new(query_string)

      runtime = Oxide::Validation::Runtime.new(
        ValidationsSchema,
        query,
        [Oxide::Validation::FragmentSpreadIsPossible.new.as(Oxide::Validation::Rule)]
      )

      runtime.execute
      runtime.errors.should be_empty
    end
  end
end

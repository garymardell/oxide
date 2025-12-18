require "../../spec_helper"

describe Oxide::Validation::FragmentSpreadsMusNotFormCycles do
  describe "counter example #155" do
    it "detects direct cycle - fragment spreading itself" do
      query_string = <<-QUERY
        fragment nameFragment on Dog {
          name
          ...nameFragment
        }

        {
          dog {
            ...nameFragment
          }
        }
      QUERY

      query = Oxide::Query.new(query_string)

      runtime = Oxide::Validation::Runtime.new(
        ValidationsSchema,
        query,
        [Oxide::Validation::FragmentSpreadsMusNotFormCycles.new.as(Oxide::Validation::Rule)]
      )

      runtime.execute

      runtime.errors.size.should be >= 1
      runtime.errors.first.message.should match(/nameFragment.*cycle|cycle.*nameFragment/i)
    end
  end

  describe "counter example #156" do
    it "detects indirect cycle through one intermediate fragment" do
      query_string = <<-QUERY
        fragment dogFragment on Dog {
          name
          ...ownerFragment
        }

        fragment ownerFragment on Dog {
          owner {
            name
            ...dogFragment
          }
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
        [Oxide::Validation::FragmentSpreadsMusNotFormCycles.new.as(Oxide::Validation::Rule)]
      )

      runtime.execute

      runtime.errors.size.should be >= 1
      error_messages = runtime.errors.map(&.message).join(" ")
      error_messages.should match(/cycle/i)
    end
  end

  describe "counter example #157" do
    it "detects cycle through multiple intermediate fragments" do
      query_string = <<-QUERY
        fragment fragA on Dog {
          ...fragB
        }

        fragment fragB on Dog {
          ...fragC
        }

        fragment fragC on Dog {
          ...fragA
        }

        {
          dog {
            ...fragA
          }
        }
      QUERY

      query = Oxide::Query.new(query_string)

      runtime = Oxide::Validation::Runtime.new(
        ValidationsSchema,
        query,
        [Oxide::Validation::FragmentSpreadsMusNotFormCycles.new.as(Oxide::Validation::Rule)]
      )

      runtime.execute

      runtime.errors.size.should be >= 1
      error_messages = runtime.errors.map(&.message).join(" ")
      error_messages.should match(/cycle/i)
    end
  end

  it "accepts fragments with no cycles" do
    query_string = <<-QUERY
      fragment nameFragment on Dog {
        name
      }

      fragment dogFragment on Dog {
        ...nameFragment
        barkVolume
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
      [Oxide::Validation::FragmentSpreadsMusNotFormCycles.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute
    runtime.errors.should be_empty
  end

  it "accepts queries with no fragments" do
    query_string = <<-QUERY
      {
        dog {
          name
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::FragmentSpreadsMusNotFormCycles.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute
    runtime.errors.should be_empty
  end

  it "accepts fragments spreading the same fragment multiple times (diamond pattern)" do
    query_string = <<-QUERY
      fragment nameFragment on Dog {
        name
      }

      fragment fragA on Dog {
        ...nameFragment
        barkVolume
      }

      fragment fragB on Dog {
        ...nameFragment
        owner {
          name
        }
      }

      fragment topFragment on Dog {
        ...fragA
        ...fragB
      }

      {
        dog {
          ...topFragment
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::FragmentSpreadsMusNotFormCycles.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute
    runtime.errors.should be_empty
  end

  it "accepts fragments with deep nesting but no cycles" do
    query_string = <<-QUERY
      fragment frag1 on Dog {
        name
      }

      fragment frag2 on Dog {
        ...frag1
      }

      fragment frag3 on Dog {
        ...frag2
      }

      fragment frag4 on Dog {
        ...frag3
      }

      {
        dog {
          ...frag4
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::FragmentSpreadsMusNotFormCycles.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute
    runtime.errors.should be_empty
  end

  it "detects self-reference through inline fragment" do
    query_string = <<-QUERY
      fragment nameFragment on Dog {
        ... on Dog {
          ...nameFragment
        }
      }

      {
        dog {
          ...nameFragment
        }
      }
    QUERY

    query = Oxide::Query.new(query_string)

    runtime = Oxide::Validation::Runtime.new(
      ValidationsSchema,
      query,
      [Oxide::Validation::FragmentSpreadsMusNotFormCycles.new.as(Oxide::Validation::Rule)]
    )

    runtime.execute

    runtime.errors.size.should be >= 1
    runtime.errors.first.message.should match(/nameFragment.*cycle|cycle.*nameFragment/i)
  end
end

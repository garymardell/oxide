require "../../spec_helper"

describe Oxide::Utils::SuggestionList do
  describe ".suggest" do
    it "returns empty array when no options provided" do
      result = Oxide::Utils::SuggestionList.suggest("input", [] of String)
      result.should eq([] of String)
    end

    it "returns exact matches" do
      options = ["apple", "banana", "apricot"]
      result = Oxide::Utils::SuggestionList.suggest("apple", options)
      result.should eq(["apple"])
    end

    it "handles case-insensitive matching" do
      options = ["Apple", "BANANA", "aPrIcOt"]
      result = Oxide::Utils::SuggestionList.suggest("apple", options)
      result.should eq(["Apple"])
    end

    it "suggests similar options with single character typo" do
      options = ["apple", "banana", "apricot"]
      result = Oxide::Utils::SuggestionList.suggest("aple", options)
      result.should contain("apple")
    end

    it "suggests options with transposed characters" do
      options = ["apple", "banana", "apricot"]
      result = Oxide::Utils::SuggestionList.suggest("aplpe", options)
      result.should contain("apple")
    end

    it "suggests options with extra character" do
      options = ["apple", "banana", "apricot"]
      result = Oxide::Utils::SuggestionList.suggest("appple", options)
      result.should contain("apple")
    end

    it "suggests options with missing character" do
      options = ["apple", "banana", "apricot"]
      result = Oxide::Utils::SuggestionList.suggest("appl", options)
      result.should contain("apple")
    end

    it "respects 40% threshold" do
      options = ["apple", "banana", "zebra"]
      # "xyz" has length 3, threshold = (3 * 0.4).to_i + 1 = 2
      # "apple" has distance 5, "banana" has distance 6, "zebra" has distance 5
      result = Oxide::Utils::SuggestionList.suggest("xyz", options)
      result.should eq([] of String)
    end

    it "filters out options beyond threshold" do
      options = ["a", "ab", "abc", "verylongstring"]
      # "a" has distance 0, "ab" has distance 1, "abc" has distance 2
      # "verylongstring" has distance 13 (too far)
      result = Oxide::Utils::SuggestionList.suggest("a", options)
      result.should contain("a")
      result.should_not contain("verylongstring")
    end

    it "sorts results by distance then alphabetically" do
      options = ["frog", "dog", "cat"]
      # "og" -> "dog" distance 1, "frog" distance 2, "cat" distance 3
      result = Oxide::Utils::SuggestionList.suggest("og", options)
      result[0].should eq("dog")
    end

    it "sorts alphabetically when distances are equal" do
      options = ["car", "bar", "far"]
      # All have distance 1 from "ar"
      result = Oxide::Utils::SuggestionList.suggest("ar", options)
      result[0].should eq("bar")
      result[1].should eq("car")
      result[2].should eq("far")
    end

    it "returns maximum 5 suggestions" do
      options = ["a1", "a2", "a3", "a4", "a5", "a6", "a7", "a8"]
      result = Oxide::Utils::SuggestionList.suggest("a", options)
      result.size.should be <= 5
    end

    it "handles empty input string" do
      options = ["apple", "banana"]
      result = Oxide::Utils::SuggestionList.suggest("", options)
      # Empty string should have high distance to all options
      result.should eq([] of String)
    end

    it "handles options with different lengths" do
      options = ["a", "aa", "aaa", "aaaa"]
      result = Oxide::Utils::SuggestionList.suggest("aa", options)
      result.should contain("aa")
    end

    context "GraphQL field name suggestions" do
      it "suggests similar field names" do
        options = ["id", "name", "email", "username", "userId"]
        result = Oxide::Utils::SuggestionList.suggest("user", options)
        result.should contain("userId")
      end

      it "suggests field with typo" do
        options = ["barkVolume", "meowVolume", "woofSound"]
        result = Oxide::Utils::SuggestionList.suggest("meowVolume", options)
        result.should contain("meowVolume")
      end
    end

    context "GraphQL type name suggestions" do
      it "suggests similar type names" do
        options = ["User", "UserProfile", "UserSettings"]
        result = Oxide::Utils::SuggestionList.suggest("Usr", options)
        result.should contain("User")
      end
    end

    context "GraphQL directive suggestions" do
      it "suggests similar directives" do
        options = ["skip", "include", "deprecated"]
        result = Oxide::Utils::SuggestionList.suggest("skipp", options)
        result[0].should eq("skip")
      end
    end

    context "GraphQL enum value suggestions" do
      it "suggests similar enum values" do
        options = ["RED", "GREEN", "BLUE"]
        result = Oxide::Utils::SuggestionList.suggest("GREN", options)
        result[0].should eq("GREEN")
      end
    end
  end

  describe ".did_you_mean_message" do
    it "returns nil for empty suggestions" do
      result = Oxide::Utils::SuggestionList.did_you_mean_message([] of String)
      result.should be_nil
    end

    it "formats single suggestion" do
      result = Oxide::Utils::SuggestionList.did_you_mean_message(["apple"])
      result.should eq(%( Did you mean "apple"?))
    end

    it "formats two suggestions with 'or'" do
      result = Oxide::Utils::SuggestionList.did_you_mean_message(["apple", "banana"])
      result.should eq(%( Did you mean "apple" or "banana"?))
    end

    it "formats three suggestions with commas and 'or'" do
      result = Oxide::Utils::SuggestionList.did_you_mean_message(["apple", "banana", "cherry"])
      result.should eq(%( Did you mean "apple", "banana", or "cherry"?))
    end

    it "formats four suggestions with commas and 'or'" do
      result = Oxide::Utils::SuggestionList.did_you_mean_message(["apple", "banana", "cherry", "date"])
      result.should eq(%( Did you mean "apple", "banana", "cherry", or "date"?))
    end

    it "formats five suggestions with commas and 'or'" do
      result = Oxide::Utils::SuggestionList.did_you_mean_message(["a", "b", "c", "d", "e"])
      result.should eq(%( Did you mean "a", "b", "c", "d", or "e"?))
    end
  end
end

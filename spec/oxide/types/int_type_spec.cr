require "../../spec_helper"

def build_int_type
  Oxide::Types::IntType.new
end

describe Oxide::Types::IntType do
  describe "#coerce" do
    it "accepts Int32 values" do
      build_int_type.coerce(DummySchema, 1234567i32).should eq(1234567i32)
    end

    it "accepts Int64 values if converable to Int32" do
      build_int_type.coerce(DummySchema, 1234567i64).should eq(1234567)
    end

    it "raises exception on non integer type" do
      expect_raises(Oxide::InputCoercionError) do
        build_int_type.coerce(DummySchema, "2134543")
      end

      expect_raises(Oxide::InputCoercionError) do
        build_int_type.coerce(DummySchema, 23.4)
      end
    end
  end

  describe "#serialize" do
    it "converts string numbers into integer" do
      build_int_type.serialize("123").should eq(123)
    end

    it "raises an error if can't serialize to int" do
      expect_raises(Oxide::SerializationError) do
        build_int_type.serialize("hello")
      end
    end

    it "converts floats into integer" do
      build_int_type.serialize(1.0).should eq(1)
    end

    it "raises an error if float cannot be converted without precision loss" do
      expect_raises(Oxide::SerializationError) do
        build_int_type.serialize(1.2)
      end
    end

    it "raises an error if values is greater than Int32::MAX" do
      expect_raises(Oxide::SerializationError) do
        build_int_type.serialize(Int32::MAX.to_i64 + 1)
      end
    end

    it "raises an error if values is less than Int32::MIN" do
      expect_raises(Oxide::SerializationError) do
        build_int_type.serialize(Int32::MIN.to_i64 - 1)
      end
    end
  end
end

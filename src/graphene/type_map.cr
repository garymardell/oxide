require "./visitor"

module Graphene
  class TypeMap < Visitor
    private property schema : Graphene::Schema
    private property type_map : Hash(String, Graphene::Type)

    def initialize(@schema)
      @type_map = {} of String => Graphene::Type
    end

    def generate
      roots = [schema.query, schema.orphan_types].flatten
      roots.each do |type|
        type.accept(self)
      end

      type_map
    end

    def visit(type : Graphene::Types::ObjectType)
      previous_type = type_map.fetch(type.name, nil)

      if previous_type.nil?
        type_map[type.name] = type
      end

      type.interfaces.each do |interface|
        interface.accept(self)
      end

      type.fields.each do |name, field|
        field.type.accept(self)

        field.arguments.each do |argument|
          argument.type.accept(self)
        end
      end
    end

    def visit(type : Graphene::Types::InterfaceType)
      type_map[type.name] = type

      type.fields.each do |name, field|
        field.type.accept(self)

        field.arguments.each do |argument|
          argument.type.accept(self)
        end
      end
    end

    def visit(type : Graphene::Types::UnionType)
      type.possible_types.each do |possible_type|
        possible_type.accept(self)
      end
    end

    def visit(type : Graphene::Types::NonNullType)
      type.of_type.accept(self)
    end

    def visit(type : Graphene::Types::ListType)
      type.of_type.accept(self)
    end

    def visit(type : Graphene::Types::ScalarType)
      type_map[type.name] = type
    end

    def visit(type : Graphene::Types::EnumType)
      type_map[type.name] = type
    end
  end
end
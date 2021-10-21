require "./visitor"

module Graphene
  class Schema
    class Types < Visitor
      private property schema : Graphene::Schema
      private property types : Hash(String, Graphene::Type)

      def initialize(@schema)
        @types = {} of String => Graphene::Type
      end

      def generate
        roots = [schema.query, schema.orphan_types].flatten
        roots.each do |type|
          type.accept(self)
        end

        types.values
      end

      def visit(type : Graphene::Type::Object)
        types[type.typename] = type

        # TODO: Interfaces
        type.implements.each do |interface|
          interface.accept(self)
        end

        type.fields.each do |field|
          field.type.accept(self)

          field.arguments.each do |argument|
            argument.type.accept(self)
          end
        end
      end

      def visit(type : Graphene::Type::Interface)
        types[type.name] = type

        type.fields.each do |field|
          field.type.accept(self)

          field.arguments.each do |argument|
            argument.type.accept(self)
          end
        end
      end

      def visit(type : Graphene::Type::Union)
        types[type.typename] = type

        type.possible_types.each do |possible_type|
          possible_type.accept(self)
        end
      end

      def visit(type : Graphene::Type::Enum)
        # types << type
        types[type.typename] = type
      end

      def visit(type : Graphene::Type::NonNull)
        type.of_type.accept(self)
      end

      def visit(type : Graphene::Type::List)
        type.of_type.accept(self)
      end

      def visit(type : Graphene::Type::Scalar)
        types[type.name] = type
      end
    end
  end
end
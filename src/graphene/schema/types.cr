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

      def visit(type : Graphene::Types::Object)
        types[type.name] = type

        type.interfaces.each do |interface|
          interface.accept(self)
        end

        type.fields.each do |field|
          field.type.accept(self)

          field.arguments.each do |argument|
            argument.type.accept(self)
          end
        end
      end

      def visit(type : Graphene::Types::Interface)
        types[type.name] = type

        type.fields.each do |field|
          field.type.accept(self)

          field.arguments.each do |argument|
            argument.type.accept(self)
          end
        end
      end

      def visit(type : Graphene::Types::Union)
        types[type.name] = type

        type.possible_types.each do |possible_type|
          possible_type.accept(self)
        end
      end

      def visit(type : Graphene::Types::Enum)
        # types << type
        types[type.name] = type
      end

      def visit(type : Graphene::Types::NonNull)
        type.of_type.accept(self)
      end

      def visit(type : Graphene::Types::List)
        type.of_type.accept(self)
      end

      def visit(type : Graphene::Types::Scalar)
        types[type.name] = type
      end
    end
  end
end
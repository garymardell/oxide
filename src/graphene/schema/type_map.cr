require "./visitor"

module Graphene
  class Schema
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

      def visit(type : Graphene::Type::Object)
        previous_type = type_map.fetch(type.name, nil)

        if previous_type.nil?
          type_map[type.name] = type
        end

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
        type.fields.each do |field|
          field.type.accept(self)

          field.arguments.each do |argument|
            argument.type.accept(self)
          end
        end
      end

      def visit(type : Graphene::Type::Union)
        type.possible_types.each do |possible_type|
          possible_type.accept(self)
        end
      end

      def visit(type : Graphene::Type::NonNull)
        type.of_type.accept(self)
      end

      def visit(type : Graphene::Type::List)
        type.of_type.accept(self)
      end

      def visit(type : Graphene::Type::Scalar)
        type_map[type.name] = type
      end
    end
  end
end
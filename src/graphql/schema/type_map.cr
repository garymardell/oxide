require "./visitor"

module Graphql
  class Schema
    class TypeMap < Visitor
      private property schema : Graphql::Schema
      private property type_map : Hash(String, Graphql::Type)

      def initialize(@schema)
        @type_map = {} of String => Graphql::Type
      end

      def generate
        roots = [schema.query, schema.orphan_types].flatten
        roots.each do |type|
          type.accept(self)
        end

        type_map
      end

      def visit(type : Graphql::Type::Object)
        previous_type = type_map.fetch(type.typename, nil)

        if previous_type.nil?
          type_map[type.typename] = type
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

      def visit(type : Graphql::Type::Interface)
        type.fields.each do |field|
          field.type.accept(self)

          field.arguments.each do |argument|
            argument.type.accept(self)
          end
        end
      end

      def visit(type : Graphql::Type::Union)
        type.possible_types.each do |possible_type|
          possible_type.accept(self)
        end
      end

      def visit(type : Graphql::Type::NonNull)
        type.of_type.accept(self)
      end

      def visit(type : Graphql::Type::List)
        type.of_type.accept(self)
      end

      def visit(type : Graphql::Type::Scalar)
        type_map[type.name] = type
      end
    end
  end
end
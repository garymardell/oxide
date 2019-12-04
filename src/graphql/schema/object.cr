module Graphql
  class Schema
    class Object < Member
      @@fields = {} of Symbol => Graphql::Schema::Field

      macro field(name, type, null, description)
        @@fields[{{name}}] = Graphql::Schema::Field.new(
          name: {{name}},
          type: {{type}},
          null: {{null}},
          description: {{description}}
        )
      end

      def self.fields
        @@fields
      end

      # property fields : Hash(Symbol, Graphql::Schema::Field) # TODO: Class method?
      #
      # def initialize
      #   @fields = {} of Symbol => Graphql::Schema::Field
      # end
      #
      # def add_field(field)
      #   @fields[field.name] = field
      # end
    end
  end
end

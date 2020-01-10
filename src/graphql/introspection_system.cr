module Graphql
  class IntrospectionSystem
    @@types = {} of String => Graphql::Type

    def self.register_type(typename, type)
      @@types[typename] = type
    end

    def self.types
      @@types
    end
  end
end
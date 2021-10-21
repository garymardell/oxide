module Graphene
  module Language
    module Visitable
      abstract def accept(visitor : Visitor)
    end
  end
end
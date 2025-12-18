module Oxide
  module Directives
    OneOfDirective = Oxide::Directive.new(
      name: "oneOf",
      description: "Indicates an Input Object is a OneOf Input Object (exactly one field must be provided).",
      locations: [Oxide::Directive::Location::INPUT_OBJECT],
      arguments: {} of String => Oxide::Argument,
      repeatable: false
    )
  end
end

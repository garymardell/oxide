require "kemal"
require "./schema"

post "/graphql" do |env|
  env.response.content_type = "application/json"

  variables = extract_variables(env.params)

  query = Graphene::Query.new(
    env.params.json["query"].as(String),
    variables: variables
  )

  runtime = Graphene::Execution::Runtime.new(
    DummySchema,
    query
  )

  runtime.execute.to_json
end

def extract_variables(params)
  variables = params.json["variables"]?

  case variables
  when Hash
    variables
  else
    {} of String => JSON::Any
  end
end

Kemal.run
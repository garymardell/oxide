@[Link("graphqlparser")]
lib LibGraphqlParser

  type GraphQLAstNode = Void*
  type GraphQLAstField = Void*
  type GraphQLAstName = Void*

  struct GraphQLAstLocation
    beginLine : Int32
    beginColumn : Int32
    endLine : Int32
    endColumn : Int32
  end

  struct GraphQLAstVisitorCallbacks
    visit_document : (GraphQLAstNode, Void* -> Int32)
    end_visit_document : (GraphQLAstNode, Void* ->)

    visit_operation_definition : (GraphQLAstNode, Void* -> Int32)
    end_visit_operation_definition : (GraphQLAstNode, Void* ->)

    visit_variable_definition :(GraphQLAstNode, Void* -> Int32)
    end_visit_variable_definition : (GraphQLAstNode, Void* ->)

    visit_selection_set :(GraphQLAstNode, Void* -> Int32)
    end_visit_selection_set : (GraphQLAstNode, Void* ->)

    visit_field : (GraphQLAstField, Void* -> Int32)
    end_visit_field : (GraphQLAstField, Void* ->)

    visit_argument : (GraphQLAstNode, Void* -> Int32)
    end_visit_argument : (GraphQLAstNode, Void* ->)

    visit_fragment_spread : (GraphQLAstNode, Void* -> Int32)
    end_visit_fragment_spread : (GraphQLAstNode, Void* ->)

    visit_inline_fragment : (GraphQLAstNode, Void* -> Int32)
    end_visit_inline_fragment : (GraphQLAstNode, Void* ->)

    visit_fragment_definition : (GraphQLAstNode, Void* -> Int32)
    end_visit_fragment_definition : (GraphQLAstNode, Void* ->)

    visit_variable : (GraphQLAstNode, Void* -> Int32)
    end_visit_variable : (GraphQLAstNode, Void* ->)

    visit_int_value : (GraphQLAstNode, Void* -> Int32)
    end_visit_int_value : (GraphQLAstNode, Void* ->)

    visit_float_value : (GraphQLAstNode, Void* -> Int32)
    end_visit_float_value : (GraphQLAstNode, Void* ->)

    visit_string_value : (GraphQLAstNode, Void* -> Int32)
    end_visit_string_value : (GraphQLAstNode, Void* ->)

    visit_boolean_value : (GraphQLAstNode, Void* -> Int32)
    end_visit_boolean_value : (GraphQLAstNode, Void* ->)

    visit_null_value : (GraphQLAstNode, Void* -> Int32)
    end_visit_null_value : (GraphQLAstNode, Void* ->)

    visit_enum_value : (GraphQLAstNode, Void* -> Int32)
    end_visit_enum_value : (GraphQLAstNode, Void* ->)

    visit_list_value : (GraphQLAstNode, Void* -> Int32)
    end_visit_list_value : (GraphQLAstNode, Void* ->)

    visit_object_value : (GraphQLAstNode, Void* -> Int32)
    end_visit_object_value : (GraphQLAstNode, Void* ->)

    visit_object_field : (GraphQLAstNode, Void* -> Int32)
    end_visit_object_field : (GraphQLAstNode, Void* ->)

    visit_directive : (GraphQLAstNode, Void* -> Int32)
    end_visit_directive : (GraphQLAstNode, Void* ->)

    visit_named_type : (GraphQLAstNode, Void* -> Int32)
    end_visit_named_type : (GraphQLAstNode, Void* ->)

    visit_list_type : (GraphQLAstNode, Void* -> Int32)
    end_visit_list_type : (GraphQLAstNode, Void* ->)

    visit_non_null_type : (GraphQLAstNode, Void* -> Int32)
    end_visit_non_null_type : (GraphQLAstNode, Void* ->)

    visit_name : (GraphQLAstNode, Void* -> Int32)
    end_visit_name : (GraphQLAstNode, Void* ->)

    visit_schema_definition : (GraphQLAstNode, Void* -> Int32)
    end_visit_schema_definition : (GraphQLAstNode, Void* ->)

    visit_operation_type_definition : (GraphQLAstNode, Void* -> Int32)
    end_visit_operation_type_definition : (GraphQLAstNode, Void* ->)

    visit_scalar_type_definition : (GraphQLAstNode, Void* -> Int32)
    end_visit_scalar_type_definition : (GraphQLAstNode, Void* ->)

    visit_object_type_definition : (GraphQLAstNode, Void* -> Int32)
    end_visit_object_type_definition : (GraphQLAstNode, Void* ->)

    visit_field_definition : (GraphQLAstNode, Void* -> Int32)
    end_visit_field_definition : (GraphQLAstNode, Void* ->)

    visit_input_value_definition : (GraphQLAstNode, Void* -> Int32)
    end_visit_input_value_definition : (GraphQLAstNode, Void* ->)

    visit_interface_type_definition : (GraphQLAstNode, Void* -> Int32)
    end_visit_interface_type_definition : (GraphQLAstNode, Void* ->)

    visit_union_type_definition : (GraphQLAstNode, Void* -> Int32)
    end_visit_union_type_definition : (GraphQLAstNode, Void* ->)

    visit_enum_type_definition : (GraphQLAstNode, Void* -> Int32)
    end_visit_enum_type_definition : (GraphQLAstNode, Void* ->)

    visit_enum_value_definition : (GraphQLAstNode, Void* -> Int32)
    end_visit_enum_value_definition : (GraphQLAstNode, Void* ->)

    visit_input_object_type_definition : (GraphQLAstNode, Void* -> Int32)
    end_visit_input_object_type_definition : (GraphQLAstNode, Void* ->)

    visit_type_extension_definition : (GraphQLAstNode, Void* -> Int32)
    end_visit_type_extension_definitionn : (GraphQLAstNode, Void* ->)

    visit_directive_definition : (GraphQLAstNode, Void* -> Int32)
    end_visit_directive_definition : (GraphQLAstNode, Void* ->)
  end

  fun parse_string = graphql_parse_string(context : LibC::Char*, error : LibC::Char**) : GraphQLAstNode
  fun error_free = graphql_error_free(error : LibC::Char*)

  fun node_visit = graphql_node_visit(node : GraphQLAstNode, callbacks : GraphQLAstVisitorCallbacks*, userData : Void*)

  fun node_get_location = graphql_node_get_location(node : GraphQLAstNode*, location : GraphQLAstLocation*)
  fun node_free = graphql_node_free(node : GraphQLAstNode*)

  fun GraphQLAstOperationDefinition_get_name(node : GraphQLAstNode) : GraphQLAstName
  fun GraphQLAstOperationDefinition_get_operation(node : GraphQLAstNode) : LibC::Char*
  fun GraphQLAstField_get_name(node : GraphQLAstField) : GraphQLAstName
  fun GraphQLAstName_get_value(node : GraphQLAstName) : LibC::Char*

  fun GraphQLAstArgument_get_name(node : GraphQLAstNode) : GraphQLAstName
  fun GraphQLAstVariable_get_name(node : GraphQLAstNode) : GraphQLAstName

  fun GraphQLAstIntValue_get_value(node : GraphQLAstNode) : LibC::Char*
end
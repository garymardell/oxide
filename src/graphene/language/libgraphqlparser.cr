@[Link("graphqlparser")]
lib LibGraphqlParser

  type GraphQLAstNode = Void*
  type GraphQLAstDocument = Void*
  type GraphQLAstOperationDefinition = Void*
  type GraphQLAstVariableDefinition = Void*
  type GraphQLAstSelectionSet = Void*
  type GraphQLAstField = Void*
  type GraphQLAstArgument = Void*
  type GraphQLAstFragmentSpread = Void*
  type GraphQLAstInlineFragment = Void*
  type GraphQLAstFragmentDefinition = Void*
  type GraphQLAstVariable = Void*
  type GraphQLAstIntValue = Void*
  type GraphQLAstFloatValue = Void*
  type GraphQLAstStringValue = Void*
  type GraphQLAstBooleanValue = Void*
  type GraphQLAstNullValue = Void*
  type GraphQLAstEnumValue = Void*
  type GraphQLAstListValue = Void*
  type GraphQLAstObjectValue = Void*
  type GraphQLAstObjectField = Void*
  type GraphQLAstDirective = Void*
  type GraphQLAstNamedType = Void*
  type GraphQLAstListType = Void*
  type GraphQLAstNonNullType = Void*
  type GraphQLAstName = Void*
  type GraphQLAstSchemaDefinition = Void*
  type GraphQLAstOperationTypeDefinition = Void*
  type GraphQLAstScalarTypeDefinition = Void*
  type GraphQLAstObjectTypeDefinition = Void*
  type GraphQLAstFieldDefinition = Void*
  type GraphQLAstInputValueDefinition = Void*
  type GraphQLAstInterfaceTypeDefinition = Void*
  type GraphQLAstUnionTypeDefinition = Void*
  type GraphQLAstEnumTypeDefinition = Void*
  type GraphQLAstEnumValueDefinition = Void*
  type GraphQLAstInputObjectTypeDefinition = Void*
  type GraphQLAstTypeExtensionTypeDefinition = Void*
  type GraphQLAstDirectiveTypeDefinition = Void*

  struct GraphQLAstLocation
    beginLine : Int32
    beginColumn : Int32
    endLine : Int32
    endColumn : Int32
  end

  struct GraphQLAstVisitorCallbacks
    visit_document : (GraphQLAstDocument, Void* -> Int32)
    end_visit_document : (GraphQLAstDocument, Void* ->)

    visit_operation_definition : (GraphQLAstOperationDefinition, Void* -> Int32)
    end_visit_operation_definition : (GraphQLAstOperationDefinition, Void* ->)

    visit_variable_definition :(GraphQLAstVariableDefinition, Void* -> Int32)
    end_visit_variable_definition : (GraphQLAstVariableDefinition, Void* ->)

    visit_selection_set :(GraphQLAstSelectionSet, Void* -> Int32)
    end_visit_selection_set : (GraphQLAstSelectionSet, Void* ->)

    visit_field : (GraphQLAstField, Void* -> Int32)
    end_visit_field : (GraphQLAstField, Void* ->)

    visit_argument : (GraphQLAstArgument, Void* -> Int32)
    end_visit_argument : (GraphQLAstArgument, Void* ->)

    visit_fragment_spread : (GraphQLAstFragmentSpread, Void* -> Int32)
    end_visit_fragment_spread : (GraphQLAstFragmentSpread, Void* ->)

    visit_inline_fragment : (GraphQLAstInlineFragment, Void* -> Int32)
    end_visit_inline_fragment : (GraphQLAstInlineFragment, Void* ->)

    visit_fragment_definition : (GraphQLAstFragmentDefinition, Void* -> Int32)
    end_visit_fragment_definition : (GraphQLAstFragmentDefinition, Void* ->)

    visit_variable : (GraphQLAstVariable, Void* -> Int32)
    end_visit_variable : (GraphQLAstVariable, Void* ->)

    visit_int_value : (GraphQLAstIntValue, Void* -> Int32)
    end_visit_int_value : (GraphQLAstIntValue, Void* ->)

    visit_float_value : (GraphQLAstFloatValue, Void* -> Int32)
    end_visit_float_value : (GraphQLAstFloatValue, Void* ->)

    visit_string_value : (GraphQLAstStringValue, Void* -> Int32)
    end_visit_string_value : (GraphQLAstStringValue, Void* ->)

    visit_boolean_value : (GraphQLAstBooleanValue, Void* -> Int32)
    end_visit_boolean_value : (GraphQLAstBooleanValue, Void* ->)

    visit_null_value : (GraphQLAstNullValue, Void* -> Int32)
    end_visit_null_value : (GraphQLAstNullValue, Void* ->)

    visit_enum_value : (GraphQLAstEnumValue, Void* -> Int32)
    end_visit_enum_value : (GraphQLAstEnumValue, Void* ->)

    visit_list_value : (GraphQLAstListValue, Void* -> Int32)
    end_visit_list_value : (GraphQLAstListValue, Void* ->)

    visit_object_value : (GraphQLAstObjectValue, Void* -> Int32)
    end_visit_object_value : (GraphQLAstObjectValue, Void* ->)

    visit_object_field : (GraphQLAstObjectField, Void* -> Int32)
    end_visit_object_field : (GraphQLAstObjectField, Void* ->)

    visit_directive : (GraphQLAstDirective, Void* -> Int32)
    end_visit_directive : (GraphQLAstDirective, Void* ->)

    visit_named_type : (GraphQLAstNamedType, Void* -> Int32)
    end_visit_named_type : (GraphQLAstNamedType, Void* ->)

    visit_list_type : (GraphQLAstListType, Void* -> Int32)
    end_visit_list_type : (GraphQLAstListType, Void* ->)

    visit_non_null_type : (GraphQLAstNonNullType, Void* -> Int32)
    end_visit_non_null_type : (GraphQLAstNonNullType, Void* ->)

    visit_name : (GraphQLAstName, Void* -> Int32)
    end_visit_name : (GraphQLAstName, Void* ->)

    visit_schema_definition : (GraphQLAstSchemaDefinition, Void* -> Int32)
    end_visit_schema_definition : (GraphQLAstSchemaDefinition, Void* ->)

    visit_operation_type_definition : (GraphQLAstOperationTypeDefinition, Void* -> Int32)
    end_visit_operation_type_definition : (GraphQLAstOperationTypeDefinition, Void* ->)

    visit_scalar_type_definition : (GraphQLAstScalarTypeDefinition, Void* -> Int32)
    end_visit_scalar_type_definition : (GraphQLAstScalarTypeDefinition, Void* ->)

    visit_object_type_definition : (GraphQLAstObjectTypeDefinition, Void* -> Int32)
    end_visit_object_type_definition : (GraphQLAstObjectTypeDefinition, Void* ->)

    visit_field_definition : (GraphQLAstFieldDefinition, Void* -> Int32)
    end_visit_field_definition : (GraphQLAstFieldDefinition, Void* ->)

    visit_input_value_definition : (GraphQLAstInputValueDefinition, Void* -> Int32)
    end_visit_input_value_definition : (GraphQLAstInputValueDefinition, Void* ->)

    visit_interface_type_definition : (GraphQLAstInterfaceTypeDefinition, Void* -> Int32)
    end_visit_interface_type_definition : (GraphQLAstInterfaceTypeDefinition, Void* ->)

    visit_union_type_definition : (GraphQLAstUnionTypeDefinition, Void* -> Int32)
    end_visit_union_type_definition : (GraphQLAstUnionTypeDefinition, Void* ->)

    visit_enum_type_definition : (GraphQLAstEnumTypeDefinition, Void* -> Int32)
    end_visit_enum_type_definition : (GraphQLAstEnumTypeDefinition, Void* ->)

    visit_enum_value_definition : (GraphQLAstEnumValueDefinition, Void* -> Int32)
    end_visit_enum_value_definition : (GraphQLAstEnumValueDefinition, Void* ->)

    visit_input_object_type_definition : (GraphQLAstInputObjectTypeDefinition, Void* -> Int32)
    end_visit_input_object_type_definition : (GraphQLAstInputObjectTypeDefinition, Void* ->)

    visit_type_extension_definition : (GraphQLAstTypeExtensionTypeDefinition, Void* -> Int32)
    end_visit_type_extension_definitionn : (GraphQLAstTypeExtensionTypeDefinition, Void* ->)

    visit_directive_definition : (GraphQLAstDirectiveTypeDefinition, Void* -> Int32)
    end_visit_directive_definition : (GraphQLAstDirectiveTypeDefinition, Void* ->)
  end

  fun parse_string = graphql_parse_string(context : LibC::Char*, error : LibC::Char**) : GraphQLAstNode
  fun parse_string_with_schema = graphql_parse_string_with_experimental_schema_support(context : LibC::Char*, error : LibC::Char**) : GraphQLAstNode

  fun error_free = graphql_error_free(error : LibC::Char*)

  fun node_visit = graphql_node_visit(node : GraphQLAstNode, callbacks : GraphQLAstVisitorCallbacks*, userData : Void*)

  fun node_get_location = graphql_node_get_location(node : GraphQLAstNode, location : GraphQLAstLocation*)
  fun node_free = graphql_node_free(node : GraphQLAstNode)

  fun GraphQLAstOperationDefinition_get_name(node : GraphQLAstOperationDefinition) : GraphQLAstName
  fun GraphQLAstOperationDefinition_get_operation(node : GraphQLAstOperationDefinition) : LibC::Char*
  fun GraphQLAstFragmentDefinition_get_name(node : GraphQLAstFragmentDefinition) : GraphQLAstName
  fun GraphQLAstFragmentSpread_get_name(node : GraphQLAstFragmentSpread) : GraphQLAstName
  fun GraphQLAstField_get_name(node : GraphQLAstField) : GraphQLAstName
  fun GraphQLAstField_get_alias(node : GraphQLAstField) : GraphQLAstName
  fun GraphQLAstName_get_value(node : GraphQLAstName) : LibC::Char*

  fun GraphQLAstArgument_get_name(node : GraphQLAstArgument) : GraphQLAstName
  fun GraphQLAstVariable_get_name(node : GraphQLAstVariable) : GraphQLAstName

  fun GraphQLAstIntValue_get_value(node : GraphQLAstIntValue) : LibC::Char*
  fun GraphQLAstFloatValue_get_value(node : GraphQLAstFloatValue) : LibC::Char*
  fun GraphQLAstBooleanValue_get_value(node : GraphQLAstBooleanValue) : Int32
  fun GraphQLAstStringValue_get_value(node : GraphQLAstStringValue) : LibC::Char*

  fun GraphQLAstNamedType_get_name(node : GraphQLAstNamedType) : GraphQLAstName

  fun GraphQLAstDirective_get_name(node : GraphQLAstDirective) : GraphQLAstName

  fun GraphQLAstOperationTypeDefinition_get_operation(node : GraphQLAstOperationTypeDefinition) : LibC::Char*
  fun GraphQLAstEnumValue_get_value(node : GraphQLAstEnumValue) : LibC::Char*

  fun GraphQLAstObjectTypeDefinition_get_name(node : GraphQLAstObjectTypeDefinition) : GraphQLAstName
  fun GraphQLAstFieldDefinition_get_name(node : GraphQLAstFieldDefinition) : GraphQLAstName
  fun GraphQLAstInputValueDefinition_get_name(node : GraphQLAstInputValueDefinition) : GraphQLAstName
  fun GraphQLAstInterfaceTypeDefinition_get_name(node : GraphQLAstInterfaceTypeDefinition) : GraphQLAstName
  fun GraphQLAstUnionTypeDefinition_get_name(node : GraphQLAstUnionTypeDefinition) : GraphQLAstName
  fun GraphQLAstEnumTypeDefinition_get_name(node : GraphQLAstEnumTypeDefinition) : GraphQLAstName
  fun GraphQLAstScalarTypeDefinition_get_name(node : GraphQLAstScalarTypeDefinition) : GraphQLAstName
  fun GraphQLAstEnumValueDefinition_get_name(node : GraphQLAstEnumValueDefinition) : GraphQLAstName
  fun GraphQLAstDirectiveDefinition_get_name(node : GraphQLAstDirectiveTypeDefinition) : GraphQLAstName
end
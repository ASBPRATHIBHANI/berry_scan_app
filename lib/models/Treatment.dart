/*
* Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License").
* You may not use this file except in compliance with the License.
* A copy of the License is located at
*
*  http://aws.amazon.com/apache2.0
*
* or in the "license" file accompanying this file. This file is distributed
* on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
* express or implied. See the License for the specific language governing
* permissions and limitations under the License.
*/

// NOTE: This file is generated and may not follow lint rules defined in your app
// Generated files can be excluded from analysis in analysis_options.yaml
// For more info, see: https://dart.dev/guides/language/analysis-options#excluding-code-from-analysis

// ignore_for_file: public_member_api_docs, annotate_overrides, dead_code, dead_codepublic_member_api_docs, depend_on_referenced_packages, file_names, library_private_types_in_public_api, no_leading_underscores_for_library_prefixes, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, null_check_on_nullable_type_parameter, override_on_non_overriding_member, prefer_adjacent_string_concatenation, prefer_const_constructors, prefer_if_null_operators, prefer_interpolation_to_compose_strings, slash_for_doc_comments, sort_child_properties_last, unnecessary_const, unnecessary_constructor_name, unnecessary_late, unnecessary_new, unnecessary_null_aware_assignments, unnecessary_nullable_for_final_variable_declarations, unnecessary_string_interpolations, use_build_context_synchronously

import 'ModelProvider.dart';
import 'package:amplify_core/amplify_core.dart' as amplify_core;


/** This is an auto generated class representing the Treatment type in your schema. */
class Treatment extends amplify_core.Model {
  static const classType = const _TreatmentModelType();
  final String id;
  final String? _diseaseName;
  final String? _chemicalCure;
  final String? _organicCure;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  TreatmentModelIdentifier get modelIdentifier {
      return TreatmentModelIdentifier(
        id: id
      );
  }
  
  String get diseaseName {
    try {
      return _diseaseName!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String? get chemicalCure {
    return _chemicalCure;
  }
  
  String? get organicCure {
    return _organicCure;
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const Treatment._internal({required this.id, required diseaseName, chemicalCure, organicCure, createdAt, updatedAt}): _diseaseName = diseaseName, _chemicalCure = chemicalCure, _organicCure = organicCure, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory Treatment({String? id, required String diseaseName, String? chemicalCure, String? organicCure}) {
    return Treatment._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      diseaseName: diseaseName,
      chemicalCure: chemicalCure,
      organicCure: organicCure);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Treatment &&
      id == other.id &&
      _diseaseName == other._diseaseName &&
      _chemicalCure == other._chemicalCure &&
      _organicCure == other._organicCure;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("Treatment {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("diseaseName=" + "$_diseaseName" + ", ");
    buffer.write("chemicalCure=" + "$_chemicalCure" + ", ");
    buffer.write("organicCure=" + "$_organicCure" + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Treatment copyWith({String? diseaseName, String? chemicalCure, String? organicCure}) {
    return Treatment._internal(
      id: id,
      diseaseName: diseaseName ?? this.diseaseName,
      chemicalCure: chemicalCure ?? this.chemicalCure,
      organicCure: organicCure ?? this.organicCure);
  }
  
  Treatment copyWithModelFieldValues({
    ModelFieldValue<String>? diseaseName,
    ModelFieldValue<String?>? chemicalCure,
    ModelFieldValue<String?>? organicCure
  }) {
    return Treatment._internal(
      id: id,
      diseaseName: diseaseName == null ? this.diseaseName : diseaseName.value,
      chemicalCure: chemicalCure == null ? this.chemicalCure : chemicalCure.value,
      organicCure: organicCure == null ? this.organicCure : organicCure.value
    );
  }
  
  Treatment.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _diseaseName = json['diseaseName'],
      _chemicalCure = json['chemicalCure'],
      _organicCure = json['organicCure'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'diseaseName': _diseaseName, 'chemicalCure': _chemicalCure, 'organicCure': _organicCure, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'diseaseName': _diseaseName,
    'chemicalCure': _chemicalCure,
    'organicCure': _organicCure,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<TreatmentModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<TreatmentModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final DISEASENAME = amplify_core.QueryField(fieldName: "diseaseName");
  static final CHEMICALCURE = amplify_core.QueryField(fieldName: "chemicalCure");
  static final ORGANICCURE = amplify_core.QueryField(fieldName: "organicCure");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Treatment";
    modelSchemaDefinition.pluralName = "Treatments";
    
    modelSchemaDefinition.authRules = [
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.PRIVATE,
        operations: const [
          amplify_core.ModelOperation.READ
        ])
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Treatment.DISEASENAME,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Treatment.CHEMICALCURE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Treatment.ORGANICCURE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.nonQueryField(
      fieldName: 'createdAt',
      isRequired: false,
      isReadOnly: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.nonQueryField(
      fieldName: 'updatedAt',
      isRequired: false,
      isReadOnly: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _TreatmentModelType extends amplify_core.ModelType<Treatment> {
  const _TreatmentModelType();
  
  @override
  Treatment fromJson(Map<String, dynamic> jsonData) {
    return Treatment.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'Treatment';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [Treatment] in your schema.
 */
class TreatmentModelIdentifier implements amplify_core.ModelIdentifier<Treatment> {
  final String id;

  /** Create an instance of TreatmentModelIdentifier using [id] the primary key. */
  const TreatmentModelIdentifier({
    required this.id});
  
  @override
  Map<String, dynamic> serializeAsMap() => (<String, dynamic>{
    'id': id
  });
  
  @override
  List<Map<String, dynamic>> serializeAsList() => serializeAsMap()
    .entries
    .map((entry) => (<String, dynamic>{ entry.key: entry.value }))
    .toList();
  
  @override
  String serializeAsString() => serializeAsMap().values.join('#');
  
  @override
  String toString() => 'TreatmentModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is TreatmentModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}
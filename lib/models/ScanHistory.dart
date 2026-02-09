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


/** This is an auto generated class representing the ScanHistory type in your schema. */
class ScanHistory extends amplify_core.Model {
  static const classType = const _ScanHistoryModelType();
  final String id;
  final String? _disease;
  final double? _confidence;
  final String? _imagePath;
  final amplify_core.TemporalDateTime? _timestamp;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  ScanHistoryModelIdentifier get modelIdentifier {
      return ScanHistoryModelIdentifier(
        id: id
      );
  }
  
  String get disease {
    try {
      return _disease!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  double? get confidence {
    return _confidence;
  }
  
  String? get imagePath {
    return _imagePath;
  }
  
  amplify_core.TemporalDateTime? get timestamp {
    return _timestamp;
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const ScanHistory._internal({required this.id, required disease, confidence, imagePath, timestamp, createdAt, updatedAt}): _disease = disease, _confidence = confidence, _imagePath = imagePath, _timestamp = timestamp, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory ScanHistory({String? id, required String disease, double? confidence, String? imagePath, amplify_core.TemporalDateTime? timestamp}) {
    return ScanHistory._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      disease: disease,
      confidence: confidence,
      imagePath: imagePath,
      timestamp: timestamp);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ScanHistory &&
      id == other.id &&
      _disease == other._disease &&
      _confidence == other._confidence &&
      _imagePath == other._imagePath &&
      _timestamp == other._timestamp;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("ScanHistory {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("disease=" + "$_disease" + ", ");
    buffer.write("confidence=" + (_confidence != null ? _confidence!.toString() : "null") + ", ");
    buffer.write("imagePath=" + "$_imagePath" + ", ");
    buffer.write("timestamp=" + (_timestamp != null ? _timestamp!.format() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  ScanHistory copyWith({String? disease, double? confidence, String? imagePath, amplify_core.TemporalDateTime? timestamp}) {
    return ScanHistory._internal(
      id: id,
      disease: disease ?? this.disease,
      confidence: confidence ?? this.confidence,
      imagePath: imagePath ?? this.imagePath,
      timestamp: timestamp ?? this.timestamp);
  }
  
  ScanHistory copyWithModelFieldValues({
    ModelFieldValue<String>? disease,
    ModelFieldValue<double?>? confidence,
    ModelFieldValue<String?>? imagePath,
    ModelFieldValue<amplify_core.TemporalDateTime?>? timestamp
  }) {
    return ScanHistory._internal(
      id: id,
      disease: disease == null ? this.disease : disease.value,
      confidence: confidence == null ? this.confidence : confidence.value,
      imagePath: imagePath == null ? this.imagePath : imagePath.value,
      timestamp: timestamp == null ? this.timestamp : timestamp.value
    );
  }
  
  ScanHistory.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _disease = json['disease'],
      _confidence = (json['confidence'] as num?)?.toDouble(),
      _imagePath = json['imagePath'],
      _timestamp = json['timestamp'] != null ? amplify_core.TemporalDateTime.fromString(json['timestamp']) : null,
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'disease': _disease, 'confidence': _confidence, 'imagePath': _imagePath, 'timestamp': _timestamp?.format(), 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'disease': _disease,
    'confidence': _confidence,
    'imagePath': _imagePath,
    'timestamp': _timestamp,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<ScanHistoryModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<ScanHistoryModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final DISEASE = amplify_core.QueryField(fieldName: "disease");
  static final CONFIDENCE = amplify_core.QueryField(fieldName: "confidence");
  static final IMAGEPATH = amplify_core.QueryField(fieldName: "imagePath");
  static final TIMESTAMP = amplify_core.QueryField(fieldName: "timestamp");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "ScanHistory";
    modelSchemaDefinition.pluralName = "ScanHistories";
    
    modelSchemaDefinition.authRules = [
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.OWNER,
        ownerField: "owner",
        identityClaim: "cognito:username",
        provider: amplify_core.AuthRuleProvider.USERPOOLS,
        operations: const [
          amplify_core.ModelOperation.CREATE,
          amplify_core.ModelOperation.UPDATE,
          amplify_core.ModelOperation.DELETE,
          amplify_core.ModelOperation.READ
        ])
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: ScanHistory.DISEASE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: ScanHistory.CONFIDENCE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: ScanHistory.IMAGEPATH,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: ScanHistory.TIMESTAMP,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
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

class _ScanHistoryModelType extends amplify_core.ModelType<ScanHistory> {
  const _ScanHistoryModelType();
  
  @override
  ScanHistory fromJson(Map<String, dynamic> jsonData) {
    return ScanHistory.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'ScanHistory';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [ScanHistory] in your schema.
 */
class ScanHistoryModelIdentifier implements amplify_core.ModelIdentifier<ScanHistory> {
  final String id;

  /** Create an instance of ScanHistoryModelIdentifier using [id] the primary key. */
  const ScanHistoryModelIdentifier({
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
  String toString() => 'ScanHistoryModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is ScanHistoryModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}
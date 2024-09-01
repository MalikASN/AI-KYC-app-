// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class FieldTypeStruct extends BaseStruct {
  FieldTypeStruct({
    String? labelText,
    int? maxLength,
  })  : _labelText = labelText,
        _maxLength = maxLength;

  // "LabelText" field.
  String? _labelText;
  String get labelText => _labelText ?? '';
  set labelText(String? val) => _labelText = val;

  bool hasLabelText() => _labelText != null;

  // "MaxLength" field.
  int? _maxLength;
  int get maxLength => _maxLength ?? 0;
  set maxLength(int? val) => _maxLength = val;

  void incrementMaxLength(int amount) => maxLength = maxLength + amount;

  bool hasMaxLength() => _maxLength != null;

  static FieldTypeStruct fromMap(Map<String, dynamic> data) => FieldTypeStruct(
        labelText: data['LabelText'] as String?,
        maxLength: castToType<int>(data['MaxLength']),
      );

  static FieldTypeStruct? maybeFromMap(dynamic data) => data is Map
      ? FieldTypeStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'LabelText': _labelText,
        'MaxLength': _maxLength,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'LabelText': serializeParam(
          _labelText,
          ParamType.String,
        ),
        'MaxLength': serializeParam(
          _maxLength,
          ParamType.int,
        ),
      }.withoutNulls;

  static FieldTypeStruct fromSerializableMap(Map<String, dynamic> data) =>
      FieldTypeStruct(
        labelText: deserializeParam(
          data['LabelText'],
          ParamType.String,
          false,
        ),
        maxLength: deserializeParam(
          data['MaxLength'],
          ParamType.int,
          false,
        ),
      );

  @override
  String toString() => 'FieldTypeStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is FieldTypeStruct &&
        labelText == other.labelText &&
        maxLength == other.maxLength;
  }

  @override
  int get hashCode => const ListEquality().hash([labelText, maxLength]);
}

FieldTypeStruct createFieldTypeStruct({
  String? labelText,
  int? maxLength,
}) =>
    FieldTypeStruct(
      labelText: labelText,
      maxLength: maxLength,
    );

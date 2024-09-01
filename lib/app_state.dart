import 'dart:collection';

import 'package:flutter/material.dart';
import '/backend/schema/structs/index.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {}

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  int _multiStepState = 0;
  int get multiStepState => _multiStepState;
  set multiStepState(int value) {
    _multiStepState = value;
  }

  double _matchingScore = 0.0;
  double get matchingScore => _matchingScore;
  set matchingScore(double value) {
    _matchingScore = value;
  }

  String _selfieImagePath = "";
  String get selfieImagePath => _selfieImagePath;
  void setSelfie(String path) {
    _selfieImagePath = path;
  }

  Map<String, dynamic> _nfcMap = {};
  Map<String, dynamic> get nfcMap => _nfcMap;
  void setNfcMap(Map<String, dynamic> map) {
    _nfcMap = map;
    // notifyListeners();
  }

  String _extractedPerson = "";
  String get extractedPerson => _extractedPerson;
  void setExtractedPerson(String path) {
    _extractedPerson = path;
    notifyListeners();
  }

  bool _useGoogleML = true;
  bool get useGooleML => _useGoogleML;
  void setGoogleML(bool val) {
    _useGoogleML = val;
    notifyListeners();
  }

  bool _contractSigned = false;
  bool get contractSigned => _contractSigned;
  void setContractSigned(bool val) {
    _contractSigned = val;
  }

  bool _matchingRes = false;
  bool get matchingRes => _matchingRes;
  void setMatchingRes(bool res) {
    _matchingRes = res;
  }

  int _nfcState = 0;
  int get nfcState => _nfcState;
  void setNfcState(int state) {
    _nfcState = state;
    notifyListeners();
  }

  String _documentImagePathRecto = "";
  String get documentImagePathRecto => _documentImagePathRecto;
  void setdocumentImagePathRecto(String path) {
    _documentImagePathRecto = path;
  }

  String _documentImagePathVerso = "";
  String get documentImagePathVerso => _documentImagePathVerso;
  void setdocumentImagePathVerso(String path) {
    _documentImagePathVerso = path;
  }

  final Map<String, String> _formData = HashMap<String, String>();
  void setFromData(Map<String, String> data) {
    _formData.addAll(data);
  }

  get formData => _formData;

  bool _displayUserpdf = false;
  bool get displayUserpdf => _displayUserpdf;
  void setuserPDF(bool val) {
    _displayUserpdf = val;
    notifyListeners(); // This is crucial to update the UI
  }

  List<FieldTypeStruct> _FieldsToAddList = [];
  List<FieldTypeStruct> get FieldsToAddList => _FieldsToAddList;
  set FieldsToAddList(List<FieldTypeStruct> value) {
    _FieldsToAddList = value;
  }

  void addToFieldsToAddList(FieldTypeStruct value) {
    FieldsToAddList.add(value);
  }

  void removeFromFieldsToAddList(FieldTypeStruct value) {
    FieldsToAddList.remove(value);
  }

  void removeAtIndexFromFieldsToAddList(int index) {
    FieldsToAddList.removeAt(index);
  }

  void updateFieldsToAddListAtIndex(
    int index,
    FieldTypeStruct Function(FieldTypeStruct) updateFn,
  ) {
    FieldsToAddList[index] = updateFn(_FieldsToAddList[index]);
  }

  void insertAtIndexInFieldsToAddList(int index, FieldTypeStruct value) {
    FieldsToAddList.insert(index, value);
  }
}

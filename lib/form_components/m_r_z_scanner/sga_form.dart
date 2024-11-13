import 'dart:convert';

import 'package:facial_reco_p_o_c/app_state.dart';
import 'package:facial_reco_p_o_c/flutter_flow/flutter_flow_theme.dart';
import 'package:facial_reco_p_o_c/flutter_flow/flutter_flow_widgets.dart';
import 'package:facial_reco_p_o_c/form_components/m_r_z_scanner/m_r_z_scanner_model.dart';
import 'package:flutter/material.dart';

class SGAForm extends StatefulWidget {
  final bool isConfirmed; // Public property (remove the underscore)
  final MRZScannerModel model;
  final Map<String, String> mrzMap;
  final void Function(bool val) changeConfirmation;
  Map<String, String> mapForm;

  // Constructor to accept isConfirmed as a required parameter
  SGAForm(
      {Key? key,
      required this.isConfirmed,
      required this.model,
      required this.mrzMap,
      required this.mapForm,
      required this.changeConfirmation})
      : super(key: key);

  @override
  _SGAFormState createState() => _SGAFormState();
}

class _SGAFormState extends State<SGAForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomJeuneFille = TextEditingController();
  final TextEditingController _lieuNaissance = TextEditingController();
  final TextEditingController _pere = TextEditingController();
  final TextEditingController _mere = TextEditingController();

  final TextEditingController _addressPrincipaleController =
      TextEditingController();
  final TextEditingController _profession = TextEditingController();
  final TextEditingController _employeur = TextEditingController();
  final TextEditingController _phoneProfessionalController =
      TextEditingController();
  final TextEditingController _phoneHomeController = TextEditingController();
  final TextEditingController _phoneMobileController = TextEditingController();

  final TextEditingController _emailController =
      TextEditingController(text: FFAppState().formData['email']);

  final TextEditingController _dateDeliverancePID = TextEditingController();
  final TextEditingController _lieuDeliverance = TextEditingController();
  final TextEditingController _nomDelivreur = TextEditingController();
  final TextEditingController _montantController = TextEditingController();

  Map<String, int> revenuesMap = {
    'Salaire': 0,
    'Revenus locatifs': 0,
    'Retraite': 0,
    'Revenu sur le capital': 0,
    'Pension': 0
  };
  int revenuesTracker = 0;

  String? _salaire = "Salaire";

  final List<String> _maritalStatusOptions = {
    'Célibataire',
    'Séparé(e)',
    'Veuf/Veuve',
    'Marié(e)',
    'Divorcé(e)',
  }.toList();
  String? _maritalStatus = 'Célibataire';
  final List<String> _typeRevenusOptions = [
    'Salaire',
    'Revenus locatifs',
    'Retraite',
    'Revenu sur le capital',
    'Pension'
  ];

  String? phoneValidator(String? value) {
    // Check if value is null or empty
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer un numéro de téléphone.';
    }

    // Try to parse the input as an integer
    final int? parsedValue = int.tryParse(value);

    // Check if the parsed value is null (invalid number)
    if (parsedValue == null) {
      return 'Veuillez entrer un numéro valide.';
    }

    return null; // Return null if the value is valid
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              widget.model.dropDownValue == "Femme"
                  ? _buildTextFormField(
                      controller: _nomJeuneFille,
                      label: 'Nom de jeune fille',
                      maxLength: 20,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre nom de jeune fille';
                        }
                        return null;
                      },
                    )
                  : Container(),
              _buildTextFormField(
                controller: _lieuNaissance,
                label: 'Lieu de naissance',
                maxLength: 20,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre lieu de naissance';
                  }
                  return null;
                },
              ),
              /* _buildTextFormField(
                controller: _pere,
                label: 'Nom et prenoms du père',
                maxLength: 30,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer les nom et prénom(s) de votre père';
                  }
                  return null;
                },
              ),
              _buildTextFormField(
                controller: _mere,
                label: 'Nom et prenoms de la mère',
                maxLength: 30,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer les nom et prénom(s) de votre mère';
                  }
                  return null;
                },
              ),*/
              _buildDropdown(
                value: _maritalStatusOptions[0],
                label: 'Situation familiale',
                options: _maritalStatusOptions,
                onChanged: (value) =>
                    setState(() => _maritalStatus = value.toString()!),
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez sélectionner votre situation familiale';
                  }
                  return null;
                },
              ),
              _buildTextFormField(
                controller: _addressPrincipaleController,
                label: 'Adresse principale',
                maxLength: 100,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre adresse principale';
                  }
                  return null;
                },
              ),
              _buildTextFormField(
                controller: _profession,
                label: 'Profession',
                maxLength: 25,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre profession';
                  }
                  return null;
                },
              ),
              _buildTextFormField(
                controller: _employeur,
                label: 'Employeur',
                maxLength: 100,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le nom de votre employeur';
                  }
                  return null;
                },
              ),
              _buildTextFormField(
                  controller: _phoneProfessionalController,
                  label: 'N° de téléphone professionel',
                  maxLength: 10,
                  validator: phoneValidator),
              _buildTextFormField(
                  controller: _phoneHomeController,
                  label: 'N° de Téléphone domicile',
                  maxLength: 10,
                  validator: phoneValidator),
              _buildTextFormField(
                  controller: _phoneMobileController,
                  label: 'N° de téléphone portable',
                  maxLength: 10,
                  validator: phoneValidator),
              _buildTextFormField(
                controller: _emailController,
                label: 'Email',
                maxLength: 100,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre adresse email';
                  } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Veuillez entrer un email valide';
                  }
                  return null;
                },
              ),
              _buildTextFormField(
                hint: "année/mois/jour",
                controller: _dateDeliverancePID,
                label: 'Date deliverance PID',
                maxLength: 100,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir la date de deliverance';
                  } // Regular expression to match the yyyy/MM/dd format
                  final RegExp regex = RegExp(r'^\d{4}/\d{2}/\d{2}$');
                  if (!regex.hasMatch(value)) {
                    return 'Format de date invalide. Utilisez le format année/mois/jour';
                  }

                  return null; // Date is valid
                },
              ),
              _buildTextFormField(
                controller: _lieuDeliverance,
                label: 'Lieu deliverance de la PID',
                maxLength: 100,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le lieu de deliverance de la PID';
                  }
                  return null;
                },
              ),
              _buildTextFormField(
                controller: _nomDelivreur,
                label: 'Commune de délivrance de la PID',
                maxLength: 100,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le nom du delivereur de votre PID';
                  }
                  return null;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Wrap the Expanded widget in a SizedBox to provide width constraints
                  SizedBox(
                    width: 200, // You can adjust the width as needed
                    child: _buildDropdown(
                      value: _salaire,
                      label: 'Types de revenus',
                      options: _typeRevenusOptions,
                      onChanged: (value) => {
                        if (value == 'Salaire')
                          {
                            setState(() {
                              revenuesTracker = 0;
                            }),
                            _montantController.text =
                                revenuesMap['Salaire'].toString()
                          },
                        if (value == 'Revenus locatifs')
                          {
                            setState(() {
                              revenuesTracker = 1;
                            }),
                            _montantController.text =
                                revenuesMap['Revenus locatifs'].toString()
                          },
                        if (value == 'Retraite')
                          {
                            setState(() {
                              revenuesTracker = 2;
                            }),
                            _montantController.text =
                                revenuesMap['Retraite'].toString()
                          },
                        if (value == 'Revenu sur le capital')
                          {
                            setState(() {
                              revenuesTracker = 3;
                            }),
                            _montantController.text =
                                revenuesMap['Revenu sur le capital'].toString()
                          },
                        if (value == 'Pension')
                          {
                            setState(() {
                              revenuesTracker = 4;
                            }),
                            _montantController.text =
                                revenuesMap['Pension'].toString(),
                          }
                      },
                    ),
                  ),

                  // Wrap the Expanded TextFormField inside a SizedBox to provide width constraints
                  SizedBox(
                    width: 150, // Adjust the width according to your UI design
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          8.0, 5.0, 8.0, 5.0),
                      child: TextFormField(
                        onChanged: (value) {
                          if (revenuesTracker == 0) {
                            setState(() {
                              revenuesMap['Salaire'] = int.parse(value);
                            });
                          }
                          if (revenuesTracker == 1) {
                            setState(() {
                              revenuesMap['Revenus locatifs'] =
                                  int.parse(value);
                            });
                          }
                          if (revenuesTracker == 2) {
                            setState(() {
                              revenuesMap['Retraite'] = int.parse(value);
                            });
                          }
                          if (revenuesTracker == 3) {
                            setState(() {
                              revenuesMap['Revenu sur le capital'] =
                                  int.parse(value);
                            });
                          }
                          if (revenuesTracker == 4) {
                            setState(() {
                              revenuesMap['Pension'] = int.parse(value);
                            });
                          }
                        },
                        controller: _montantController,
                        autofocus: false,
                        obscureText: false,
                        enabled: true,
                        readOnly: false,
                        decoration: InputDecoration(
                          labelText: "Montant (DZD)",
                          labelStyle:
                              FlutterFlowTheme.of(context).labelMedium.override(
                                    fontFamily: 'Readex Pro',
                                    letterSpacing: 0.0,
                                  ),
                          hintStyle:
                              FlutterFlowTheme.of(context).labelMedium.override(
                                    fontFamily: 'Readex Pro',
                                    letterSpacing: 0.0,
                                  ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).alternate,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).primary,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          errorBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).error,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedErrorBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).error,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Readex Pro',
                              letterSpacing: 0.0,
                            ),
                        maxLength: 20,
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un nombre';
                          }

                          // Check if the value is a positive integer
                          final int? intValue = int.tryParse(value);
                          if (intValue == null || intValue <= 0) {
                            return 'Veuillez entrer un nombre entier positif.';
                          }

                          return null; // Value is valid
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(30.0, 0.0, 15.0, 10.0),
                child: FFButtonWidget(
                  onPressed: () {
                    if (widget.isConfirmed == true) {
                      widget.changeConfirmation(false);
                    } else {
                      if (widget.model.textController1!.text.isNotEmpty &&
                          widget.model.textController2!.text.isNotEmpty &&
                          widget.model.textController3!.text.isNotEmpty &&
                          widget.model.textController4!.text.isNotEmpty &&
                          widget.model.dropDownValue != null &&
                          _formKey.currentState!.validate()) {
                        if ((FFAppState().FieldsToAddList.isNotEmpty &&
                                widget.mrzMap.isNotEmpty) ||
                            FFAppState().FieldsToAddList.isEmpty) {
                          Map<String, String> map = {
                            "firstname": widget.model.textController1!.text,
                            "lastname": widget.model.textController2!.text,
                            "birthDate": widget.model.textController3!.text,
                            "Doc num": widget.model.textController4!.text,
                            "nomJeuneFille": _nomJeuneFille.text,
                            "lieuNaissance": _lieuNaissance.text,
                            "pere": _pere.text,
                            "mere": _mere.text,
                            "statusMartial":
                                _maritalStatus!, // If you want to store the marital status
                            "addressPrincipale":
                                _addressPrincipaleController.text,
                            "profession": _profession.text,
                            "employeur": _employeur.text,
                            "phoneProfessional":
                                _phoneProfessionalController.text,
                            "phoneHome": _phoneHomeController.text,
                            "phoneMobile": _phoneMobileController.text,
                            "dateDeliverancePID": _dateDeliverancePID.text,
                            "lieuDeliverance": _lieuDeliverance.text,
                            "nomDelivreur": _nomDelivreur.text,
                            "montant": json.encode(revenuesMap)
                          };

                          FFAppState().setFromData(map);
                          widget.changeConfirmation(!widget.isConfirmed);
                        } else {
                          // Show error if any field is empty
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Veuillez remplir tout les champs')),
                          );
                        }
                      } else {
                        // Show error if any field is empty
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Veuillez remplir tout les champs')),
                        );
                      }
                    }
                  },
                  text: widget.isConfirmed ? 'Modifier' : 'Confirmer',
                  options: FFButtonOptions(
                    width: 250,
                    height: 40.0,
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        24.0, 0.0, 24.0, 0.0),
                    iconPadding: const EdgeInsetsDirectional.fromSTEB(
                        0.0, 0.0, 0.0, 0.0),
                    color: widget.isConfirmed == false
                        ? FlutterFlowTheme.of(context).primary
                        : FlutterFlowTheme.of(context).alternate,
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                          fontFamily: 'Readex Pro',
                          color: Colors.white,
                          letterSpacing: 0.0,
                        ),
                    elevation: 3.0,
                    borderSide: const BorderSide(
                      color: Colors.transparent,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    String? hint,
    required TextEditingController controller,
    required String label,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(8.0, 5.0, 8.0, 5.0),
      child: TextFormField(
          controller: controller,
          autofocus: false,
          obscureText: false,
          enabled: !widget.isConfirmed,
          readOnly: false,
          decoration: InputDecoration(
            hintText: hint,
            labelText: label,
            labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
                  fontFamily: 'Readex Pro',
                  letterSpacing: 0.0,
                ),
            hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                  fontFamily: 'Readex Pro',
                  letterSpacing: 0.0,
                ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: FlutterFlowTheme.of(context).alternate,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: FlutterFlowTheme.of(context).primary,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            errorBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: FlutterFlowTheme.of(context).error,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            focusedErrorBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: FlutterFlowTheme.of(context).error,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Readex Pro',
                letterSpacing: 0.0,
              ),
          maxLength: maxLength,
          keyboardType: TextInputType.name,
          validator: validator),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String label,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 8),
      child: DropdownButtonFormField<String>(
        iconSize: 0.0,
        elevation: 2,
        value: value,
        items: options.map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(
              option,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Readex Pro',
                    letterSpacing: 0.0,
                  ),
            ),
          );
        }).toList(),
        dropdownColor: FlutterFlowTheme.of(context).secondaryBackground,
        decoration: InputDecoration(
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: FlutterFlowTheme.of(context).secondaryText,
            size: 24.0,
          ),

          fillColor: FlutterFlowTheme.of(context).secondaryBackground,
          labelText: label,
          labelStyle: TextStyle(
            color: FlutterFlowTheme.of(context).secondaryText,
          ),
          enabledBorder: InputBorder.none, // Hide the underline
          focusedBorder: InputBorder.none, // Hide the underline when focused
          errorBorder:
              InputBorder.none, // Hide the underline when there is an error
        ),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }
}

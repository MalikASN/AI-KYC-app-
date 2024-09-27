import 'package:facial_reco_p_o_c/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';

class SGAForm extends StatefulWidget {
  final bool isConfirmed; // Public property (remove the underscore)

  // Constructor to accept isConfirmed as a required parameter
  const SGAForm({Key? key, required this.isConfirmed}) : super(key: key);

  @override
  _SGAFormState createState() => _SGAFormState();
}

class _SGAFormState extends State<SGAForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomJeuneFille = TextEditingController();
  final TextEditingController _lieuNaissance = TextEditingController();
  final TextEditingController _pere = TextEditingController();
  final TextEditingController _mere = TextEditingController();
  String _statusMartial = "";
  final TextEditingController _addressPrincipaleController =
      TextEditingController();
  final TextEditingController _profession = TextEditingController();
  final TextEditingController _employeur = TextEditingController();
  final TextEditingController _phoneProfessionalController =
      TextEditingController();
  final TextEditingController _phoneHomeController = TextEditingController();
  final TextEditingController _phoneMobileController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _dateDeliverancePID = TextEditingController();
  final TextEditingController _lieuDeliverance = TextEditingController();
  final TextEditingController _nomDelivreur = TextEditingController();
  final TextEditingController _montantController = TextEditingController();

  Map<String, int> revenuesMap = {
    'Salaire': 1,
    'Séparé(e)': 0,
    'Veuf/Veuve': 0,
    'Marié(e)': 0,
    'Divorcé(e)': 0
  };
  int revenuesTracker = 0;
  String? _maritalStatus;
  bool _isConfirmed = false;

  final List<String> _maritalStatusOptions = [
    'Célibataire',
    'Séparé(e)',
    'Veuf/Veuve',
    'Marié(e)',
    'Divorcé(e)'
  ];

  final List<String> _typeRevenusOptions = [
    'Salaire',
    'Revenus locatifs',
    'Retraite',
    'Revenu sur le capital',
    'Pension'
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildTextFormField(
              controller: _nomJeuneFille,
              label: 'Nom de jeune fille',
              maxLength: 20,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre nom de jeune fille';
                }
                return null;
              },
            ),
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
            _buildTextFormField(
              controller: _pere,
              label: 'Nom et prenoms du père',
              maxLength: 20,
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
              maxLength: 10,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer les nom et prénom(s) de votre mère';
                }
                return null;
              },
            ),
            _buildDropdown(
              value: _maritalStatus,
              label: 'Situation familiale',
              options: _maritalStatusOptions,
              onChanged: (value) => setState(() => _maritalStatus = value),
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
              controller: _emailController,
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
              controller: _addressPrincipaleController,
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
              controller: _phoneMobileController,
              label: 'N° de téléphone professionel',
              maxLength: 15,
            ),
            _buildTextFormField(
              controller: _phoneHomeController,
              label: 'N° de Téléphone domicile',
              maxLength: 15,
            ),
            _buildTextFormField(
              controller: _phoneMobileController,
              label: 'N° de téléphone portable',
              maxLength: 15,
            ),
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

                // Check if the date is valid
                try {
                  final DateTime parsedDate = DateTime.parse(value);
                  // Additional validation: check if the parsed date matches the input string
                  if (value !=
                      '${parsedDate.year}/${parsedDate.month.toString().padLeft(2, '0')}/${parsedDate.day.toString().padLeft(2, '0')}') {
                    return 'Date invalide.';
                  }
                } catch (e) {
                  return 'Date invalide.';
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
              controller: _addressPrincipaleController,
              label: 'Nom delivereur de la PID',
              maxLength: 100,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer le nom du delivereur de votre PID';
                }
                return null;
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDropdown(
                    value: _maritalStatus,
                    label: 'Types de revenus',
                    options: _maritalStatusOptions,
                    onChanged: (value) => {
                          if (value == 'Salaire')
                            {
                              setState(() {
                                revenuesTracker = 0;
                              }),
                            },
                          if (value == 'Séparé(e)')
                            {
                              setState(() {
                                revenuesTracker = 1;
                              }),
                            },
                          if (value == 'Veuf/Veuve')
                            {
                              setState(() {
                                revenuesTracker = 2;
                              }),
                            },
                          if (value == 'Marié(e)')
                            {
                              setState(() {
                                revenuesTracker = 3;
                              }),
                            },
                          if (value == 'Divorcé(e)')
                            {
                              setState(() {
                                revenuesTracker = 4;
                              }),
                            }
                        }),
                Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(8.0, 5.0, 8.0, 5.0),
                  child: TextFormField(
                    onChanged: (value) {
                      if (revenuesTracker == 0) {
                        setState(() {
                          revenuesMap['salaire'] = int.parse(value);
                        });
                      }
                      if (revenuesTracker == 1) {
                        setState(() {
                          revenuesMap['Séparé(e)'] = int.parse(value);
                        });
                      }
                      if (revenuesTracker == 2) {
                        setState(() {
                          revenuesMap['Veuf/Veuve'] = int.parse(value);
                        });
                      }
                      if (revenuesTracker == 3) {
                        setState(() {
                          revenuesMap['Marié(e)'] = int.parse(value);
                        });
                      }
                      if (revenuesTracker == 4) {
                        setState(() {
                          revenuesMap['Divorcé(e)'] = int.parse(value);
                        });
                      }
                    },
                    initialValue: revenuesTracker == 0
                        ? revenuesMap['salaire'].toString()
                        : revenuesTracker == 1
                            ? revenuesMap['Séparé(e)'].toString()
                            : revenuesTracker == 2
                                ? revenuesMap['Veuf/Veuve'].toString()
                                : revenuesTracker == 3
                                    ? revenuesMap['Marié(e)'].toString()
                                    : revenuesMap['Divorcé(e)'].toString(),
                    controller: _montantController,
                    autofocus: false,
                    obscureText: false,
                    enabled: false,
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
                        return 'Veuillez entrer le nom du delivereur de votre PID';
                      }

                      // Check if the value is a positive integer
                      final int? intValue = int.tryParse(value);
                      if (intValue == null || intValue <= 0) {
                        return 'Veuillez entrer un nombre entier positif.';
                      }

                      return null; // Value is valid
                    },
                  ),
                )
              ],
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Handle form submission
                }
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField({
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
          enabled: !_isConfirmed,
          readOnly: false,
          decoration: InputDecoration(
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
          maxLength: 20,
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
        value: value,
        items: options.map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
        decoration: InputDecoration(
          labelText: label,
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 2.0),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 2.0),
          ),
        ),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }
}

import 'dart:io';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

Future<bool> sendMail(String filePath, String receiver) async {
  // Remarque : l'utilisation d'un nom d'utilisateur et d'un mot de passe pour Gmail ne fonctionne que si
  // vous avez activé l'authentification à deux facteurs et créé un mot de passe d'application.
  // Recherchez "mot de passe d'application Gmail 2FA".
  // L'alternative est d'utiliser OAuth.
  String username = 'capturedoc306@gmail.com';
  String password = 'gadlrhrkulrswbjl';

  final smtpServer = gmail(username, password);

  // Création du message
  final message = Message()
    ..from = Address(username, 'SGA')
    ..recipients.add(Address(receiver))
    ..subject = 'Contrat société générale'
    ..text = 'Ci-joint le contrat signé et validé par la société générale'
    ..attachments = [
      FileAttachment(File(filePath))
        ..location = Location.inline
        ..cid = '<myimg@3.141>'
    ];

  try {
    // Envoi du message
    final sendReport = await send(message, smtpServer);
    print('Message envoyé : ' + sendReport.toString());

    // Vous pouvez également envoyer le message avec une connexion persistante
    var connection = PersistentConnection(smtpServer);
    await connection.send(message);
    await connection.close();

    return true; // Retourne true si l'envoi réussit
  } catch (e) {
    print('Erreur lors de l\'envoi du message : $e');
    return false; // Retourne false en cas d'erreur
  }
}

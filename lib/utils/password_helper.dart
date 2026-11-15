import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Utilitaire pour sécuriser les mots de passe.
///
/// Les mots de passe ne doivent jamais être stockés en clair dans la base
/// de données. Cette classe fournit des méthodes pour les hacher (avec un
/// "sel" / salt) et pour vérifier un mot de passe saisi par rapport à un
/// hash enregistré.
class PasswordHelper {
  /// Sel statique de l'application. Dans une application en production,
  /// il serait préférable de générer un sel aléatoire différent pour
  /// chaque utilisateur, mais un sel global reste déjà une nette
  /// amélioration par rapport à un stockage en clair.
  static const String _salt = "SenTontine_2026_salt_kE1";

  /// Transforme un mot de passe en clair en un hash sécurisé (SHA-256).
  static String hashPassword(String plainPassword) {
    final bytes = utf8.encode(_salt + plainPassword);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Vérifie qu'un mot de passe saisi correspond bien au hash stocké.
  static bool verifyPassword(String plainPassword, String storedHash) {
    return hashPassword(plainPassword) == storedHash;
  }
}

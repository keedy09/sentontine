# 🚀 Guide de démarrage rapide - SenTontine

## ⚡ Démarrage en 5 minutes

### 1️⃣ Installer Flutter (si ce n'est pas déjà fait)

**Windows/Mac/Linux :**
```bash
# Téléchargez Flutter depuis : https://flutter.dev/docs/get-started/install
# Suivez les instructions pour votre OS
```

Vérifiez l'installation :
```bash
flutter doctor
```

### 2️⃣ Ouvrir le projet

**Option A : Avec VS Code**
1. Ouvrez VS Code
2. File → Open Folder
3. Sélectionnez le dossier `sentontine`
4. Attendez que les extensions Flutter se chargent

**Option B : Avec Android Studio**
1. Ouvrez Android Studio
2. Open → Sélectionnez le dossier `sentontine`
3. Attendez l'indexation

### 3️⃣ Installer les dépendances

Dans le terminal (à la racine du projet) :
```bash
flutter pub get
```

### 4️⃣ Lancer l'application

**Sur émulateur Android/iOS :**
```bash
flutter run
```

**Sur Chrome (pour tester rapidement) :**
```bash
flutter run -d chrome
```

**Sur votre téléphone :**
1. Activez le mode développeur sur votre téléphone
2. Branchez-le en USB
3. Exécutez : `flutter run`

### 5️⃣ Se connecter

**Compte Admin :**
- Nom : `admin`
- Mot de passe : `admin123`

**Compte Membre :**
- Nom : `awa diop`
- Mot de passe : `awa123`

---

## 🎯 Premiers tests

### Test rapide de synchronisation

1. **Connectez-vous en membre** (Awa Diop)
2. Allez dans **"Paiements"**
3. Cliquez sur **"Payer"**
4. **Hot restart** (tapez `r` dans le terminal)
5. **Déconnectez-vous** et connectez-vous en **admin**
6. Allez dans **"Paiements"**
7. Vous devez voir le paiement **"En attente"** ✅

---

## 📱 Plateformes supportées

- ✅ **Android** (API 21+)
- ✅ **iOS** (iOS 11+)
- ✅ **Web** (Chrome, Safari, Firefox)
- ✅ **Windows** (Flutter 3.0+)
- ✅ **macOS** (Flutter 3.0+)
- ✅ **Linux** (Flutter 3.0+)

---

## 🔧 Commandes utiles

```bash
# Installer les dépendances
flutter pub get

# Lancer l'app
flutter run

# Lancer en mode release (plus rapide)
flutter run --release

# Nettoyer le build
flutter clean

# Analyser le code
flutter analyze

# Formater le code
flutter format .

# Lancer les tests
flutter test

# Créer un APK Android
flutter build apk

# Créer un Bundle Android
flutter build appbundle
```

---

## 💡 Raccourcis utiles pendant le développement

Quand l'app tourne :

- **`r`** : Hot reload (recharger les changements)
- **`R`** : Hot restart (redémarrer l'app)
- **`p`** : Afficher la grille de pixels
- **`o`** : Basculer iOS/Android dans l'émulateur
- **`q`** : Quitter

---

## 🐛 Problèmes courants

### "flutter: command not found"
**Solution** : Ajoutez Flutter au PATH
```bash
# Linux/Mac
export PATH="$PATH:`pwd`/flutter/bin"

# Windows
# Ajoutez le chemin dans les variables d'environnement
```

### "No connected devices"
**Solution** :
1. Lancez un émulateur depuis Android Studio
2. OU branchez votre téléphone en USB
3. OU lancez sur Chrome : `flutter run -d chrome`

### "Gradle build failed"
**Solution** :
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Caractères bizarres affichés
**Solution** :
1. Vérifiez que tous les fichiers .dart sont en UTF-8
2. Dans VS Code : File → Preferences → Settings
3. Cherchez "encoding" et mettez "UTF-8"

---

## 📚 Ressources utiles

- [Documentation Flutter](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Widget Catalog](https://docs.flutter.dev/development/ui/widgets)
- [Cookbook Flutter](https://docs.flutter.dev/cookbook)

---

## 🎓 Apprendre Flutter

### Tutoriels recommandés
1. [Flutter Codelab](https://docs.flutter.dev/get-started/codelab)
2. [Flutter YouTube Channel](https://www.youtube.com/flutterdev)
3. [FlutterFlow](https://flutterflow.io/) pour le no-code

---

## 🆘 Besoin d'aide ?

1. Consultez le **README.md** pour plus de détails
2. Vérifiez que Flutter est bien installé : `flutter doctor`
3. Relancez : `flutter clean && flutter pub get && flutter run`

---

**C'est parti ! Bon développement ! 🚀**

# 🇸🇳 SenTontine - Projet Flutter Complet

Application mobile de gestion de tontines pour le Sénégal.

## 📱 Fonctionnalités

### Pour l'Administrateur
- ✅ Tableau de bord avec statistiques en temps réel
- ✅ Gestion complète des tontines (CRUD)
- ✅ Gestion des membres (ajout, modification, affectation)
- ✅ Validation des paiements
- ✅ Vue d'ensemble des activités

### Pour les Membres
- ✅ Tableau de bord personnel
- ✅ Consultation de sa tontine
- ✅ Déclaration de paiements
- ✅ Historique des cotisations
- ✅ Vue des tontines disponibles

## 🚀 Installation

### 1. Prérequis
- Flutter SDK (>= 3.0.0)
- Dart SDK
- Un émulateur Android/iOS ou un appareil physique

### 2. Installation du projet

```bash
# Cloner ou extraire le projet
cd sentontine

# Installer les dépendances
flutter pub get

# Lancer l'application
flutter run
```

## 🔑 Comptes de test

### Administrateur
- **Nom** : `admin` ou `administrateur`
- **Mot de passe** : `admin123`

### Membres
- **Awa Diop** : `awa diop` / `awa123`
- **Fatou Ndiaye** : `fatou ndiaye` / `fatou123`
- **Marieme Sow** : `marieme sow` / `marieme123`
- **Jean Dupont** : `jean dupont` / `jean123`

## 📂 Structure du projet

```
lib/
├── main.dart                    # Point d'entrée de l'application
├── data/
│   └── shared_data.dart         # Données centralisées (singleton)
└── pages/
    ├── login_page.dart          # Page de connexion
    ├── admin/
    │   ├── admin_home_page.dart
    │   ├── admin_tontines_page.dart
    │   ├── admin_members_page.dart
    │   └── paiements_admin_page.dart
    └── member/
        ├── home_page.dart       # Navigation principale
        ├── home_member_page.dart
        ├── tontines_page.dart
        └── paiements_page.dart
```

## 🧪 Tester la synchronisation

### Test 1 : Paiement membre → validation admin
1. Connectez-vous en tant que **Awa Diop**
2. Allez dans **"Paiements"**
3. Cliquez sur **"Payer"** pour un paiement
4. Statut passe à **"En attente"**
5. Déconnectez-vous
6. Connectez-vous en tant qu'**admin**
7. Allez dans **"Paiements"**
8. Le paiement d'Awa apparaît en **"En attente"** ✅
9. Cliquez sur **"Valider"**
10. Reconnectez-vous en tant qu'Awa
11. Le paiement est maintenant **"Payé"** ✅

### Test 2 : Création de membre
1. En tant qu'admin, créez un nouveau membre
2. Affectez-le à une tontine
3. Connectez-vous avec ce nouveau membre
4. Sa tontine apparaît dans "Mes Tontines" ✅

## 🎨 Personnalisation

### Couleurs du thème
Les couleurs du drapeau sénégalais sont définies dans `main.dart` :
- **Vert** : `#00853F`
- **Rouge** : `#E30B17`

### Ajouter des données
Pour ajouter des tontines, membres ou paiements par défaut, modifiez le fichier `lib/data/shared_data.dart` dans la méthode `_initialiserDonnees()`.

## 📱 Captures d'écran

(Vous pouvez ajouter vos captures d'écran ici)

## 🔄 Prochaines étapes

### Phase 1 : Amélioration de l'état
- [ ] Intégrer **Provider** pour une meilleure gestion d'état
- [ ] Ajouter des animations fluides

### Phase 2 : Persistance
- [ ] Intégrer **Hive** ou **SQLite** pour sauvegarder les données
- [ ] Permettre la sauvegarde hors ligne

### Phase 3 : Backend
- [ ] Créer une API (Firebase / Laravel / Node.js)
- [ ] Authentification sécurisée avec JWT
- [ ] Synchronisation temps réel

### Phase 4 : Fonctionnalités avancées
- [ ] Notifications push
- [ ] Export PDF des historiques
- [ ] Intégration Mobile Money (Orange Money, Wave)
- [ ] Graphiques et statistiques avancées
- [ ] Mode sombre

## 🛠️ Dépannage

### Problème : "Cannot find package 'data'"
**Solution** : Vérifiez que `shared_data.dart` est bien dans `lib/data/`

### Problème : Caractères mal affichés
**Solution** : Assurez-vous que tous les fichiers sont en UTF-8
1. Dans votre éditeur : File → Save with Encoding → UTF-8
2. Sauvegardez tous les fichiers .dart

### Problème : Les données ne se synchronisent pas
**Solution** : Vérifiez que vous utilisez bien `SharedData()` dans chaque page

## 📄 License

Ce projet est fourni à des fins éducatives.

## 👨‍💻 Auteur

Application de gestion de tontines pour le Sénégal 🇸🇳

## 🙏 Remerciements

Merci d'utiliser SenTontine !

---

**Version** : 1.0.0  
**Date** : Février 2026

# 📊 Diagrammes UML - SenTontine

Ce dossier contient tous les diagrammes UML du projet SenTontine en format PlantUML.

## 📋 Fichiers disponibles

### 1. **use_case_diagram.puml** - Diagramme de Cas d'Utilisation
Décrit les interactions entre les acteurs (Membre, Admin) et les cas d'utilisation du système.

**Acteurs :**
- **Membre** : Peut consulter les tontines, effectuer des paiements, voir les statistiques
- **Admin** : Peut valider les paiements, gérer les paiements, générer des rapports

**Cas d'Utilisation Principaux :**
- UC1 : Consulter Tontines
- UC2 : Effectuer un Paiement
- UC3 : Consulter Statistiques
- UC4 : Valider les Paiements
- UC5 : Gérer les Paiements
- UC6 : Générer Rapports

---

### 2. **class_diagram.puml** - Diagramme de Classes
Représente la structure des classes, leurs attributs et leurs relations.

**Classes Principales :**
- **SharedData** : Gestionnaire central des données (Pattern Singleton)
- **Membre** : Représente un membre de la tontine
- **Tontine** : Représente une tontine
- **Paiement** : Représente un paiement/cotisation
- **PaiementsAdminPage** : Interface d'administration des paiements
- **PaiementsPage** : Interface des paiements pour les membres
- **TontinesPage** : Interface de consultation des tontines
- **HomeMemberPage** : Page d'accueil du membre
- **StripePaymentSimulation** : Widget de simulation de paiement

**Relations :**
- SharedData contient les collections de Membres, Tontines et Paiements
- Un Paiement appartient à un Membre et une Tontine
- Les pages utilisent SharedData pour accéder aux données

---

### 3. **sequence_diagrams.puml** - Diagrammes de Séquence
Décrit les interactions entre les objets dans le temps pour différents scénarios.

**4 Scénarios décrits :**

#### Scénario 1 : Effectuer un Paiement
Flux : Membre → PaiementsPage → StripePaymentSimulation → SharedData
- Valide le paiement
- Met à jour le statut
- Affiche un message de succès

#### Scénario 2 : Gérer les Paiements (Admin)
Flux : Admin → PaiementsAdminPage → SharedData
- Consulte la liste des paiements
- Valide un paiement
- Actualise l'interface

#### Scénario 3 : Consulter les Tontines
Flux : Membre → TontinesPage → SharedData
- Affiche la liste des tontines
- Affiche les détails d'une tontine

#### Scénario 4 : Tableau de Bord
Flux : Membre → HomeMemberPage → SharedData
- Affiche les statistiques
- Affiche les tontines actives

---

### 4. **deployment_diagram.puml** - Diagramme de Déploiement
Montre l'architecture physique du système et ses composants.

**Composants :**
- **Flutter App** : Application client (UI Membre + UI Admin)
- **Data Layer** : Couche de gestion des données (SharedData + Storage)
- **Payment Layer** : Simulation de paiement Stripe
- **Backend Services** : Serveur API + Base de données

---

## 🚀 Comment visualiser les diagrammes

### Option 1 : En ligne (Recommandé)
Utilisez [PlantUML Online Editor](http://www.plantuml.com/plantuml/uml/)
1. Copiez le contenu d'un fichier .puml
2. Collez-le dans l'éditeur
3. Visualisez le diagramme généré

### Option 2 : Localement avec VS Code
1. Installez l'extension "PlantUML" (jgraph.drawio ou similar)
2. Ouvrez un fichier .puml
3. Prévisualisez avec `Alt+D`

### Option 3 : Ligne de commande
```bash
plantuml use_case_diagram.puml
plantuml class_diagram.puml
plantuml sequence_diagrams.puml
plantuml deployment_diagram.puml
```

---

## 📐 Architecture du Système

```
┌─────────────────────────────────────────────────┐
│         Flutter Application (Frontend)          │
├─────────────────────────────────────────────────┤
│  Membre Pages  │  Admin Pages  │  Common Widgets│
│  ├─ Home       │  ├─ Paiements │  ├─ Payment   │
│  ├─ Paiements  │  ├─ Tontines  │  ├─ Stripe   │
│  └─ Tontines   │  └─ Rapports  │  └─ Dialogs  │
└─────────────────────────────────────────────────┘
           ↓ Uses
┌─────────────────────────────────────────────────┐
│         Data Management Layer                   │
├─────────────────────────────────────────────────┤
│  SharedData (Singleton Pattern)                │
│  ├─ membres[]                                  │
│  ├─ tontines[]                                 │
│  └─ paiements[]                                │
└─────────────────────────────────────────────────┘
           ↓ Stores
┌─────────────────────────────────────────────────┐
│    Local Storage & Backend Services            │
├─────────────────────────────────────────────────┤
│  Shared Preferences  │  API Server  │  Database│
└─────────────────────────────────────────────────┘
```

---

## 🔑 Patterns et Principes Utilisés

- **Singleton Pattern** : SharedData pour accès centralisé aux données
- **MVC Pattern** : Séparation des préoccupations (Pages = Views, SharedData = Model)
- **Observer Pattern** : StatefulWidget pour réactivité UI
- **Strategy Pattern** : StripePaymentSimulation pour paiements

---

## 📝 Notes

- Les diagrammes peuvent être modifiés en éditant les fichiers .puml
- Les relations entre classes suivent la cardinalité UML standard
- Les séquences montrent les appels synchrones principaux (pas tout le code asynchrone)
- Les couleurs et styles peuvent être personnalisés dans les fichiers .puml

---

**Dernière mise à jour** : Février 2026
**Projet** : SenTontine - Gestion de Tontines

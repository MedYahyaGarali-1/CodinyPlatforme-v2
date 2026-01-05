# Cahier des Charges - Codiny Platform
## Application Mobile d'Apprentissage du Code de la Route

---

**Projet**: Codiny Platform  
**Étudiant**: [Votre Nom]  
**Date**: 5 Janvier 2026  
**Version**: 1.0

---

## 1. Présentation du Projet

### 1.1 Contexte
Le projet **Codiny Platform** est une application mobile destinée à l'apprentissage du code de la route en Tunisie. Elle vise à digitaliser le processus d'enseignement du code de la route en connectant les étudiants candidats au permis de conduire avec les auto-écoles.

### 1.2 Objectif Général
Créer une plateforme numérique permettant aux candidats d'apprendre le code de la route (Permis A, B, C) tout en offrant aux auto-écoles un système de gestion et de monétisation de leurs étudiants.

### 1.3 Problématique
- Manque de ressources digitales modernes pour l'apprentissage du code
- Difficulté pour les auto-écoles de gérer leurs étudiants
- Besoin d'une solution de génération de revenus pour les écoles
- Absence de suivi de progression pour les étudiants

---

## 2. Acteurs du Système

### 2.1 Étudiant
**Rôle**: Apprenant candidat au permis de conduire

**Besoins**:
- S'inscrire et créer un compte personnel
- Choisir le type de permis (A, B ou C)
- Accéder aux cours et leçons interactifs
- Passer des examens blancs
- Consulter le calendrier des événements de son école
- Suivre sa progression

### 2.2 Auto-école
**Rôle**: Partenaire commercial et gestionnaire d'étudiants

**Besoins**:
- S'inscrire comme établissement
- Rechercher et activer des étudiants
- Gérer un calendrier d'événements
- Consulter les revenus générés
- Suivre les statistiques des étudiants

### 2.3 Administrateur
**Rôle**: Gestionnaire de la plateforme

**Besoins**:
- Gérer le contenu pédagogique (cours, examens)
- Superviser les utilisateurs
- Accéder aux statistiques globales

---

## 3. Modèle Économique

### 3.1 Principe
**Activation par auto-école**: 50 TND par étudiant

**Répartition**:
- 20 TND → Auto-école
- 30 TND → Plateforme

### 3.2 Workflow
1. L'étudiant s'inscrit gratuitement
2. L'étudiant visite son auto-école physiquement
3. L'école recherche l'étudiant par son ID unique
4. L'école active l'étudiant (paiement 50 TND)
5. L'étudiant obtient l'accès complet au contenu
6. Les revenus sont répartis automatiquement

**Note**: Aucun abonnement direct - Les étudiants paient uniquement via leur auto-école.

---

## 4. Spécifications Fonctionnelles

### 4.1 Module Étudiant

#### F1.1 - Inscription et Authentification
- Inscription avec email et mot de passe
- Connexion sécurisée avec JWT
- Gestion de profil

#### F1.2 - Onboarding (Choix du Permis)
- Écran de sélection avec 3 cartes interactives
- Permis A (Moto) 🏍️ - Contenu à venir
- Permis B (Voiture) 🚗 - Disponible
- Permis C (Camion) 🚛 - Contenu à venir
- Choix unique et définitif

#### F1.3 - Apprentissage
- Accès aux cours par permis choisi
- Consultation de leçons (texte, images, vidéos)
- Navigation fluide entre chapitres
- Sauvegarde automatique de la progression

#### F1.4 - Examens Blancs
- Examens chronométrés avec questions
- Images de panneaux de signalisation tunisiens
- Correction immédiate avec explications
- Historique des résultats

#### F1.5 - Calendrier
- Visualisation des événements de l'auto-école
- Détails des rendez-vous (conduite, examens)
- Synchronisation en temps réel

#### F1.6 - Tableau de Bord
- Aperçu des cours disponibles
- Progression globale
- Statut d'activation (Actif/En attente)
- Statistiques personnelles

### 4.2 Module Auto-école

#### F2.1 - Gestion des Étudiants
- Recherche d'étudiants par Student ID
- Activation/Ajout d'étudiants à l'école
- Liste des étudiants actifs et inactifs
- Désactivation si nécessaire

#### F2.2 - Gestion Financière
- Dashboard des revenus en temps réel
- Détail des revenus par étudiant
- Total des revenus générés
- Nombre d'étudiants activés

#### F2.3 - Gestion d'Événements
- Création d'événements (sessions de conduite, examens)
- Modification et suppression d'événements
- Calendrier visuel
- Notification automatique aux étudiants attachés

#### F2.4 - Profil et Statistiques
- Informations de l'école (nom, adresse, téléphone)
- Statistiques globales
- Paramètres du compte

### 4.3 Module Administrateur

#### F3.1 - Gestion du Contenu
- CRUD des cours et leçons
- Import de questions d'examens
- Upload d'images et ressources
- Organisation par type de permis

#### F3.2 - Gestion des Utilisateurs
- Liste de tous les utilisateurs
- Modération des comptes
- Statistiques d'utilisation

---

## 5. Spécifications Techniques

### 5.1 Architecture Logicielle

#### Frontend (Application Mobile)
- **Framework**: Flutter/Dart
- **Interface**: Material Design 3
- **Gestion d'état**: Provider
- **Navigation**: Named Routes
- **Stockage local**: Flutter Secure Storage
- **Plateformes**: Android (actuel), iOS (à venir)

#### Backend (API REST)
- **Runtime**: Node.js 18+
- **Framework**: Express.js
- **Base de données**: PostgreSQL
- **Authentification**: JWT (JSON Web Tokens)
- **Hébergement**: Railway avec auto-déploiement
- **URL Production**: https://codinyplatforme-v2-production.up.railway.app

### 5.2 Base de Données

#### Tables Principales
```sql
users                -- Utilisateurs (tous rôles)
students             -- Profils étudiants
schools              -- Profils auto-écoles
courses              -- Cours de formation
lessons              -- Leçons par cours
exams                -- Examens blancs
questions            -- Questions d'examens
revenue_tracking     -- Suivi des revenus
school_events        -- Événements des écoles
```

#### Champs Critiques - Table Students
```sql
id                        -- Identifiant unique
user_id                   -- Référence vers users
student_type              -- 'independent' ou 'attached_to_school'
permit_type               -- 'A', 'B' ou 'C'
school_id                 -- Référence vers schools (nullable)
is_active                 -- Booléen d'activation
access_level              -- 'none', 'limited', 'full'
access_method             -- 'independent' ou 'school_linked'
school_approval_status    -- 'pending', 'approved', 'rejected'
onboarding_complete       -- Booléen de complétion onboarding
subscription_start_date   -- Date de début d'accès
subscription_end_date     -- Date de fin d'accès (30 jours)
```

### 5.3 API REST - Endpoints Principaux

#### Authentification
```
POST   /api/auth/register         -- Inscription
POST   /api/auth/login            -- Connexion
POST   /api/auth/logout           -- Déconnexion
GET    /api/auth/me               -- Profil actuel
```

#### Étudiants
```
GET    /api/students/me                          -- Mon profil
GET    /api/students/me/access-status            -- Vérification accès
POST   /api/students/onboarding/choose-permit    -- Choix permis
```

#### Auto-écoles
```
GET    /api/schools/me                    -- Profil école
GET    /api/schools/students              -- Liste étudiants
POST   /api/schools/students/search       -- Recherche par ID
POST   /api/schools/students/activate     -- Activation étudiant
GET    /api/schools/financial-report      -- Rapport financier
```

#### Cours et Examens
```
GET    /api/courses                -- Liste des cours
GET    /api/courses/:id            -- Détail cours
GET    /api/exams                  -- Liste examens
POST   /api/exams/:id/submit       -- Soumission réponses
```

### 5.4 Sécurité

#### Authentification
- Hachage des mots de passe avec **bcrypt** (10 rounds)
- Tokens JWT avec expiration de 7 jours
- Middleware de vérification sur routes protégées

#### Protection des Données
- Requêtes paramétrées (prévention SQL injection)
- Validation des entrées (express-validator)
- CORS configuré pour domaines autorisés
- Rate limiting (100 requêtes/15 minutes)

#### Contrôle d'Accès
- Système de rôles (student, school, admin)
- Widget AccessGuard côté frontend
- Vérification serveur via `calculateStudentAccess()`
- Timeout de 10 secondes pour éviter blocages

---

## 6. Logique Métier - Système d'Accès

### 6.1 États d'un Étudiant

#### État 1: Inscrit (Non activé)
```
student_type = 'independent'
is_active = false
access_level = 'none'
onboarding_complete = false
```
**Résultat**: Pas d'accès aux cours

#### État 2: Permis Choisi (Non activé)
```
student_type = 'independent'
permit_type = 'A', 'B' ou 'C'
is_active = false
onboarding_complete = true
```
**Résultat**: Message "Donnez votre Student ID à votre auto-école"

#### État 3: Activé par École
```
student_type = 'attached_to_school'
school_id = [ID école]
is_active = true
access_level = 'full'
access_method = 'school_linked'
school_approval_status = 'approved'
```
**Résultat**: Accès complet aux cours et examens

### 6.2 Processus d'Activation

**Backend - Endpoints `/activate` et `/attach`**:
```javascript
// 1. Mise à jour de l'étudiant
UPDATE students SET
  student_type = 'attached_to_school',
  school_id = [ID école],
  is_active = TRUE,
  access_level = 'full',
  access_method = 'school_linked',
  school_approval_status = 'approved',
  subscription_start_date = CURRENT_DATE,
  subscription_end_date = CURRENT_DATE + 30 days
WHERE id = [ID étudiant]

// 2. Enregistrement des revenus
INSERT INTO revenue_tracking (
  student_id, school_id, 
  school_revenue, platform_revenue, total_amount
) VALUES (
  [ID étudiant], [ID école],
  20.00, 30.00, 50.00
)

// 3. Mise à jour des compteurs école
UPDATE schools SET
  total_revenue = total_revenue + 20.00,
  students_count = students_count + 1
WHERE id = [ID école]
```

---

## 7. Parcours Utilisateurs

### 7.1 Parcours Étudiant

```
┌─────────────────────────────────────────────────────────────┐
│                     PARCOURS ÉTUDIANT                       │
└─────────────────────────────────────────────────────────────┘

1. Page d'accueil
   └─> Clic "S'inscrire"

2. Formulaire d'inscription
   └─> Saisie: Email, Mot de passe, Nom
   └─> Validation et création compte

3. Écran Onboarding
   └─> Choix du permis: A 🏍️, B 🚗, ou C 🚛
   └─> Confirmation du choix

4. Dashboard (État: Non activé)
   └─> Message: "En attente d'activation par une auto-école"
   └─> Affichage du Student ID unique
   └─> Instruction: Donner l'ID à votre auto-école

5. École active l'étudiant
   └─> Système met à jour le statut

6. Dashboard (État: Activé)
   └─> Accès complet aux cours
   └─> Accès aux examens blancs
   └─> Consultation du calendrier école
```

### 7.2 Parcours Auto-école

```
┌─────────────────────────────────────────────────────────────┐
│                   PARCOURS AUTO-ÉCOLE                       │
└─────────────────────────────────────────────────────────────┘

1. Page d'accueil
   └─> Clic "Inscription Auto-école"

2. Formulaire d'inscription école
   └─> Saisie: Nom école, Email, Téléphone, Adresse
   └─> Validation et création compte

3. Dashboard école
   └─> Vue d'ensemble: Statistiques, revenus

4. Gestion des étudiants
   └─> Clic "Ajouter un étudiant"
   └─> Saisie du Student ID fourni par l'étudiant
   └─> Clic "Rechercher"

5. Résultat de recherche
   └─> Affichage: Nom, Permis choisi, État
   └─> Clic "Activer l'étudiant"

6. Confirmation d'activation
   └─> Système génère les revenus
   └─> École: +20 TND
   └─> Plateforme: +30 TND
   └─> Notification de succès

7. Gestion continue
   └─> Création d'événements au calendrier
   └─> Suivi des étudiants actifs
   └─> Consultation des rapports financiers
```

---

## 8. Contraintes et Exigences

### 8.1 Contraintes Techniques

#### Performance
- Temps de réponse API: < 2 secondes
- Chargement de l'application: < 3 secondes
- Timeout AccessGuard: 10 secondes maximum

#### Compatibilité
- Android: Version 5.0 (API 21) et supérieure
- iOS: Version 11.0 et supérieure (à venir)
- Navigateurs web: Chrome, Firefox, Safari (dernières versions)

#### Disponibilité
- Uptime cible: 99.9%
- Sauvegardes automatiques quotidiennes
- Plan de reprise après incident

### 8.2 Contraintes Fonctionnelles

#### Données
- Un étudiant = Un seul permis
- Un étudiant = Une seule auto-école à la fois
- Activation = Durée de 30 jours (renouvelable)

#### Sécurité
- Mots de passe: Minimum 6 caractères
- Sessions: Expiration après 7 jours d'inactivité
- Données sensibles: Chiffrées au repos et en transit

### 8.3 Contraintes Métier

#### Revenus
- Montant fixe: 50 TND par activation
- Répartition non modifiable: 20/30 TND
- Pas de remboursement automatique

#### Contenu
- Contenu Permis B: Complet et validé
- Contenu Permis A et C: En développement
- Questions d'examen: Conformes au code tunisien

---

## 9. Technologies Utilisées

### 9.1 Frontend Mobile
- **Flutter SDK 3.x**: Framework de développement cross-platform
- **Dart 3.x**: Langage de programmation
- **Provider**: Gestion d'état
- **HTTP**: Communication avec l'API
- **Flutter Secure Storage**: Stockage sécurisé des tokens

### 9.2 Backend
- **Node.js 18+**: Runtime JavaScript
- **Express.js**: Framework web
- **PostgreSQL 14+**: Base de données relationnelle
- **JWT**: Authentification stateless
- **bcrypt**: Hachage de mots de passe

### 9.3 Déploiement
- **Railway**: Hébergement backend et base de données
- **GitHub**: Contrôle de version
- **CI/CD**: Déploiement automatique sur push

### 9.4 Outils de Développement
- **Visual Studio Code**: IDE principal
- **Git**: Contrôle de version
- **Postman**: Test des API
- **pgAdmin**: Gestion de la base de données

---

## 10. État Actuel du Projet

### 10.1 Fonctionnalités Complétées ✅

#### Backend
- ✅ API REST complète et déployée
- ✅ Authentification JWT fonctionnelle
- ✅ Base de données structurée et migrée
- ✅ Système de revenus avec table de tracking
- ✅ Endpoints d'activation testés
- ✅ Contrôle d'accès implémenté

#### Frontend
- ✅ Application Flutter fonctionnelle
- ✅ Écran d'inscription et connexion
- ✅ Onboarding avec choix de permis
- ✅ Dashboard étudiant avec AccessGuard
- ✅ Liste et détail des cours
- ✅ Dashboard auto-école
- ✅ Recherche et activation d'étudiants
- ✅ Calendrier d'événements
- ✅ Navigation corrigée (pas d'écran noir)

#### Contenu
- ✅ Cours complets pour Permis B
- ✅ Examens blancs avec questions
- ✅ Images de panneaux tunisiens

### 10.2 En Cours 🚧
- APK en phase de rebuild final
- Tests end-to-end en cours

### 10.3 À Venir 🔮
- Contenu pour Permis A (Moto)
- Contenu pour Permis C (Camion)
- Notifications push
- Mode hors ligne
- Version iOS
- Support multilingue (Arabe/Français)

---

## 11. Planning Prévisionnel

### Phase 1 - MVP (Complétée)
**Durée**: 3 mois  
**Statut**: ✅ Terminée

- Conception de l'architecture
- Développement backend
- Développement frontend
- Intégration et tests
- Déploiement sur Railway

### Phase 2 - Amélioration (En cours)
**Durée**: 1 mois  
**Statut**: 🚧 En cours

- Tests utilisateurs
- Corrections de bugs
- Optimisations de performance
- Documentation

### Phase 3 - Extension (À venir)
**Durée**: 3-6 mois  
**Statut**: 📅 Planifiée

- Développement contenu Permis A et C
- Système de notifications
- Mode hors ligne
- Version iOS

---

## 12. Livrables

### 12.1 Livrables Techniques
- ✅ Code source complet (GitHub)
- ✅ Application mobile (APK Android)
- ✅ API REST déployée et documentée
- ✅ Base de données structurée
- ✅ Documentation technique (CAHIER_DES_CHARGES.md)

### 12.2 Livrables Fonctionnels
- ✅ Application mobile testée
- ✅ Contenu pédagogique Permis B
- ✅ Interface d'administration
- ✅ Système de revenus opérationnel
- ✅ Guide d'utilisation

---

## 13. Conclusion

Le projet **Codiny Platform** représente une solution complète et moderne pour l'apprentissage du code de la route en Tunisie. L'application répond aux besoins des trois acteurs principaux :

- **Étudiants**: Apprentissage interactif et suivi de progression
- **Auto-écoles**: Gestion digitale et génération de revenus
- **Plateforme**: Modèle économique durable

Le MVP est actuellement fonctionnel avec le contenu complet pour le Permis B. L'architecture technique est scalable et permettra d'ajouter facilement le contenu pour les Permis A et C, ainsi que de nouvelles fonctionnalités.

---

## 14. Annexes

### 14.1 Liens Utiles
- **Repository GitHub**: https://github.com/MedYahyaGarali-1/CodinyPlatforme-v2
- **Backend Production**: https://codinyplatforme-v2-production.up.railway.app
- **Documentation complète**: CAHIER_DES_CHARGES.md
- **Vue d'ensemble**: PROJECT_OVERVIEW.md

### 14.2 Glossaire
- **JWT**: JSON Web Token (système d'authentification)
- **API REST**: Interface de programmation web
- **Flutter**: Framework de développement mobile
- **PostgreSQL**: Système de gestion de base de données
- **Railway**: Plateforme d'hébergement cloud
- **AccessGuard**: Widget de contrôle d'accès
- **Onboarding**: Processus d'intégration utilisateur

---

**Document préparé pour**: [Nom de votre enseignant]  
**Institution**: [Nom de votre établissement]  
**Date de remise**: 5 Janvier 2026

---

*Projet réalisé dans le cadre de [Nom du cours/module]*

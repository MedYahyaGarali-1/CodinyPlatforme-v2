# Cahier des Charges - Codiny Platform

## 📋 Table des Matières
1. [Présentation Générale](#présentation-générale)
2. [Objectifs du Projet](#objectifs-du-projet)
3. [Architecture Technique](#architecture-technique)
4. [Fonctionnalités](#fonctionnalités)
5. [Acteurs du Système](#acteurs-du-système)
6. [Parcours Utilisateurs](#parcours-utilisateurs)
7. [Système de Permis](#système-de-permis)
8. [Gestion des Accès](#gestion-des-accès)
9. [Système de Revenus](#système-de-revenus)
10. [Spécifications Techniques](#spécifications-techniques)
11. [Sécurité](#sécurité)
12. [Déploiement](#déploiement)

---

## 1. Présentation Générale

### 1.1 Description
**Codiny Platform** est une application mobile et web de formation au code de la route en Tunisie. Elle permet aux étudiants d'apprendre le code de la route selon trois types de permis (A, B, C) tout en offrant aux auto-écoles un système de gestion et de monétisation de leurs étudiants.

### 1.2 Contexte
- **Marché cible**: Tunisie
- **Public**: Candidats au permis de conduire (Moto, Voiture, Camion)
- **Partenaires**: Auto-écoles tunisiennes
- **Devise**: Dinar Tunisien (TND)

### 1.3 Modèle économique
- **Activation par auto-école**: 50 TND par étudiant
  - 20 TND pour l'auto-école
  - 30 TND pour la plateforme
- **Aucun abonnement direct**: Les étudiants sont activés uniquement par les auto-écoles

---

## 2. Objectifs du Projet

### 2.1 Objectifs principaux
1. ✅ Fournir une plateforme d'apprentissage du code de la route accessible via mobile/web
2. ✅ Permettre aux auto-écoles de gérer et activer leurs étudiants
3. ✅ Générer des revenus pour les auto-écoles et la plateforme
4. ✅ Offrir une expérience utilisateur fluide et moderne

### 2.2 Objectifs secondaires
1. ✅ Intégrer un système de calendrier pour les événements des auto-écoles
2. ✅ Fournir des examens blancs pour la préparation
3. ✅ Permettre le suivi des progrès des étudiants
4. ✅ Offrir un tableau de bord financier pour les auto-écoles

---

## 3. Architecture Technique

### 3.1 Stack Technologique

#### Frontend (Application Mobile)
- **Framework**: Flutter/Dart
- **UI**: Material Design 3
- **State Management**: Provider
- **Navigation**: Named Routes (AppRouter)
- **Authentification**: JWT Token Storage

#### Backend (API)
- **Runtime**: Node.js 18+
- **Framework**: Express.js
- **Base de données**: PostgreSQL
- **Hébergement**: Railway (auto-deployment via GitHub)
- **URL Production**: `https://codinyplatforme-v2-production.up.railway.app`

#### Outils de développement
- **IDE**: Visual Studio Code
- **Contrôle de version**: Git/GitHub
- **CI/CD**: Railway auto-deploy on push to main
- **Build APK**: Flutter build tools

### 3.2 Architecture de données

#### Tables principales
1. **users**: Utilisateurs (étudiants, écoles, admins)
2. **students**: Profils étudiants avec informations d'accès
3. **schools**: Profils auto-écoles
4. **courses**: Cours de formation
5. **lessons**: Leçons par cours
6. **exams**: Examens blancs
7. **questions**: Questions d'examens
8. **revenue_tracking**: Suivi des revenus
9. **school_events**: Événements des auto-écoles

---

## 4. Fonctionnalités

### 4.1 Fonctionnalités Étudiants

#### ✅ Inscription et Onboarding
- Inscription avec email/mot de passe
- Choix du type de permis (A, B, ou C)
- Interface moderne avec cartes de sélection
- Validation email (optionnelle)

#### ✅ Apprentissage
- Accès aux cours par permis choisi
- Consultation des leçons avec texte, images, vidéos
- Navigation fluide entre les chapitres
- Progression sauvegardée automatiquement

#### ✅ Examens Blancs
- Examens chronométrés
- Questions avec images de panneaux de signalisation
- Correction immédiate avec explications
- Historique des résultats

#### ✅ Calendrier
- Visualisation des événements de l'auto-école
- Notifications pour les rendez-vous importants
- Synchronisation en temps réel

#### ✅ Tableau de Bord
- Aperçu des cours disponibles
- Progression globale
- Statut d'activation (Actif/En attente)
- Accès rapide aux fonctionnalités

### 4.2 Fonctionnalités Auto-écoles

#### ✅ Gestion des Étudiants
- Recherche d'étudiants par Student ID
- Activation/Ajout d'étudiants à l'école
- Liste des étudiants actifs
- Statistiques en temps réel

#### ✅ Gestion Financière
- Tableau de bord des revenus
- Détail des revenus par étudiant
- Total des revenus générés
- Nombre d'étudiants activés

#### ✅ Gestion d'Événements
- Création d'événements (examens, sessions de conduite, etc.)
- Modification et suppression d'événements
- Notification automatique aux étudiants
- Calendrier visuel

#### ✅ Profil
- Informations de l'école (nom, adresse, téléphone)
- Statistiques globales
- Paramètres du compte

### 4.3 Fonctionnalités Administrateur

#### ✅ Gestion des Contenus
- Création/modification/suppression de cours
- Gestion des leçons et chapitres
- Import de questions d'examens
- Upload d'images et ressources

#### ✅ Gestion des Utilisateurs
- Liste de tous les utilisateurs
- Modération des comptes
- Statistiques globales

#### ✅ Monitoring
- Logs système
- Performances de l'application
- Rapports d'erreurs

---

## 5. Acteurs du Système

### 5.1 Étudiant
**Rôle**: Utilisateur final apprenant le code de la route

**Droits**:
- S'inscrire et créer un compte
- Choisir un type de permis
- Consulter les cours (si activé)
- Passer des examens blancs (si activé)
- Voir le calendrier de son école (si attaché)
- Gérer son profil

**États**:
- `independent` + `inactive`: Inscrit, pas encore attaché à une école
- `attached_to_school` + `active`: Attaché et activé par une école
- `attached_to_school` + `inactive`: Attaché mais désactivé

### 5.2 Auto-école
**Rôle**: Partenaire commercial gérant des étudiants

**Droits**:
- S'inscrire comme auto-école
- Chercher et activer des étudiants
- Créer et gérer des événements
- Consulter les revenus générés
- Gérer le profil de l'école

**Responsabilités**:
- Vérifier l'identité des étudiants avant activation
- Créer des événements pour les étudiants
- Assurer le suivi pédagogique

### 5.3 Administrateur
**Rôle**: Gestionnaire de la plateforme

**Droits**:
- Accès complet à tous les contenus
- Gestion des utilisateurs
- Création de cours et examens
- Consultation des statistiques globales
- Modération du contenu

---

## 6. Parcours Utilisateurs

### 6.1 Parcours Étudiant - Inscription

```
┌─────────────────────┐
│  Page d'Accueil     │
│  "S'inscrire"       │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Formulaire         │
│  - Email            │
│  - Mot de passe     │
│  - Nom              │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Onboarding         │
│  Choix du Permis    │
│  ┌───┐ ┌───┐ ┌───┐ │
│  │ A │ │ B │ │ C │ │
│  └───┘ └───┘ └───┘ │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Dashboard          │
│  "En attente        │
│   d'activation"     │
└─────────────────────┘
```

**États**:
1. Inscrit: `student_type='independent'`, `is_active=false`, `onboarding_complete=false`
2. Permis choisi: `onboarding_complete=true`, `permit_type='A/B/C'`
3. En attente: Message "Donnez votre Student ID à votre auto-école"

### 6.2 Parcours Étudiant - Activation par Auto-école

```
┌─────────────────────┐
│  École cherche      │
│  étudiant par ID    │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  École clique       │
│  "Activer"          │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Système met à jour │
│  - Type: attached   │
│  - Active: true     │
│  - Accès: full      │
│  - Revenus: +50 TND │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Étudiant peut      │
│  accéder aux cours  │
└─────────────────────┘
```

**Champs mis à jour**:
```sql
student_type = 'attached_to_school'
school_id = <ID_école>
is_active = TRUE
access_level = 'full'
access_method = 'school_linked'
school_approval_status = 'approved'
subscription_start_date = CURRENT_DATE
subscription_end_date = CURRENT_DATE + 30 days
```

### 6.3 Parcours École - Activation Étudiant

```
┌─────────────────────┐
│  Dashboard École    │
│  "Étudiants"        │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Recherche          │
│  [Student ID____]   │
│  🔍 Chercher        │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Résultat trouvé    │
│  Nom: Ahmed Ben Ali │
│  Permis: B          │
│  [✅ Activer]       │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Confirmation       │
│  "Étudiant activé"  │
│  Revenus: +20 TND   │
└─────────────────────┘
```

### 6.4 Parcours Étudiant - Apprentissage

```
┌─────────────────────┐
│  Dashboard          │
│  [📚 Mes Cours]     │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  AccessGuard        │
│  ✓ Vérifie accès    │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Liste des Cours    │
│  - Code de la route │
│  - Panneaux         │
│  - Priorités        │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Détail du Cours    │
│  Chapitres et       │
│  Leçons             │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Leçon              │
│  Texte + Images     │
│  Vidéos             │
│  [← Retour]         │
└─────────────────────┘
```

**Navigation importante**:
- Bouton retour utilise `pushReplacementNamed('/student')` pour éviter l'écran noir
- AccessGuard vérifie l'accès avant chaque page protégée
- Timeout de 10 secondes pour éviter chargement infini

---

## 7. Système de Permis

### 7.1 Types de Permis

#### Permis A - Motocyclette 🏍️
- **Véhicules**: Motos, scooters
- **Statut**: 🚧 Contenu à venir (Coming Soon)
- **Base de données**: `permit_type = 'A'`

#### Permis B - Voiture 🚗
- **Véhicules**: Voitures particulières
- **Statut**: ✅ Contenu complet disponible
- **Base de données**: `permit_type = 'B'`
- **Contenu**:
  - Cours de code de la route
  - Panneaux de signalisation
  - Règles de priorité
  - Examens blancs

#### Permis C - Camion 🚛
- **Véhicules**: Poids lourds, camions
- **Statut**: 🚧 Contenu à venir (Coming Soon)
- **Base de données**: `permit_type = 'C'`

### 7.2 Sélection du Permis

#### Interface Onboarding
```dart
// 3 cartes côte à côte avec animation
_PermitCard(
  icon: '🏍️',
  permitType: 'A',
  title: 'Permis A',
  description: 'Motocyclette',
  isComingSoon: true,
)

_PermitCard(
  icon: '🚗',
  permitType: 'B',
  title: 'Permis B',
  description: 'Voiture',
  isComingSoon: false,
)

_PermitCard(
  icon: '🚛',
  permitType: 'C',
  title: 'Permis C',
  description: 'Camion',
  isComingSoon: true,
)
```

#### Contraintes
- Un seul permis par étudiant
- Choix définitif après sélection
- Modification nécessite contact avec support

### 7.3 Endpoint de Choix

**POST** `/api/students/onboarding/choose-permit`

**Request**:
```json
{
  "permit_type": "B"
}
```

**Response**:
```json
{
  "message": "Permit type updated successfully",
  "student": {
    "id": 123,
    "permit_type": "B",
    "onboarding_complete": true
  }
}
```

---

## 8. Gestion des Accès

### 8.1 Principe de Contrôle d'Accès

Le système utilise un widget `AccessGuard` qui vérifie les permissions avant d'afficher le contenu protégé.

#### Composant AccessGuard
```dart
AccessGuard(
  requiresFullAccess: true,
  featureName: 'courses',
  child: CoursesScreen(),
)
```

### 8.2 Logique de Vérification

#### Frontend: `lib/shared/ui/access_guard.dart`
```dart
Future<AccessStatusResponse> _checkAccess(BuildContext context) async {
  final token = context.read<SessionController>().token;
  final repo = OnboardingRepository();
  
  return await repo.getAccessStatus(token: token).timeout(
    const Duration(seconds: 10),
    onTimeout: () => throw Exception('Access check timed out'),
  );
}
```

#### Backend: `backend/utils/accessControl.js`
```javascript
function calculateStudentAccess(student) {
  // Vérifie si étudiant est actif
  if (!student.is_active) {
    return {
      isActive: false,
      canAccessCourses: false,
      reason: 'school_pending',
      message: 'Donnez votre Student ID à votre auto-école'
    };
  }
  
  // Vérifie la méthode d'accès
  if (student.access_method !== 'school_linked') {
    return {
      isActive: false,
      canAccessCourses: false,
      reason: 'invalid_access_method'
    };
  }
  
  // Tout est OK
  return {
    isActive: true,
    canAccessCourses: true,
    canAccessExams: true,
    accessLevel: 'full'
  };
}
```

### 8.3 Champs de Base de Données

#### Table `students`
```sql
-- Champs d'accès critiques
is_active BOOLEAN DEFAULT FALSE,
access_level VARCHAR(20) DEFAULT 'none',
access_method VARCHAR(50),  -- 'independent' ou 'school_linked'
school_approval_status VARCHAR(20),  -- 'approved', 'pending', 'rejected'
student_type VARCHAR(50) DEFAULT 'independent',  -- ou 'attached_to_school'
```

### 8.4 États d'Accès Possibles

| État | is_active | access_method | school_id | Résultat |
|------|-----------|---------------|-----------|----------|
| Inscrit | false | NULL | NULL | ❌ Pas d'accès - "En attente d'activation" |
| Activé | true | 'school_linked' | 123 | ✅ Accès complet |
| Désactivé | false | 'school_linked' | 123 | ❌ Pas d'accès - "Compte désactivé" |

### 8.5 Écrans de Blocage

#### Étudiant non activé
```
┌─────────────────────────────┐
│         🏫                  │
│                             │
│  School Activation Required │
│                             │
│  Give your Student ID to    │
│  your school to activate    │
│  your account               │
│                             │
│  [Go to Dashboard]          │
└─────────────────────────────┘
```

#### Contenu Premium (future)
```
┌─────────────────────────────┐
│         🔒                  │
│                             │
│    Premium Content          │
│                             │
│  Subscribe to access        │
│  advanced features          │
│                             │
│  [View Plans & Subscribe]   │
└─────────────────────────────┘
```

---

## 9. Système de Revenus

### 9.1 Modèle de Revenus

#### Activation = 50 TND
- **20 TND** → Revenu de l'auto-école
- **30 TND** → Revenu de la plateforme
- **Total**: 50 TND par étudiant activé

### 9.2 Table revenue_tracking

```sql
CREATE TABLE revenue_tracking (
  id SERIAL PRIMARY KEY,
  student_id INTEGER REFERENCES students(id),
  school_id INTEGER REFERENCES schools(id),
  school_revenue DECIMAL(10, 2) DEFAULT 20.00,
  platform_revenue DECIMAL(10, 2) DEFAULT 30.00,
  total_amount DECIMAL(10, 2) DEFAULT 50.00,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 9.3 Enregistrement des Revenus

#### Lors de l'activation
```javascript
// Dans /students/activate et /students/attach
await pool.query(`
  INSERT INTO revenue_tracking (
    student_id, 
    school_id, 
    school_revenue, 
    platform_revenue, 
    total_amount
  ) VALUES ($1, $2, 20.00, 30.00, 50.00)
`, [studentId, schoolId]);

// Mise à jour du compteur école
await pool.query(`
  UPDATE schools 
  SET 
    total_revenue = total_revenue + 20.00,
    students_count = students_count + 1
  WHERE id = $1
`, [schoolId]);
```

### 9.4 Affichage Dashboard École

**Endpoint**: `GET /api/schools/me`

**Response**:
```json
{
  "school": {
    "id": 5,
    "name": "Auto-École El Mourouj",
    "email": "contact@autoecole.tn",
    "students_count": 45,
    "total_revenue": "900.00"
  },
  "stats": {
    "activeStudents": 42,
    "inactiveStudents": 3,
    "totalRevenue": "900.00",
    "revenueThisMonth": "240.00"
  }
}
```

**Affichage**:
```
┌────────────────────────────┐
│  💰 Revenus Générés        │
│                            │
│  900.00 TND                │
│  (45 étudiants activés)    │
└────────────────────────────┘
```

### 9.5 Rapport Financier

**Endpoint**: `GET /api/schools/financial-report`

**Response**:
```json
{
  "report": [
    {
      "student_name": "Ahmed Ben Ali",
      "student_id": "STU001",
      "activation_date": "2026-01-01",
      "school_revenue": "20.00",
      "platform_revenue": "30.00",
      "total": "50.00"
    },
    // ...
  ],
  "summary": {
    "total_students": 45,
    "school_total": "900.00",
    "platform_total": "1350.00",
    "grand_total": "2250.00"
  }
}
```

---

## 10. Spécifications Techniques

### 10.1 Endpoints API Principaux

#### Authentification
```
POST /api/auth/register
POST /api/auth/login
POST /api/auth/logout
GET  /api/auth/me
```

#### Étudiants
```
GET    /api/students/me
GET    /api/students/me/access-status
POST   /api/students/onboarding/choose-permit
GET    /api/students/:id
PUT    /api/students/:id
```

#### Auto-écoles
```
GET    /api/schools/me
PUT    /api/schools/me
GET    /api/schools/students
POST   /api/schools/students/search
POST   /api/schools/students/activate
POST   /api/schools/students/attach
GET    /api/schools/financial-report
```

#### Cours
```
GET    /api/courses
GET    /api/courses/:id
GET    /api/courses/:id/lessons
POST   /api/courses (admin)
PUT    /api/courses/:id (admin)
DELETE /api/courses/:id (admin)
```

#### Examens
```
GET    /api/exams
GET    /api/exams/:id
POST   /api/exams/:id/submit
GET    /api/exams/:id/results
```

#### Événements
```
GET    /api/events
GET    /api/events/school/:schoolId
POST   /api/events (école)
PUT    /api/events/:id (école)
DELETE /api/events/:id (école)
```

### 10.2 Modèle de Données Principal

#### User
```typescript
interface User {
  id: number;
  email: string;
  password_hash: string;
  name: string;
  role: 'student' | 'school' | 'admin';
  created_at: Date;
  last_login: Date;
}
```

#### Student
```typescript
interface Student {
  id: number;
  user_id: number;
  student_type: 'independent' | 'attached_to_school';
  permit_type: 'A' | 'B' | 'C' | null;
  school_id: number | null;
  is_active: boolean;
  access_level: 'none' | 'limited' | 'full';
  access_method: 'independent' | 'school_linked' | null;
  school_approval_status: 'pending' | 'approved' | 'rejected' | null;
  onboarding_complete: boolean;
  subscription_start_date: Date | null;
  subscription_end_date: Date | null;
  created_at: Date;
}
```

#### School
```typescript
interface School {
  id: number;
  user_id: number;
  phone: string;
  address: string;
  city: string;
  students_count: number;
  total_revenue: number;
  created_at: Date;
}
```

#### Course
```typescript
interface Course {
  id: number;
  title: string;
  description: string;
  permit_types: string[]; // ['A', 'B', 'C']
  thumbnail_url: string;
  is_published: boolean;
  order_index: number;
  created_at: Date;
}
```

#### Lesson
```typescript
interface Lesson {
  id: number;
  course_id: number;
  chapter_id: number;
  title: string;
  content: string; // HTML ou Markdown
  video_url: string | null;
  duration_minutes: number;
  order_index: number;
  created_at: Date;
}
```

### 10.3 Authentification JWT

#### Token Structure
```json
{
  "userId": 123,
  "email": "user@example.com",
  "role": "student",
  "iat": 1704412800,
  "exp": 1704499200
}
```

#### Middleware
```javascript
// backend/middleware/auth.js
const jwt = require('jsonwebtoken');

function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  
  if (!token) {
    return res.status(401).json({ error: 'No token provided' });
  }
  
  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({ error: 'Invalid token' });
    }
    req.user = user;
    next();
  });
}
```

#### Stockage Frontend
```dart
// lib/state/session/session_controller.dart
class SessionController with ChangeNotifier {
  String? _token;
  User? _user;
  
  Future<void> setSession(String token, User user) async {
    _token = token;
    _user = user;
    await _storage.write(key: 'auth_token', value: token);
    notifyListeners();
  }
  
  Future<void> clearSession() async {
    _token = null;
    _user = null;
    await _storage.delete(key: 'auth_token');
    notifyListeners();
  }
}
```

### 10.4 Variables d'Environnement

#### Backend (.env)
```env
# Database
DATABASE_URL=postgresql://user:password@host:5432/database

# JWT
JWT_SECRET=your-super-secret-key-here
JWT_EXPIRES_IN=7d

# Server
PORT=3000
NODE_ENV=production

# Railway (auto-provided)
RAILWAY_ENVIRONMENT=production
```

#### Frontend (environment.dart)
```dart
class Environment {
  static const String baseUrl = 
    'https://codinyplatforme-v2-production.up.railway.app';
  static const String apiVersion = 'v1';
  static const int timeoutSeconds = 30;
}
```

---

## 11. Sécurité

### 11.1 Authentification

#### Hachage des mots de passe
- Algorithme: **bcrypt**
- Salt rounds: **10**
- Vérification: `bcrypt.compare(password, hash)`

#### Tokens JWT
- Expiration: **7 jours**
- Renouvellement: Automatique lors de connexion
- Révocation: Suppression côté client

### 11.2 Protection des Endpoints

#### Middleware d'authentification
```javascript
// Protège toutes les routes privées
router.use('/students/me', authenticateToken);
router.use('/schools', authenticateToken);
router.use('/admin', authenticateToken, requireAdmin);
```

#### Vérification du rôle
```javascript
function requireRole(role) {
  return (req, res, next) => {
    if (req.user.role !== role) {
      return res.status(403).json({ 
        error: 'Insufficient permissions' 
      });
    }
    next();
  };
}
```

### 11.3 Validation des Entrées

#### Backend
```javascript
const { body, validationResult } = require('express-validator');

router.post('/register', [
  body('email').isEmail(),
  body('password').isLength({ min: 6 }),
  body('name').trim().notEmpty()
], (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }
  // ...
});
```

#### Frontend
```dart
// Validation côté client
String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Email requis';
  }
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(value)) {
    return 'Email invalide';
  }
  return null;
}
```

### 11.4 Protection CORS

```javascript
// backend/app.js
const cors = require('cors');

app.use(cors({
  origin: [
    'http://localhost:3000',
    'https://codiny-platform.tn'
  ],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
```

### 11.5 Rate Limiting

```javascript
const rateLimit = require('express-rate-limit');

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // 100 requests max
  message: 'Too many requests, please try again later'
});

app.use('/api/', limiter);
```

### 11.6 SQL Injection Prevention

```javascript
// ✅ BON: Parameterized queries
await pool.query(
  'SELECT * FROM users WHERE email = $1',
  [email]
);

// ❌ MAUVAIS: String concatenation
await pool.query(
  `SELECT * FROM users WHERE email = '${email}'`
);
```

---

## 12. Déploiement

### 12.1 Backend sur Railway

#### Configuration
```toml
# railway.toml
[build]
builder = "nixpacks"

[deploy]
startCommand = "node backend/server.js"
healthcheckPath = "/health"
healthcheckTimeout = 100
restartPolicyType = "on_failure"
restartPolicyMaxRetries = 10
```

#### Processus
1. Push vers GitHub (branche `main`)
2. Railway détecte le push
3. Build automatique du backend
4. Déploiement automatique
5. URL: `https://codinyplatforme-v2-production.up.railway.app`

#### Variables d'environnement Railway
```
DATABASE_URL (auto-généré par Railway Postgres)
JWT_SECRET (manuel)
NODE_ENV=production (manuel)
PORT=3000 (auto)
```

### 12.2 Base de Données

#### PostgreSQL sur Railway
- Version: PostgreSQL 14+
- Connexion: Via `DATABASE_URL` injectée automatiquement
- Backups: Automatiques quotidiens
- Migrations: Manuelles via scripts

#### Scripts de migration
```bash
# Ajouter la colonne permit_type
node backend/add-permit-type-column.js

# Appliquer les indexes
node backend/apply-indexes-migration.js

# Nettoyer les données
psql $DATABASE_URL -f backend/data-clean.sql
```

### 12.3 Application Mobile

#### Build Android APK
```bash
cd codiny_platform_app

# Nettoyer le build précédent
flutter clean

# Récupérer les dépendances
flutter pub get

# Build APK release
flutter build apk --release

# APK généré dans:
# build/app/outputs/flutter-apk/app-release.apk
```

#### Configuration Android
```gradle
// android/app/build.gradle
android {
    defaultConfig {
        applicationId "tn.codiny.platform"
        minSdkVersion 21
        targetSdkVersion 33
        versionCode 1
        versionName "1.0.0"
    }
    
    signingConfigs {
        release {
            storeFile file('key.jks')
            storePassword System.getenv("KEY_STORE_PASSWORD")
            keyAlias System.getenv("KEY_ALIAS")
            keyPassword System.getenv("KEY_PASSWORD")
        }
    }
}
```

### 12.4 CI/CD Pipeline

#### Git Workflow
```bash
# 1. Développement
git checkout -b feature/nouvelle-fonctionnalite
# ... modifications ...
git add .
git commit -m "feat: Ajout nouvelle fonctionnalité"

# 2. Push vers GitHub
git push origin feature/nouvelle-fonctionnalite

# 3. Merge vers main
git checkout main
git merge feature/nouvelle-fonctionnalite
git push origin main

# 4. Railway déploie automatiquement ✅
```

#### Scripts de déploiement
```powershell
# push-to-github.ps1
git add .
git commit -m $args[0]
git push origin main
Write-Host "✅ Pushed to GitHub - Railway will auto-deploy"
```

### 12.5 Monitoring

#### Health Check Endpoint
```javascript
// backend/app.js
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV
  });
});
```

#### Logs Railway
- Accès via Railway Dashboard
- Filtrage par niveau (info, warn, error)
- Recherche par mot-clé
- Export possible

#### Métriques
```javascript
// backend/verify-performance.js
const metrics = {
  databaseConnections: pool.totalCount,
  activeRequests: activeRequestsCount,
  averageResponseTime: calculateAvg(responseTimes),
  errorRate: (errors / totalRequests) * 100
};
```

---

## 13. Maintenance et Support

### 13.1 Logs et Debugging

#### Backend Logging
```javascript
// backend/utils/logger.js
const winston = require('winston');

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' })
  ]
});

// Usage
logger.info('User logged in', { userId: 123 });
logger.error('Database connection failed', { error: err.message });
```

#### Frontend Error Handling
```dart
// Capture des erreurs globales
void main() {
  FlutterError.onError = (details) {
    print('Flutter Error: ${details.exception}');
    // Envoyer à un service de monitoring (Sentry, etc.)
  };
  
  runApp(MyApp());
}
```

### 13.2 Requêtes Diagnostiques

```sql
-- backend/DIAGNOSTIC_QUERIES.sql

-- 1. Vérifier les étudiants sans accès
SELECT id, user_id, is_active, access_method, school_approval_status
FROM students
WHERE is_active = TRUE 
  AND school_id IS NOT NULL
  AND (access_method IS NULL OR access_method != 'school_linked');

-- 2. Vérifier les revenus manquants
SELECT s.id, s.user_id, s.school_id, u.name
FROM students s
JOIN users u ON s.user_id = u.id
WHERE s.school_id IS NOT NULL 
  AND s.is_active = TRUE
  AND NOT EXISTS (
    SELECT 1 FROM revenue_tracking rt 
    WHERE rt.student_id = s.id
  );

-- 3. Statistiques globales
SELECT 
  COUNT(*) as total_students,
  COUNT(CASE WHEN is_active THEN 1 END) as active,
  COUNT(CASE WHEN school_id IS NOT NULL THEN 1 END) as attached,
  SUM(CASE WHEN is_active THEN 1 ELSE 0 END) * 50 as total_revenue_expected
FROM students;
```

### 13.3 Scripts de Maintenance

#### Nettoyage des données
```javascript
// backend/data-clean.js
async function cleanupInvalidData() {
  // Fixer les noms null
  await pool.query(`
    UPDATE users 
    SET name = 'User ' || id 
    WHERE name IS NULL OR TRIM(name) = ''
  `);
  
  // Fixer les access_method manquants
  await pool.query(`
    UPDATE students 
    SET access_method = 'school_linked',
        school_approval_status = 'approved'
    WHERE school_id IS NOT NULL 
      AND is_active = TRUE
      AND access_method IS NULL
  `);
  
  console.log('✅ Data cleanup completed');
}
```

### 13.4 Backup et Restauration

#### Backup automatique
```bash
# Railway fait des backups automatiques
# Backup manuel:
pg_dump $DATABASE_URL > backup_$(date +%Y%m%d).sql
```

#### Restauration
```bash
# Restaurer depuis un backup
psql $DATABASE_URL < backup_20260105.sql
```

---

## 14. Roadmap et Évolutions Futures

### 14.1 Phase 1 - Complétée ✅
- [x] Système d'authentification JWT
- [x] Onboarding avec choix de permis
- [x] Gestion des étudiants par auto-écoles
- [x] Système de revenus
- [x] Cours et examens pour Permis B
- [x] Calendrier d'événements
- [x] Dashboard école avec statistiques
- [x] AccessGuard et contrôle d'accès

### 14.2 Phase 2 - À venir 🚧
- [ ] Contenu pour Permis A (Moto)
- [ ] Contenu pour Permis C (Camion)
- [ ] Système de notifications push
- [ ] Mode hors ligne (offline)
- [ ] Statistiques détaillées de progression
- [ ] Génération de certificats PDF
- [ ] Export des rapports financiers

### 14.3 Phase 3 - Futur 🔮
- [ ] Application iOS
- [ ] Mode sombre (dark mode)
- [ ] Multilingue (Arabe, Français, Anglais)
- [ ] Gamification (badges, points)
- [ ] Forum communautaire
- [ ] Intégration paiement en ligne
- [ ] API publique pour partenaires

---

## 15. Glossaire

| Terme | Définition |
|-------|------------|
| **AccessGuard** | Widget Flutter qui vérifie les permissions avant d'afficher du contenu |
| **Onboarding** | Processus d'intégration après inscription (choix du permis) |
| **Student ID** | Identifiant unique de l'étudiant (format: STU001, STU002, etc.) |
| **Permit Type** | Type de permis (A=Moto, B=Voiture, C=Camion) |
| **Activation** | Action de l'auto-école pour donner accès à un étudiant |
| **Revenue Tracking** | Table de suivi des revenus générés |
| **AccessGuard Timeout** | Délai maximum (10s) pour vérifier l'accès via API |
| **Railway** | Plateforme d'hébergement du backend avec auto-deploy |

---

## 16. Contacts et Support

### Développement
- **Repository**: [GitHub - CodinyPlatforme-v2](https://github.com/MedYahyaGarali-1/CodinyPlatforme-v2)
- **Backend URL**: https://codinyplatforme-v2-production.up.railway.app

### Documentation Technique
- **API Documentation**: `/api/docs` (à implémenter)
- **Fichiers de référence**:
  - `START_HERE.md` - Guide de démarrage
  - `DEPLOYMENT_GUIDE.md` - Guide de déploiement
  - `TESTING_GUIDE.md` - Guide de tests
  - `APK_BUILD_CHECKLIST.md` - Checklist build APK

---

## 📝 Notes Finales

Ce cahier des charges reflète l'état actuel de **Codiny Platform v2** en date du **5 janvier 2026**.

**Dernières modifications majeures**:
- ✅ Système de permis A/B/C implémenté
- ✅ Suppression du système d'approbation (remplacement par activation directe)
- ✅ Correction du suivi des revenus
- ✅ Correction de la navigation (problème d'écran noir)
- ✅ Amélioration de l'AccessGuard avec timeout

**État du projet**: 
- Backend: ✅ Déployé sur Railway
- Frontend: ✅ Code commité, APK à rebuilder
- Base de données: ✅ Migrée et nettoyée

**Prochaine étape**: Rebuild APK et tests end-to-end 🚀

---

*Document généré le 5 janvier 2026*
*Version: 1.0*

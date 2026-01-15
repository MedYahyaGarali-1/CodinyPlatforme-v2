# 📐 Architecture Complète - Codiny Platform

Ce document contient tous les diagrammes pour comprendre l'architecture complète de l'application **Codiny - Driving Exam Platform**.

---

## 🏗️ 1. Architecture Système Globale

```mermaid
graph TB
    subgraph "Client - Mobile App"
        A[Flutter App<br/>Android/iOS]
    end
    
    subgraph "Backend - Node.js"
        B[Express API Server<br/>Port 3000]
        C[JWT Authentication<br/>30 days token]
        D[Controllers Layer]
        E[Routes Layer]
        F[Middleware<br/>auth, access control]
    end
    
    subgraph "Database"
        G[(PostgreSQL<br/>Railway)]
    end
    
    subgraph "Hosting"
        H[Railway Platform<br/>Auto-deploy from GitHub]
    end
    
    A -->|HTTPS REST API| B
    B --> C
    B --> D
    D --> E
    B --> F
    D -->|SQL Queries| G
    H -.->|Deploy & Host| B
    H -.->|Host| G
    
    style A fill:#4CAF50
    style B fill:#2196F3
    style G fill:#FF9800
    style H fill:#9C27B0
```

**Explication** :
- **Flutter App** : Interface utilisateur mobile (Android/iOS)
- **Express API** : Backend Node.js qui gère toute la logique métier
- **JWT Token** : Authentification sécurisée (durée 30 jours)
- **PostgreSQL** : Base de données relationnelle
- **Railway** : Hébergement cloud avec déploiement automatique

---

## 🗄️ 2. Modèle de Base de Données (Schema ER)

```mermaid
erDiagram
    USERS ||--o| STUDENTS : "has"
    USERS ||--o| SCHOOLS : "has"
    USERS {
        uuid id PK
        string identifier "email/phone"
        string password_hash
        string name
        string role "student/school/admin"
        timestamp created_at
    }
    
    STUDENTS ||--o{ EXAM_SESSIONS : "takes"
    STUDENTS ||--o{ STUDENT_EVENTS : "has"
    STUDENTS }o--|| SCHOOLS : "attached_to"
    STUDENTS {
        uuid id PK
        uuid user_id FK
        string student_type "independent/attached"
        uuid school_id FK
        boolean onboarding_complete
        string access_method "independent/school_linked"
        boolean payment_verified
        string school_approval_status "pending/approved/rejected"
        string access_level "none/limited/full"
        boolean is_active
    }
    
    SCHOOLS ||--o{ STUDENTS : "manages"
    SCHOOLS {
        uuid id PK
        uuid user_id FK
        string name
        int total_students
        int total_earned
        boolean active
    }
    
    EXAM_SESSIONS ||--o{ EXAM_ANSWERS : "contains"
    EXAM_SESSIONS {
        uuid id PK
        uuid student_id FK
        timestamp started_at
        timestamp completed_at
        int total_questions "always 30"
        int correct_answers
        int wrong_answers
        decimal score "0-100"
        boolean passed ">=23 correct"
        int time_taken_seconds
    }
    
    EXAM_ANSWERS }o--|| EXAM_QUESTIONS : "references"
    EXAM_ANSWERS {
        uuid id PK
        uuid exam_session_id FK
        uuid question_id FK
        string student_answer "A/B/C"
        boolean is_correct
        timestamp answered_at
    }
    
    EXAM_QUESTIONS {
        uuid id PK
        int question_number "1-120"
        text question_text
        text image_url
        text option_a
        text option_b
        text option_c
        string correct_answer "A/B/C"
        string category
        boolean is_active
    }
    
    STUDENT_EVENTS {
        uuid id PK
        uuid student_id FK
        text title
        timestamp starts_at
        timestamp ends_at
        text location
        text notes
    }
    
    SCHOOL_STUDENT_REQUESTS {
        uuid id PK
        uuid student_id FK
        uuid school_id FK
        string status "pending/approved/rejected"
        timestamp requested_at
        text rejection_reason
    }
    
    REVENUE_TRACKING {
        uuid id PK
        uuid student_id FK
        uuid school_id FK
        decimal school_revenue "20 TND"
        decimal platform_revenue "30 TND"
        decimal total_amount "50 TND"
        timestamp created_at
    }
```

**Tables principales** :
- **users** : Tous les comptes (étudiants, écoles, admins)
- **students** : Profils étudiants avec accès et abonnements
- **schools** : Profils auto-écoles
- **exam_questions** : Banque de 120 questions
- **exam_sessions** : Chaque tentative d'examen (30 questions)
- **exam_answers** : Réponses détaillées question par question
- **student_events** : Calendrier/événements des étudiants

---

## 🔄 3. Flux d'Authentification (Sequence Diagram)

```mermaid
sequenceDiagram
    participant U as User (App)
    participant A as API Server
    participant DB as PostgreSQL
    participant JWT as JWT Service
    
    U->>A: POST /auth/login {identifier, password}
    A->>DB: SELECT * FROM users WHERE identifier=?
    DB-->>A: User data + password_hash
    A->>A: bcrypt.compare(password, hash)
    alt Password correct
        A->>JWT: jwt.sign({id, role}, secret, {expiresIn: '30d'})
        JWT-->>A: Token (valid 30 days)
        A-->>U: {token, user: {id, name, role}}
        U->>U: Store token in SecureStorage
    else Password incorrect
        A-->>U: Error: Invalid credentials
    end
    
    Note over U,A: Subsequent requests
    U->>A: GET /exams/questions<br/>Authorization: Bearer TOKEN
    A->>JWT: jwt.verify(token, secret)
    JWT-->>A: Decoded: {id, role}
    A->>DB: Check access permissions
    DB-->>A: Access granted
    A-->>U: {questions: [...]}
```

**Durée du token** : **30 jours** (au lieu de 1 heure avant)

---

## 📱 4. Flux de Passage d'Examen

```mermaid
sequenceDiagram
    participant S as Student (App)
    participant API as Backend API
    participant DB as Database
    
    S->>API: GET /exams/questions<br/>(requires full access)
    API->>DB: SELECT 30 random questions<br/>WHERE is_active=true
    DB-->>API: 30 questions
    API-->>S: {questions: [...], time_limit: 45min}
    
    S->>API: POST /exams/start
    API->>DB: INSERT INTO exam_sessions<br/>(student_id, total_questions=30)
    DB-->>API: {session_id, started_at}
    API-->>S: {session: {id, started_at}}
    
    Note over S: Student answers 30 questions<br/>Max 45 minutes
    
    S->>API: POST /exams/submit<br/>{session_id, answers[], time_taken}
    API->>DB: BEGIN TRANSACTION
    
    loop For each answer
        API->>DB: SELECT correct_answer<br/>FROM exam_questions
        DB-->>API: correct_answer
        API->>API: Check if student_answer == correct_answer
        API->>DB: INSERT INTO exam_answers<br/>(session_id, question_id, student_answer, is_correct)
    end
    
    API->>API: Calculate score<br/>passed = (correct >= 23)
    API->>DB: UPDATE exam_sessions<br/>SET completed_at, score, passed, correct_answers, wrong_answers
    API->>DB: COMMIT
    DB-->>API: Success
    API-->>S: {score, passed, correct: 25, wrong: 5}
    
    S->>S: Show result screen<br/>✅ Passed / ❌ Failed
```

**Règle de passage** : **23/30 correct (76.67%)** minimum

---

## 🏫 5. Système École-Étudiant (Use Case Diagram)

```mermaid
graph TB
    subgraph "Étudiants"
        E1[Étudiant Indépendant]
        E2[Étudiant École]
    end
    
    subgraph "Auto-École"
        S[School Account]
    end
    
    subgraph "Fonctionnalités"
        UC1[S'inscrire / Login]
        UC2[Onboarding<br/>Choisir : Indépendant ou École]
        UC3[Payer Abonnement<br/>50 TND]
        UC4[Demander Rattachement<br/>à une École]
        UC5[Approuver/Rejeter<br/>Étudiants]
        UC6[Passer Examens<br/>30 questions]
        UC7[Voir Historique Examens]
        UC8[Gérer Calendrier<br/>Événements]
        UC9[Suivre Progrès<br/>des Étudiants]
        UC10[Voir Réponses Détaillées<br/>par Question]
    end
    
    E1 -->|Utilise| UC1
    E2 -->|Utilise| UC1
    E1 --> UC2
    E2 --> UC2
    E1 -->|Paiement direct| UC3
    E2 -->|Demande| UC4
    S -->|Gère| UC5
    E1 --> UC6
    E2 -->|Si approuvé| UC6
    E1 --> UC7
    E2 --> UC7
    E1 --> UC8
    E2 --> UC8
    S --> UC9
    S --> UC10
    
    style E1 fill:#4CAF50
    style E2 fill:#2196F3
    style S fill:#FF9800
```

**Deux types d'accès** :
1. **Étudiant Indépendant** : Paie 50 TND directement → accès immédiat
2. **Étudiant École** : Demande rattachement → école approuve → accès gratuit (école paie 50 TND : 20 TND école + 30 TND plateforme)

---

## 🔐 6. Contrôle d'Accès (Access Control Flow)

```mermaid
graph TD
    A[User Login] --> B{Role?}
    B -->|student| C[StudentController]
    B -->|school| D[SchoolController]
    B -->|admin| E[AdminController]
    
    C --> F{Onboarding<br/>Complete?}
    F -->|No| G[Redirect to Onboarding]
    F -->|Yes| H{Access Method?}
    
    H -->|independent| I{Payment<br/>Verified?}
    I -->|Yes| J[access_level = FULL]
    I -->|No| K[access_level = LIMITED]
    
    H -->|school_linked| L{School<br/>Approval?}
    L -->|approved| J
    L -->|pending| M[access_level = LIMITED<br/>Show: Waiting for school approval]
    L -->|rejected| N[access_level = LIMITED<br/>Show: School rejected request]
    
    J --> O[✅ Access Exams<br/>✅ Access Courses<br/>✅ Full Features]
    K --> P[❌ Cannot take exams<br/>❌ Limited dashboard<br/>⚠️ Prompt to subscribe]
    M --> P
    N --> P
    
    D --> Q[✅ Manage Students<br/>✅ Track Progress<br/>✅ View Exam Details]
    E --> R[✅ All Features<br/>✅ Statistics<br/>✅ Revenue Tracking]
    
    style J fill:#4CAF50
    style P fill:#FF5722
    style O fill:#4CAF50
```

**Niveaux d'accès** :
- **FULL** : Peut passer les examens et accéder à tout
- **LIMITED** : Dashboard only, doit payer/être approuvé
- **NONE** : Doit compléter onboarding

---

## 🌐 7. API Routes (Backend Endpoints)

```mermaid
graph LR
    subgraph "Public Routes"
        A1[POST /auth/register]
        A2[POST /auth/login]
    end
    
    subgraph "Student Routes 🔒"
        B1[GET /students/me]
        B2[PUT /students/me]
        B3[GET /students/access-status]
        B4[POST /students/complete-onboarding]
        B5[GET /students/events]
        B6[POST /students/events]
    end
    
    subgraph "Exam Routes 🔒"
        C1[GET /exams/questions<br/>Requires FULL access]
        C2[POST /exams/start<br/>Requires FULL access]
        C3[POST /exams/submit<br/>Requires FULL access]
        C4[GET /exams/history]
        C5[GET /exams/:examId]
    end
    
    subgraph "School Routes 🔒"
        D1[GET /schools/students]
        D2[POST /schools/students/attach]
        D3[POST /schools/students/detach]
        D4[GET /schools/students/:id/exams]
        D5[GET /schools/students/:id/exams/:examId/answers]
    end
    
    subgraph "Subscription Routes 🔒"
        E1[POST /subscriptions/verify-payment]
        E2[POST /subscriptions/request-school]
    end
    
    subgraph "Admin Routes 🔒"
        F1[GET /admin/exam-stats]
        F2[GET /admin/revenue]
    end
    
    style A1 fill:#4CAF50
    style A2 fill:#4CAF50
    style C1 fill:#FF9800
    style C2 fill:#FF9800
    style C3 fill:#FF9800
```

**🔒** = Requires JWT Token Authentication  
**Requires FULL access** = Needs payment verified OR school approved

---

## 📲 8. Frontend Architecture (Flutter App)

```mermaid
graph TD
    subgraph "Presentation Layer"
        A[Screens<br/>UI Components]
    end
    
    subgraph "State Management"
        B[Provider<br/>SessionController<br/>ThemeController]
    end
    
    subgraph "Business Logic"
        C[Repositories<br/>- ExamRepository<br/>- SchoolRepository<br/>- CourseRepository]
    end
    
    subgraph "Data Layer"
        D[API Service<br/>HTTP Client]
        E[Models<br/>- User<br/>- Student<br/>- ExamQuestion<br/>- ExamResult]
    end
    
    subgraph "Core"
        F[Environment Config<br/>BaseURL, Keys]
        G[Routes<br/>Navigation]
        H[Theme<br/>Light/Dark]
    end
    
    A --> B
    B --> C
    C --> D
    D --> E
    A --> G
    B --> H
    C --> F
    
    D -->|REST API| I[Backend Server]
    
    style A fill:#4CAF50
    style B fill:#2196F3
    style C fill:#FF9800
    style D fill:#9C27B0
```

**Structure du code Flutter** :
```
lib/
├── app/              # App entry, theme, router
├── core/             # Config, constants
├── data/
│   ├── models/       # Data classes
│   ├── repositories/ # Business logic
│   └── services/     # API calls
├── features/         # Screens par fonctionnalité
│   ├── auth/
│   ├── dashboard/
│   ├── exams/
│   └── onboarding/
├── shared/           # Widgets réutilisables
│   ├── layout/
│   ├── ui/
│   └── widgets/
└── state/            # State management (Provider)
```

---

## 🎯 9. Flux Complet : Étudiant Indépendant

```mermaid
stateDiagram-v2
    [*] --> Register: User creates account
    Register --> Login: Account created
    Login --> CheckOnboarding: Authenticated
    
    CheckOnboarding --> Onboarding: Not complete
    Onboarding --> ChooseAccessMethod: Start onboarding
    
    ChooseAccessMethod --> Independent: Choose independent
    Independent --> PaymentScreen: Selected
    PaymentScreen --> VerifyPayment: Paid 50 TND
    VerifyPayment --> FullAccess: Payment verified
    
    FullAccess --> Dashboard: Access granted
    Dashboard --> TakeExam: Navigate to exams
    Dashboard --> ViewHistory: View past exams
    Dashboard --> ManageCalendar: Manage events
    
    TakeExam --> ExamScreen: Start new exam
    ExamScreen --> SubmitExam: Answer 30 questions
    SubmitExam --> ViewResult: Show score
    ViewResult --> Dashboard: Return
    
    ViewHistory --> ExamDetails: Click exam
    ExamDetails --> ViewAnswers: See detailed answers
    ViewAnswers --> Dashboard: Return
```

---

## 🏫 10. Flux Complet : Étudiant École

```mermaid
stateDiagram-v2
    [*] --> Register
    Register --> Login
    Login --> Onboarding
    
    Onboarding --> ChooseAccessMethod
    ChooseAccessMethod --> SchoolLinked: Choose school
    SchoolLinked --> EnterStudentID: Provide ID
    EnterStudentID --> RequestSent: Submit request
    RequestSent --> WaitingApproval: Status: Pending
    
    WaitingApproval --> CheckStatus: School reviews
    CheckStatus --> Approved: School approves
    CheckStatus --> Rejected: School rejects
    
    Approved --> FullAccess: Access granted
    Rejected --> LimitedAccess: Dashboard only
    LimitedAccess --> RequestSent: Request again
    
    FullAccess --> Dashboard
    Dashboard --> TakeExam
    Dashboard --> ViewHistory
```

---

## 📊 11. Diagramme de Classes Simplifié

```mermaid
classDiagram
    class User {
        +String id
        +String identifier
        +String name
        +String role
        +String passwordHash
        +login()
        +register()
    }
    
    class Student {
        +String id
        +String userId
        +String studentType
        +String accessMethod
        +Boolean paymentVerified
        +String schoolApprovalStatus
        +String accessLevel
        +Boolean isActive
        +completeOnboarding()
        +verifyPayment()
        +requestSchoolLink()
    }
    
    class School {
        +String id
        +String userId
        +String name
        +Int totalStudents
        +Int totalEarned
        +approveStudent()
        +rejectStudent()
        +getStudents()
        +trackProgress()
    }
    
    class ExamQuestion {
        +String id
        +Int questionNumber
        +String questionText
        +String imageUrl
        +String optionA
        +String optionB
        +String optionC
        +String correctAnswer
        +String category
    }
    
    class ExamSession {
        +String id
        +String studentId
        +DateTime startedAt
        +DateTime completedAt
        +Int totalQuestions
        +Int correctAnswers
        +Int wrongAnswers
        +Double score
        +Boolean passed
        +start()
        +submit()
        +calculateScore()
    }
    
    class ExamAnswer {
        +String id
        +String examSessionId
        +String questionId
        +String studentAnswer
        +Boolean isCorrect
        +DateTime answeredAt
    }
    
    User "1" -- "0..1" Student : has
    User "1" -- "0..1" School : has
    Student "1" -- "*" ExamSession : takes
    School "1" -- "*" Student : manages
    ExamSession "1" -- "*" ExamAnswer : contains
    ExamAnswer "*" -- "1" ExamQuestion : references
```

---

## 🔄 12. Gestion des Erreurs et Token Expiration

```mermaid
sequenceDiagram
    participant App as Flutter App
    participant API as ApiService
    participant Backend as Express Server
    participant Nav as NavigatorKey
    
    App->>API: GET /exams/questions<br/>Authorization: Bearer EXPIRED_TOKEN
    API->>Backend: Request with token
    Backend->>Backend: jwt.verify(token) → Token expired!
    Backend-->>API: 401 Unauthorized
    
    API->>API: _handleAuthError(401)
    API->>Nav: navigatorKey.currentContext
    Nav-->>API: BuildContext
    API->>Nav: pushNamedAndRemoveUntil('/login')
    Nav->>App: Navigate to Login Screen
    
    App->>App: Show: "Session expired, please login again"
    
    Note over App,Backend: User logs in again
    App->>Backend: POST /auth/login
    Backend-->>App: New token (valid 30 days)
    App->>App: Store token in SecureStorage
    App->>Backend: Retry request with new token
    Backend-->>App: Success ✅
```

**Fix implémenté** : Au lieu de lancer une exception, l'app redirige automatiquement vers login.

---

## 📈 13. Statistiques et Reporting (School Dashboard)

```mermaid
graph TD
    A[School Dashboard] --> B[View All Students]
    A --> C[Revenue Statistics]
    A --> D[Exam Statistics]
    
    B --> E[Click Student]
    E --> F[Student Progress Detail]
    
    F --> G[Exam History<br/>List of all exams]
    F --> H[Overall Stats<br/>Pass rate, avg score]
    
    G --> I[Click Exam]
    I --> J[Detailed Answers Screen]
    
    J --> K[Show all 30 questions]
    J --> L[Student's answer]
    J --> M[Correct answer]
    J --> N[Visual indicators<br/>✅ Green / ❌ Red]
    
    C --> O[Total Earned: 20 TND/student]
    C --> P[Platform Share: 30 TND/student]
    
    D --> Q[Total Students with Exams]
    D --> R[Total Exams Taken]
    D --> S[Pass Rate %]
    D --> T[Average Score]
    
    style J fill:#4CAF50
    style K fill:#2196F3
    style L fill:#FF9800
    style M fill:#FF5722
```

---

## 🛠️ 14. Technologies et Stack

```mermaid
graph TB
    subgraph "Frontend"
        A1[Flutter SDK]
        A2[Dart Language]
        A3[Provider<br/>State Management]
        A4[HTTP Package<br/>API Calls]
        A5[Secure Storage<br/>Token storage]
    end
    
    subgraph "Backend"
        B1[Node.js]
        B2[Express.js]
        B3[JWT<br/>jsonwebtoken]
        B4[Bcrypt<br/>Password hashing]
        B5[pg<br/>PostgreSQL driver]
    end
    
    subgraph "Database"
        C1[PostgreSQL 15+]
        C2[UUID Primary Keys]
        C3[Indexes for Performance]
    end
    
    subgraph "Deployment"
        D1[Railway Platform]
        D2[GitHub Auto-Deploy]
        D3[Environment Variables]
    end
    
    subgraph "Tools"
        E1[VS Code]
        E2[Android Studio]
        E3[Postman<br/>API Testing]
        E4[Git / GitHub]
    end
    
    A1 --> A3
    A1 --> A4
    A1 --> A5
    
    B1 --> B2
    B2 --> B3
    B2 --> B4
    B2 --> B5
    
    B5 --> C1
    
    D1 --> D2
    D2 --> E4
    
    style A1 fill:#4CAF50
    style B1 fill:#2196F3
    style C1 fill:#FF9800
    style D1 fill:#9C27B0
```

---

## 📝 15. Résumé des Fonctionnalités Principales

### Pour les Étudiants :
- ✅ Inscription / Connexion
- ✅ Onboarding (choix accès indépendant ou école)
- ✅ Passer des examens (30 questions, 45 minutes)
- ✅ Voir historique des examens avec scores
- ✅ Calendrier d'événements
- ✅ Dashboard personnalisé

### Pour les Auto-Écoles :
- ✅ Gérer la liste des étudiants
- ✅ Approuver/Rejeter les demandes
- ✅ Voir le progrès détaillé de chaque étudiant
- ✅ Voir tous les examens d'un étudiant
- ✅ Voir les réponses détaillées question par question
- ✅ Statistiques de revenus
- ✅ Dashboard de statistiques

### Pour les Admins :
- ✅ Voir statistiques globales
- ✅ Gérer les revenus
- ✅ Voir statistiques des examens

---

## 🔒 16. Sécurité Implémentée

- ✅ **JWT Tokens** : 30 jours de validité
- ✅ **Bcrypt** : Hash des mots de passe
- ✅ **Middleware d'authentification** : Toutes les routes protégées
- ✅ **Contrôle d'accès** : Vérification des permissions (FULL/LIMITED)
- ✅ **Validation des entrées** : Côté backend
- ✅ **CORS configuré** : Protection contre les requêtes non autorisées
- ✅ **Token expiration handling** : Redirection automatique vers login
- ✅ **School ownership verification** : Une école ne peut voir que ses étudiants

---

## 📦 17. Déploiement et CI/CD

```mermaid
graph LR
    A[Code Change] --> B[Git Commit]
    B --> C[Git Push to GitHub]
    C --> D[Railway detects change]
    D --> E[Auto Build]
    E --> F[Run Tests]
    F --> G{Tests Pass?}
    G -->|Yes| H[Deploy to Production]
    G -->|No| I[Rollback / Notify]
    H --> J[Live on Railway]
    
    K[Mobile App Code] --> L[Flutter Build APK/AAB]
    L --> M[Sign with Keystore]
    M --> N[Upload to Play Console]
    N --> O[Review by Google]
    O --> P[Published on Play Store]
    
    style H fill:#4CAF50
    style P fill:#4CAF50
    style I fill:#FF5722
```

---

## 🎨 18. UI/UX Flow (Screens)

### Écrans principaux :
1. **Splash Screen** → **Login** → **Register**
2. **Onboarding** (3 étapes : Bienvenue → Choix accès → Configuration)
3. **Dashboard Étudiant** (Stats, Quick actions, Calendar)
4. **Exams Screen** (Start new exam, History)
5. **Exam Taking Screen** (30 questions, timer, navigation)
6. **Exam Result Screen** (Score, Pass/Fail, Review)
7. **Exam History Screen** (List of all exams)
8. **Exam Answers Detail** (Question-by-question review)
9. **Calendar Screen** (Events management)
10. **Dashboard École** (Students list, Stats)
11. **Student Progress Detail** (Exam history, Stats)
12. **Payment Screen** (Independent students)

---

## 🚀 19. Performance Optimizations

- ✅ **Database Indexes** : Sur les colonnes fréquemment requêtées
- ✅ **Pagination** : Pour les listes longues (exams history)
- ✅ **Lazy Loading** : Chargement des images à la demande
- ✅ **Caching** : Provider state management garde l'état
- ✅ **Connection Pooling** : PostgreSQL pool pour réutiliser les connexions
- ✅ **JWT Token Long Duration** : Réduit les re-authentifications

---

## 📖 Guide d'Utilisation des Diagrammes

### Visualiser les diagrammes Mermaid :

#### Option 1 : VS Code Extension
1. Installe l'extension **"Markdown Preview Mermaid Support"**
2. Ouvre ce fichier dans VS Code
3. Ctrl+Shift+V pour voir le preview

#### Option 2 : Mermaid Live Editor
1. Va sur https://mermaid.live
2. Copie/colle le code Mermaid
3. Télécharge en PNG/SVG

#### Option 3 : GitHub
1. Pousse ce fichier sur GitHub
2. GitHub affiche automatiquement les diagrammes Mermaid

---

## 📞 Contact & Support

Pour toute question sur l'architecture :
- Consulte le code source dans les dossiers `backend/` et `codiny_platform_app/`
- Regarde les fichiers de documentation dans le root du projet
- Check les commentaires dans le code

---

**Version** : 1.0  
**Date** : 2026-01-13  
**Auteur** : Documentation générée pour Codiny Platform

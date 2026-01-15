# Institut Supérieur des Études Technologiques de Nabeul (ISET Nabeul)
## Département Technologie de l’Informatique

# **Rapport de stage de perfectionnement**

## **Conception et développement d’une application mobile de préparation à l’examen de conduite :**
## **Codiny – Driving Exam**

**Réalisé par :** Mohamed Yahya GARALI  
**Spécialité :** SEM  
**Lieu de stage :** ISET Nabeul – Département TI  
**Période :** du 05 janvier au 31 janvier  
**Encadrant (ISET) :** Chokri Bousetta  
**Encadrant (Département) :** Chokri Bousetta – Chef de département  

---

# Remerciements

Je tiens à remercier M. **Chokri Bousetta** pour son encadrement, ses conseils et son suivi tout au long de ce stage de perfectionnement. Je remercie également l’équipe du département TI pour sa disponibilité et l’environnement de travail favorable ayant permis la réalisation de ce projet.

---

# Sommaire

1. Introduction générale
2. Chapitre 1 : Contexte du travail et cahier des charges
3. Chapitre 2 : Étude conceptuelle
4. Chapitre 3 : Réalisation
5. Conclusion générale
6. Bibliographie et netographie
7. Annexes

---

# Introduction générale

Ce rapport présente le travail réalisé durant le **stage de perfectionnement** au sein de l’**ISET Nabeul – Département TI**, portant sur la conception et le développement d’une application mobile éducative : **Codiny – Driving Exam**.

**Objectif :** concevoir une plateforme numérique d’apprentissage et d’entraînement au code de la route et aux examens de conduite, permettant à l’apprenant de **réviser**, **s’évaluer** et **suivre sa progression** via une application mobile.

Le rapport est structuré en trois chapitres : (1) contexte et cahier des charges, (2) étude conceptuelle, (3) réalisation et validation.

---

# Chapitre 1 : Contexte du travail et cahier des charges

## 1.1 Contexte

La préparation à l’examen de conduite nécessite des supports variés (cours, panneaux, séries de questions, examens blancs). Une application mobile rend ces ressources accessibles à tout moment et facilite le suivi des résultats.

## 1.2 Problématique

Les apprenants manquent souvent d’un outil unique qui centralise :
- des contenus pédagogiques structurés,
- des examens blancs et corrections,
- un suivi clair de progression.

**Problématique :** proposer une solution mobile simple, fiable et rapide qui centralise l’apprentissage et l’évaluation pour la préparation à l’examen de conduite.

## 1.3 Objectifs

- Mettre à disposition des cours et supports visuels.
- Proposer des questions d’entraînement et examens blancs.
- Afficher résultats et corrections.
- Suivre la progression de l’utilisateur.

## 1.4 Cahier des charges (synthèse)

### 1.4.1 Fonctionnalités

- Authentification (inscription / connexion).
- Banque de questions + examens blancs.
- Résultats et correction.
- Cours et panneaux de signalisation.
- Suivi de progression.
- Politique de confidentialité accessible.

### 1.4.2 Exigences non fonctionnelles

- Ergonomie mobile (interface simple).
- Performance (temps de chargement réduit).
- Sécurité (session, gestion des erreurs).

> **Figure 1 (à insérer)** : Schéma global de l’application / architecture (mobile + API + BD).

---

# Chapitre 2 : Étude conceptuelle

## 2.1 Vision globale et architecture

L’application est conçue selon une architecture en couches :
- **Frontend mobile** (Flutter) : interface et logique de présentation.
- **Backend** (API REST) : authentification et accès aux données.
- **Base de données** : stockage utilisateurs, questions, cours, résultats.

## 2.2 Acteurs

- **Apprenant** : s’entraîne, passe des examens, consulte cours/panneaux et suit sa progression.
- **Administrateur** (si activé) : gère contenus (questions/cours).

## 2.3 Cas d’utilisation (résumé)

- S’inscrire / se connecter
- Consulter cours et panneaux
- Passer un examen blanc
- Consulter résultats et correction
- Visualiser la progression

> **Figure 2 (à insérer)** : Diagramme de cas d’utilisation (acteurs + actions).

## 2.4 Modèle de données (résumé)

Entités principales :
- **User** (id, nom, rôle)
- **Question** (énoncé, choix, réponse, explication, image)
- **ExamSession** (date, score, réponses)
- **Course/Lesson** (titre, contenu)

> **Figure 3 (à insérer)** : Modèle conceptuel / diagramme ER simplifié.

---

# Chapitre 3 : Réalisation

## 3.1 Outils et technologies

- Flutter/Dart (mobile)
- API REST (backend)
- Base de données
- Git/GitHub (versioning)

## 3.2 Fonctionnalités réalisées

### 3.2.1 Authentification

Écrans d’inscription et connexion, avec persistance de session (rester connecté).

> **Figure 4 (à insérer)** : Capture écran Login.

### 3.2.2 Entraînement / examens blancs

Affichage des questions, sélection des réponses et calcul de score. Après l’examen : résultat + correction.

> **Figure 5 (à insérer)** : Capture écran Examen + Résultat.

### 3.2.3 Cours et panneaux

Accès à des cours structurés et à des images de panneaux, pour renforcer l’apprentissage.

### 3.2.4 Suivi de progression

Historique des résultats et indicateurs simples permettant d’identifier les points à améliorer.

## 3.3 Conformité et confidentialité

Pour respecter la transparence envers l’utilisateur :
- Ajout d’un **disclaimer** au premier lancement indiquant que l’app est **privée**, **indépendante** et **non affiliée au gouvernement**.
- Ajout d’un bouton **Politique de confidentialité** ouvrant l’URL dédiée.

> **Figure 6 (à insérer)** : Capture du disclaimer (celle que vous avez déjà).

## 3.4 Tests (synthèse)

- Tests fonctionnels (connexion, navigation, examens).
- Tests de relance (fermer/relancer l’app).
- Vérification de la stabilité et gestion d’erreurs.

---

# Conclusion générale

Ce stage de perfectionnement a permis de concevoir et développer **Codiny – Driving Exam**, une application mobile éducative visant à centraliser cours, entraînement, examens blancs et suivi de progression.

**Perspectives :** enrichissement de la banque de questions, mode hors-ligne partiel, statistiques plus détaillées et optimisation des performances.

---

# Bibliographie et Netographie

## Netographie

- Flutter documentation : https://docs.flutter.dev (Consultée le 11/01/2026)
- Dart documentation : https://dart.dev (Consultée le 11/01/2026)
- Node.js documentation : https://nodejs.org (Consultée le 11/01/2026)

---

# Annexes

**Annexe A :** Captures d’écran supplémentaires (cours, panneaux, dashboards).  
**Annexe B :** Exemples de questions (2–3 pages max).  
**Annexe C :** Politique de confidentialité (URL + date de consultation).  

---

## Note (mise en page pour 22 pages au total)

Pour obtenir **22 pages au total** dans Word :
- Utiliser **Times New Roman 12**, interligne **1.5**, texte **justifié**.
- Insérer **6 figures** (Figure 1 à 6) comme indiqué.
- Limiter les annexes à **2–3 pages maximum**.
- Garder l’introduction à ~1 page et chaque chapitre à ~4–5 pages.

---

# Rapport de Stage de Perfectionnement

## Introduction

Ce rapport présente le travail réalisé durant le **stage de perfectionnement** au sein de l’**ISET Nabeul – Département TI**, portant sur la conception et le développement d’une application mobile éducative : **Codiny – Driving Exam**.

**Objectif :** concevoir une plateforme numérique d’apprentissage et d’entraînement au code de la route et aux examens de conduite, permettant à l’apprenant de **réviser**, **s’évaluer** et **suivre sa progression** via une application mobile.

Le rapport est structuré en trois chapitres : (1) contexte et cahier des charges, (2) étude conceptuelle, (3) réalisation et validation.

## Présentation de l'entreprise

L’**Institut Supérieur des Études Technologiques de Nabeul (ISET Nabeul)** est un établissement d’enseignement supérieur tunisien, relevant du ministère de l’Enseignement supérieur et de la Recherche scientifique. Il a pour mission de former des cadres supérieurs dans le domaine des technologies de l’information et de la communication, en adéquation avec les besoins du marché du travail.

**Diagramme 1 : Organigramme de l’entreprise**
*Insérer ici un organigramme représentant la structure hiérarchique de l’entreprise.*

## Présentation du projet

Le projet **Codiny – Driving Exam** s’inscrit dans le cadre de la formation pratique des étudiants en technologie de l’information. Il vise à développer une application mobile innovante, permettant une préparation optimale à l’examen de conduite, à travers des cours interactifs, des séries de questions d’entraînement et un suivi personnalisé de la progression.

**Diagramme 2 : Diagramme de contexte du projet**
*Insérer ici un diagramme de contexte illustrant les interactions entre le système développé et les acteurs externes (utilisateurs, administrateurs, etc.).*

## Étude conceptuelle

L’étude conceptuelle a pour objectif de définir les grandes lignes du projet, en termes de fonctionnalités, d’architecture et d’interactions entre les différents acteurs.

**Diagramme 3 : Diagramme de cas d’utilisation**
*Insérer ici un diagramme de cas d’utilisation montrant les principales fonctionnalités du système et les interactions avec les utilisateurs.*

**Diagramme 4 : Diagramme de classes**
*Insérer ici un diagramme de classes représentant la structure des principales entités logicielles du projet.*

## Réalisation

La phase de réalisation a consisté à développer l’application mobile **Codiny – Driving Exam**, en utilisant les technologies Flutter pour le front-end et une API REST pour le back-end. La base de données a été conçue pour stocker l’ensemble des données relatives aux utilisateurs, questions, cours et résultats.

**Diagramme 5 : Schéma d’architecture technique**
*Insérer ici un schéma illustrant l’architecture technique de la solution (front-end, back-end, base de données, etc.).*

**Diagramme 6 : Diagramme de séquence (exemple d’un scénario clé)**
*Insérer ici un diagramme de séquence détaillant le déroulement d’un scénario fonctionnel important (ex : authentification, passage d’un examen, etc.).*

## Conclusion

Ce stage de perfectionnement a permis de concevoir et développer **Codiny – Driving Exam**, une application mobile éducative visant à centraliser cours, entraînement, examens blancs et suivi de progression.

**Perspectives :** enrichissement de la banque de questions, mode hors-ligne partiel, statistiques plus détaillées et optimisation des performances.

## Annexes

**Annexe A :** Captures d’écran supplémentaires (cours, panneaux, dashboards).  
**Annexe B :** Exemples de questions (2–3 pages max).  
**Annexe C :** Politique de confidentialité (URL + date de consultation).  

---

## Note (mise en page pour 22 pages au total)

Pour obtenir **22 pages au total** dans Word :
- Utiliser **Times New Roman 12**, interligne **1.5**, texte **justifié**.
- Insérer **6 figures** (Figure 1 à 6) comme indiqué.
- Limiter les annexes à **2–3 pages maximum**.
- Garder l’introduction à ~1 page et chaque chapitre à ~4–5 pages.

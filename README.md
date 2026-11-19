# PsyTech Pro — Interface candidat (Flutter)

Interface connectée au backend `psytech-backend` (Express + MySQL), module `/api/candidat`.

## 1. Lancer le backend
Voir le README du backend : `npm run seed:admin`, `npm run seed:demo:reset` (affiche des clés `PSY-XXXXXX`), `npm run dev` → http://localhost:3000

## 2. Lancer l'interface
```bash
flutter create .        # une seule fois : génère web/android/ios
flutter pub get
flutter run -d chrome --web-port=5000
```
`--web-port=5000` correspond à `CANDIDAT_URL` du `.env` du backend (lien dans l'email d'invitation).

URL de l'API (par défaut `http://localhost:3000/api`) :
- Émulateur Android : `--dart-define=API_BASE_URL=http://10.0.2.2:3000/api`
- Téléphone réel : `--dart-define=API_BASE_URL=http://<IP_DU_PC>:3000/api`

## Correspondance écrans ↔ API
| Écran | Appel |
|---|---|
| Connexion | `POST /candidat/auth/login {cle}` puis `GET /candidat/test` ; le `statut` renvoyé choisit l'écran : `invite` → intro, `en_cours` → reprise du test, `termine` → résultat |
| Test | `POST /candidat/test/demarrer` (chrono serveur, reprise possible), `PUT /candidat/test/reponses/:id {choix}` à chaque clic |
| Soumission | `POST /candidat/test/soumettre` (aussi automatique à la fin du temps) |
| Résultat | score affiché seulement si l'entreprise l'autorise (`scoreVisible`) |

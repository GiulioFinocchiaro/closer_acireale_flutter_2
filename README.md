# Closer Acireale Flutter

Sistema di Gestione Closer Acireale - Applicazione Flutter Multi-piattaforma

## 📋 Descrizione

Questa è una moderna applicazione Flutter che converte il sistema web originale HTML/CSS/JS di Closer Acireale in un'applicazione multi-piattaforma. L'applicazione mantiene tutte le funzionalità originali del backend API esistente e aggiunge un'interfaccia utente moderna e responsiva.

## 🚀 Caratteristiche

### Piattaforme Supportate
- **Web** - Applicazione web progressive (PWA)
- **Mobile** - Android e iOS
- **Desktop** - Linux, Windows, macOS

### Funzionalità Principali
- 🔐 Sistema di autenticazione con email/password
- 👥 Gestione utenti completa (CRUD)
- 📊 Dashboard interattiva con statistiche
- 🏫 Dashboard specializzata per la gestione scuole
- 🎯 Gestione campagne elettorali
- 👨‍🎓 Gestione candidati
- 📈 Visualizzazione grafici e analytics
- 🛡️ Sistema di ruoli e permessi
- 📱 Design completamente responsivo
- 🌙 Supporto tema scuro (futuro)

### Tecnologie Utilizzate
- **Flutter 3.24.5** - Framework UI multi-piattaforma
- **Material Design 3** - Design system moderno
- **Provider** - State management
- **Go Router** - Navigazione avanzata
- **Dio** - Client HTTP per API
- **SharedPreferences** - Storage locale
- **ScreenUtil** - Responsive design

## 🏗️ Architettura

L'applicazione segue una architettura clean e modulare:

```
lib/
├── core/                    # Core functionality
│   ├── constants/           # App constants
│   ├── models/             # Data models
│   ├── providers/          # State management
│   ├── router/             # Navigation
│   ├── services/           # API services
│   ├── theme/              # App theming
│   └── utils/              # Utilities
├── features/               # Feature modules
│   ├── auth/               # Authentication
│   ├── dashboard/          # Dashboard screens
│   ├── users/              # User management
│   ├── campaigns/          # Campaign management
│   ├── candidates/         # Candidate management
│   ├── graphics/           # Graphics & analytics
│   └── roles/              # Role management
└── shared/                 # Shared components
    └── widgets/            # Reusable widgets
```

## 🛠️ Installazione e Setup

### Prerequisiti
- Flutter SDK 3.0+
- Dart SDK 3.0+
- Git

### Clone e Setup
```bash
# Clone del repository
git clone <repository-url>
cd closer_acireale_flutter

# Installazione dipendenze
flutter pub get

# Verifica setup
flutter doctor
```

### Configurazione API
L'applicazione è configurata per utilizzare il backend esistente:
- **Base URL**: `https://www.closeracireale.it/backend/public/api`
- **CDN URL**: `https://www.closeracireale.it/cdn`

## 🚀 Esecuzione

### Web
```bash
flutter run -d chrome --web-port 3000
```

### Mobile (Android)
```bash
flutter run -d android
```

### Mobile (iOS)
```bash
flutter run -d ios
```

### Desktop (Linux)
```bash
flutter run -d linux
```

### Desktop (Windows)
```bash
flutter run -d windows
```

### Desktop (macOS)
```bash
flutter run -d macos
```

## 🏗️ Build per Produzione

### Web
```bash
flutter build web --release
```

### Android
```bash
flutter build apk --release
# oppure
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Desktop Linux
```bash
flutter build linux --release
```

### Desktop Windows
```bash
flutter build windows --release
```

### Desktop macOS
```bash
flutter build macos --release
```

## 🎨 Design System

L'applicazione utilizza un design system moderno basato su Material Design 3 con:

### Colori Principali
- **Primary Blue**: `#1E3A8A` (blue-900)
- **Primary Indigo**: `#312E81` (indigo-900)
- **Secondary Purple**: `#667EEA`
- **Secondary Blue**: `#764BA2`
- **Background Gray**: `#F8FAFC` (gray-50)
- **Success Green**: `#059669` (emerald-600)
- **Warning Yellow**: `#F59E0B` (yellow-500)
- **Error Red**: `#DC2626` (red-600)

### Tipografia
- **Font Family**: Inter
- **Weights**: Regular (400), Medium (500), SemiBold (600), Bold (700)

### Responsive Design
- **Mobile**: < 768px
- **Tablet**: 768px - 1024px  
- **Desktop**: > 1024px

## 🔧 Configurazione

### Temi
I temi sono configurati in `lib/core/theme/app_theme.dart` e supportano:
- Light theme (default)
- Dark theme (futuro)
- Custom color schemes
- Typography scales
- Component theming

### Navigation
Il routing è gestito da Go Router in `lib/core/router/app_router.dart` con:
- Route protection basata su autenticazione
- Redirect automatici
- Deep linking support
- State preservation

### State Management
L'app usa Provider per:
- `AuthProvider` - Gestione autenticazione
- `UserProvider` - Gestione utenti
- Provider specifici per ogni feature

## 🔐 Sicurezza

- Token JWT per autenticazione
- Secure storage per credenziali
- Validazione input lato client
- Gestione errori sicura
- HTTPS enforcement

## 📱 PWA Features

Per la versione web, l'app supporta:
- Installazione come PWA
- Offline capability (futuro)
- Push notifications (futuro)
- App-like experience

## 🧪 Testing

```bash
# Run tests
flutter test

# Run widget tests
flutter test test/widget_test.dart

# Run integration tests
flutter drive --target=test_driver/app.dart
```

## 📦 Dependencies

### Core
- `flutter`: SDK
- `cupertino_icons`: Icons iOS-style
- `material_design_icons_flutter`: Material icons

### HTTP & API
- `http`: HTTP client
- `dio`: Advanced HTTP client

### State Management
- `provider`: State management

### Navigation  
- `go_router`: Routing

### Storage
- `shared_preferences`: Local storage

### UI & Layout
- `flutter_screenutil`: Responsive design

### Utils
- `intl`: Internationalization

## 🤝 Contribuire

1. Fork il progetto
2. Crea un feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit le modifiche (`git commit -m 'Add some AmazingFeature'`)
4. Push al branch (`git push origin feature/AmazingFeature`)
5. Apri una Pull Request

## 📝 Changelog

### Version 1.0.0
- ✅ Implementazione sistema di autenticazione
- ✅ Dashboard principale e per scuole
- ✅ Gestione utenti completa
- ✅ Design responsivo multi-piattaforma
- ✅ Integrazione API esistenti
- ✅ Navigazione moderna con Go Router
- ✅ State management con Provider

## 📄 Licenza

Questo progetto è proprietario di Closer Acireale.

## 📞 Contatti

Per supporto tecnico o domande:
- Website: https://www.closeracireale.it
- Email: info@closeracireale.it

---

**Closer Acireale Flutter** - Sistema di Gestione Multi-piattaforma Moderno
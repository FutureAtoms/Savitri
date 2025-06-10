# Savitri - AI-Powered Psychology Therapy App

<div align="center">
  <h3>A Revolutionary Voice-First Mental Health Companion</h3>
  <p>Evidence-based therapy • Real-time voice interaction • HIPAA compliant • Cross-platform</p>
</div>

## 🎯 Project Vision

**Savitri** is a groundbreaking voice-first psychology therapy application that democratizes access to mental health support. Built on cutting-edge AI technology and clinical best practices, Savitri provides:

- **Real-time voice therapy sessions** powered by Google's Gemini AI
- **Evidence-based therapeutic protocols** (CBT, DBT, ACT)
- **Advanced emotion detection** through voice analysis
- **Crisis intervention** with immediate resource access
- **Personalized therapy** with temporal knowledge management
- **HIPAA-compliant** data handling and security

The app targets **iOS first**, followed by Android, macOS, and web platforms.

## 📊 Project Status

### Overall Progress: 58.9% Complete (33/56 tasks)

- ✅ **Done**: 33 tasks
- 🔄 **In Progress**: 2 tasks  
- ⬜ **Todo**: 21 tasks
- ❌ **Blocked**: 0 tasks

### Recent Achievements
- ✅ Successfully fixed all widget tests (TherapeuticButton, CrisisBanner, EmotionIndicator)
- ✅ Implemented core therapeutic engine with CAG/RAG architecture
- ✅ Set up Docker infrastructure with MongoDB, Redis, and monitoring
- ✅ Integrated live audio visualization with Three.js
- ✅ Established CI/CD pipeline with GitHub Actions
- ✅ Built comprehensive Flutter UI components

## 🏗️ Architecture Overview

### System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         Frontend Layer                           │
├─────────────────────────────────────────────────────────────────┤
│  Flutter App (iOS/Android)    │    Live Audio Web Interface     │
│  • Voice Interface            │    • WebRTC Audio Streaming    │
│  • Therapeutic Visualizations │    • 3D Audio Visualization    │
│  • Clinical Assessments       │    • Real-time Processing      │
└───────────────────┬───────────┴──────────────┬──────────────────┘
                    │                          │
┌───────────────────▼──────────────────────────▼──────────────────┐
│                         Backend Services                         │
├─────────────────────────────────────────────────────────────────┤
│  Node.js/TypeScript API                                         │
│  • Authentication (JWT + MFA)                                   │
│  • Therapeutic Engine (CAG/RAG)                                 │
│  • Crisis Detection System                                      │
│  • Emotion Analysis Service                                     │
│  • HIPAA Compliance Manager                                     │
└───────────────────┬─────────────────────────────────────────────┘
                    │
┌───────────────────▼─────────────────────────────────────────────┐
│                      Data & Infrastructure                       │
├─────────────────────────────────────────────────────────────────┤
│  MongoDB          │  Redis           │  Graphiti               │
│  • User Data      │  • Session Cache │  • Temporal Knowledge   │
│  • Sessions       │  • Rate Limiting │  • Patient History      │
│  • Clinical Data  │  • Quick Access  │  • Progress Tracking    │
├───────────────────┴──────────────────┴──────────────────────────┤
│  Monitoring & Observability                                     │
│  • Prometheus (Metrics)  • Grafana (Dashboards)                │
│  • Loki (Logs)          • Promtail (Log Collection)            │
└─────────────────────────────────────────────────────────────────┘
```

### Key Components

#### Frontend Applications

1. **Flutter Mobile App** (`/savitri_app`)
   - Cross-platform mobile application (iOS first)
   - Voice-first therapeutic interface
   - Real-time emotion visualization
   - Clinical assessments (PHQ-9, GAD-7)
   - Biometric authentication

2. **Live Audio Web Interface** (`/live-audio`)
   - WebRTC-based audio streaming
   - Three.js 3D visualizations
   - Real-time audio analysis
   - Gemini AI integration

#### Backend Services (`/backend`)

1. **Clinical Services**
   - `therapeutic-engine.ts`: Core therapy logic with protocol selection
   - `crisis-detector.ts`: Multi-modal crisis detection
   - `enhanced-emotion-analyzer.ts`: Voice-based emotion analysis
   - `cag-manager.ts`: Context-Augmented Generation for therapy protocols
   - `vector-database.ts`: Semantic search for therapeutic content

2. **Security & Compliance**
   - HIPAA-compliant data encryption (AES-256-GCM)
   - Audit logging for all PHI access
   - JWT-based authentication with MFA
   - Voice biometric authentication

3. **Data Persistence**
   - MongoDB schemas for Users, Sessions, Interactions
   - Temporal knowledge graph via Graphiti
   - Redis caching for performance

## 🚀 Getting Started

### Prerequisites

- Node.js 18+ and npm
- Flutter 3.13+ 
- Docker & Docker Compose
- MongoDB 6.0+
- Redis 7+
- iOS development: Xcode 15+, macOS
- Android development: Android Studio

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/savitri.git
   cd savitri
   ```

2. **Backend Setup**
   ```bash
   cd backend
   npm install
   cp .env.example .env  # Configure environment variables
   npm run build
   ```

3. **Flutter App Setup**
   ```bash
   cd savitri_app
   flutter pub get
   flutter run
   ```

4. **Live Audio Interface**
   ```bash
   cd live-audio
   npm install
   npm run dev
   ```

5. **Docker Infrastructure**
   ```bash
   docker-compose up -d  # Starts MongoDB, Redis, and monitoring stack
   ```

### Environment Configuration

Create `.env` files with required configurations:

```env
# Backend (.env)
NODE_ENV=development
PORT=3000
MONGODB_URI=mongodb://localhost:27017/savitri
REDIS_URL=redis://localhost:6379
JWT_SECRET=your-secret-key
ENCRYPTION_KEY=your-32-char-encryption-key
GEMINI_API_KEY=your-gemini-api-key
GRAPHITI_URL=your-graphiti-endpoint
```

## 🧪 Testing

### Flutter Tests
```bash
cd savitri_app
flutter test                    # Run all tests
flutter test --coverage        # With coverage
flutter test integration_test  # Integration tests
```

**Current Test Status:**
- ✅ Widget tests: All passing (TherapeuticButton, CrisisBanner, EmotionIndicator, etc.)
- 🔄 Integration tests: In progress
- ✅ Backend tests: Configured with Jest

### Backend Tests
```bash
cd backend
npm test                # Run all tests
npm run test:coverage   # With coverage
npm run test:load      # Load testing with Artillery
```

## 📚 Documentation

Comprehensive documentation is available in the `/docs` directory:

### Core Documentation
- [`psychology-chatbot-implementation-plan.md`](docs/psychology-chatbot-implementation-plan.md) - Complete implementation roadmap
- [`psychology-chatbot-requirements-live-audio.md`](docs/psychology-chatbot-requirements-live-audio.md) - Detailed requirements specification
- [`voice-first-technical-implementation.md`](docs/voice-first-technical-implementation.md) - Voice interface architecture

### Technical Guides
- [`AUTHENTICATION_GUIDE.md`](docs/AUTHENTICATION_GUIDE.md) - Authentication implementation details
- [`database-schema.md`](docs/database-schema.md) - MongoDB schema definitions
- [`live-audio-modification-guide.md`](docs/live-audio-modification-guide.md) - Guide for modifying the live audio interface
- [`gemini-live-quick-start.md`](docs/gemini-live-quick-start.md) - Gemini AI integration guide

### Compliance & Operations
- [`HIPAA_COMPLIANCE_AUDIT.md`](docs/HIPAA_COMPLIANCE_AUDIT.md) - HIPAA compliance checklist
- [`MONITORING_GUIDE.md`](docs/MONITORING_GUIDE.md) - System monitoring setup
- [`actionable-task-checklist.md`](docs/actionable-task-checklist.md) - Development task tracking

## 🔑 Key Features

### Implemented ✅
- **Voice Interface**: Real-time audio capture and processing
- **Therapeutic UI Components**: Emotion indicators, crisis banners, breathing guides
- **Authentication**: Multi-factor authentication with biometric support
- **Clinical Assessments**: PHQ-9 and GAD-7 voice-based assessments
- **3D Visualizations**: Emotion-responsive Three.js visualizations
- **Backend Infrastructure**: Dockerized services with monitoring
- **CI/CD Pipeline**: Automated testing and deployment

### In Development 🔄
- **Crisis Detection**: Advanced multi-modal crisis detection system
- **Temporal Knowledge**: Graphiti integration for session history
- **HIPAA Compliance**: Full encryption and audit trail implementation

### Planned 📋
- **Multi-language Support**: 10+ languages
- **Wearable Integration**: Heart rate, sleep tracking
- **VR Therapy**: Immersive therapeutic experiences
- **Clinical Documentation**: AI-powered SOAP notes
- **Provider Portal**: Therapist collaboration tools

## 🛠️ Technology Stack

### Frontend
- **Flutter** - Cross-platform mobile framework
- **Dart** - Programming language
- **Provider** - State management
- **WebView** - Web integration
- **Three.js** - 3D visualizations
- **WebRTC** - Real-time audio

### Backend
- **Node.js** - Runtime environment
- **TypeScript** - Type-safe JavaScript
- **Express.js** - Web framework
- **MongoDB** - Primary database
- **Redis** - Caching layer
- **Google Gemini AI** - Conversational AI
- **Graphiti** - Temporal knowledge graph

### Infrastructure
- **Docker** - Containerization
- **GitHub Actions** - CI/CD
- **Prometheus** - Metrics
- **Grafana** - Dashboards
- **Nginx** - Reverse proxy

## 🤝 Contributing

We welcome contributions! Please see our contributing guidelines (coming soon).

### Development Workflow
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is proprietary software. All rights reserved.

## 🔒 Security & Compliance

- **HIPAA Compliant**: Full compliance with healthcare data regulations
- **End-to-End Encryption**: AES-256-GCM for all sensitive data
- **Audit Trails**: Complete logging of all PHI access
- **Regular Security Audits**: Penetration testing and vulnerability assessments

## 📞 Support & Contact

For questions or support, please contact the development team.

---

<div align="center">
  <p>Built with ❤️ for mental health accessibility</p>
</div>

# Tipping Platform Flutter App

A comprehensive Flutter application for creators to receive tips and supporters to send tips.

## 🚀 Features Implemented

### ✅ Core Features (Completed)

#### Authentication System
- **REQ-001**: User registration with email and password
- **REQ-002**: Secure login and logout functionality
- **REQ-003**: Password reset via email
- User session management with local storage
- Form validation and error handling

#### Creator Profile System
- **REQ-004**: Creator profile creation and customization
- Unique URL generation for each creator
- Profile picture upload support
- Bio and display name customization
- Public profile viewing

#### Tipping System
- **REQ-005**: Send tips to creators via unique URLs
- **REQ-006**: Multiple currency support (USD, ETB)
- **REQ-007**: Optional personalized messages with tips
- Preset tip amounts and custom amount input
- Real-time tip processing simulation

#### Dashboard & Analytics
- **REQ-010**: Creator dashboard with earnings overview
- **REQ-011**: Analytics display (tips received, total earnings)
- **REQ-012**: Profile management and sharing options
- Statistics cards and quick actions

#### Localization
- **English and Amharic language support**
- **ETB currency support**
- Dynamic language switching
- Localized UI text and messages

### 🔄 In Progress / Pending Features

#### Notifications
- **REQ-013**: Real-time notifications for new tips
- **REQ-014**: Email notifications for tip receipts
- Push notification system (framework ready)

## 🏗️ Architecture

### State Management
- **Provider Pattern** for state management
- Separate providers for:
  - Authentication (AuthProvider)
  - Theme management (ThemeProvider)
  - Language settings (LanguageProvider)
  - Notifications (NotificationProvider)

### Data Models
- **User Model**: User account information and creator status
- **Tip Model**: Tip transactions with currency and status
- **Analytics Model**: Creator statistics and earnings data

### Local Storage
- **Hive** for local data persistence
- **SharedPreferences** for user settings
- Offline data caching and synchronization

### UI Components
- **Custom Widgets**: Reusable UI components
- **Material Design 3**: Modern, accessible UI
- **Responsive Design**: Works on mobile and desktop
- **Dark/Light Theme**: User preference support

## 📱 Screens Implemented

1. **Splash Screen**: App initialization and loading
2. **Authentication Screens**:
   - Login Screen
   - Registration Screen
   - Forgot Password Screen
3. **Home Screen**: Main dashboard for authenticated users
4. **Profile Screens**:
   - Edit Profile Screen
   - Creator Profile Screen (public view)
5. **Tipping Screen**: Send tips with amount and message selection
6. **Dashboard Screen**: Creator analytics and management

## 🛠️ Technical Stack

### Dependencies
```yaml
# State Management
provider: ^6.1.1

# HTTP & API
http: ^1.1.2
dio: ^5.4.0

# Local Storage
shared_preferences: ^2.2.2
hive: ^2.2.3
hive_flutter: ^1.1.0

# UI Components
flutter_staggered_animations: ^1.1.1
shimmer: ^3.0.0
cached_network_image: ^3.3.1

# Notifications
flutter_local_notifications: ^17.0.0

# Image Handling
image_picker: ^1.0.4

# Form Validation
form_validator: ^1.0.2

# Charts & Analytics
fl_chart: ^0.66.0

# QR Code Generation
qr_flutter: ^4.1.0
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.9.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd tipping_platform
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Hive adapters**
   ```bash
   dart run build_runner build
   ```

4. **Run the application**
   ```bash
   flutter run
   ```

### Configuration

1. **API Configuration**
   - Update `AppConstants.baseUrl` with your backend API URL

2. **Localization**
   - Translation files are located in `assets/translations/`
   - Add new languages by creating corresponding JSON files

3. **Theme Customization**
   - Modify colors and styles in `lib/utils/app_theme.dart`
   - Update theme constants in `lib/constants/app_constants.dart`

## 📁 Project Structure

```
lib/
├── constants/          # App constants and configuration
├── models/            # Data models with Hive annotations
├── providers/         # State management providers
├── screens/           # UI screens organized by feature
│   ├── auth/         # Authentication screens
│   ├── profile/      # Profile management screens
│   ├── tipping/      # Tipping functionality screens
│   └── dashboard/    # Creator dashboard screens
├── services/          # API and external service integrations
├── utils/            # Utility functions and theme
├── widgets/          # Reusable UI components
└── main.dart         # App entry point

assets/
├── images/           # App images and icons
├── icons/           # Custom icon assets
└── translations/    # Localization files
```

## 🔧 Development Guidelines

### Code Style
- Follow Flutter/Dart style guidelines
- Use meaningful variable and function names
- Add comments for complex logic
- Maintain consistent indentation and formatting

### State Management
- Use Provider for global state
- Keep providers focused on specific domains
- Implement proper error handling and loading states

### UI/UX
- Follow Material Design principles
- Ensure accessibility compliance
- Test on multiple screen sizes
- Maintain consistent spacing and typography

## 🧪 Testing

### Unit Tests
```bash
flutter test
```

### Widget Tests
```bash
flutter test test/widget_test.dart
```

### Integration Tests
```bash
flutter test integration_test/
```

## 🚀 Deployment

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 📋 Requirements Coverage

| Requirement | Status | Implementation |
|-------------|--------|----------------|
| REQ-001: User Registration | ✅ Complete | Auth screens with validation |
| REQ-002: Login/Logout | ✅ Complete | Secure authentication flow |
| REQ-003: Password Reset | ✅ Complete | Email-based reset system |
| REQ-004: Creator Profiles | ✅ Complete | Profile management system |
| REQ-005: Send Tips | ✅ Complete | Tipping interface |
| REQ-006: Currency Selection | ✅ Complete | USD/ETB support |
| REQ-007: Tip Messages | ✅ Complete | Optional message field |
| REQ-008: Payment Processing | 🔄 Pending | Gateway integration needed |
| REQ-009: Payment Confirmation | 🔄 Pending | Success handling ready |
| REQ-010: Creator Dashboard | ✅ Complete | Analytics and overview |
| REQ-011: Analytics | ✅ Complete | Statistics display |
| REQ-012: Payment Management | 🔄 Pending | Withdrawal system needed |
| REQ-013: Real-time Notifications | 🔄 Pending | Framework implemented |
| REQ-014: Email Notifications | 🔄 Pending | Service integration needed |

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For support and questions:
- Create an issue in the repository
- Contact the development team
- Check the documentation wiki

## 🔮 Future Enhancements

- Advanced analytics with charts and graphs
- Social features and creator discovery
- Mobile app store deployment
- Web platform expansion
- Advanced notification preferences
- Creator verification system
- Tip scheduling and recurring tips

---

**Built with ❤️ using Flutter**

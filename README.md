# My Stand Clock 🕐

A customizable Flutter stand clock application with multiple widgets, BLoC architecture, and native Android integration.

## ✨ Features

### 🎨 11 Swappable Widgets
- **Clock**: Analog/digital time display with multiple styles
- **Now Playing**: Media player integration with album art
- **Tools Carousel**: Stopwatch, Pomodoro timer, weather
- **Quote**: Inspirational quotes
- **Battery**: Battery status with visualization
- **Countdown**: Customizable countdown timer
- **Photo Frame**: Display photos from gallery
- **Ambient**: 6 animation modes (matrix, particles, waves, etc.)
- **Notifications**: Recent notification display
- **Connectivity**: WiFi/Bluetooth/mobile status
- **GIF Sticker**: Tenor API integration

### 🎯 Core Features
- **Dual-Slot Layout**: Top and bottom widget carousels
- **Burn-in Protection**: Shift and overlay modes
- **Auto-rotate**: Carousel between multiple widgets
- **Customizable Grid**: Adjustable ratios, padding, border radius
- **Fullscreen Mode**: Immersive display
- **Keep Screen On**: Wake lock support
- **Orientation Lock**: Portrait/landscape options
- **Dark/Light Themes**: Multiple color schemes

### 🏗️ Architecture
- **BLoC Pattern**: State management with flutter_bloc
- **Native Integration**: Kotlin code for Android features
- **Offline Support**: Caching for weather, quotes, media
- **Error Handling**: Global error handler with logging
- **Haptic Feedback**: Consistent tactile feedback
- **Location Services**: Auto-detect for weather

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.10.0+
- Android Studio / VS Code
- Android device or emulator

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/my_stand_clock.git
cd my_stand_clock
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure environment variables**
```bash
cp .env.example .env
# Edit .env and add your Tenor API key
```

4. **Run the app**
```bash
flutter run
```

## 🔧 Configuration

### Environment Variables

Create a `.env` file in the project root:

```env
TENOR_API_KEY=your_tenor_api_key_here
```

Get your Tenor API key from: https://developers.google.com/tenor/guides/quickstart

### Permissions

The app requires the following Android permissions:
- Internet (for API calls)
- Location (for weather)
- Calendar (optional, for calendar widget)
- Notifications (optional, for notification widget)
- Storage (optional, for photo frame)

## 📖 Documentation

- **[Implementation Guide](IMPLEMENTATION_GUIDE.md)**: Detailed setup and migration guide
- **[Existing Features](EXISTING_FEATURES.md)**: Complete feature inventory
- **[Feature Ideas](FEATURE_IDEAS.md)**: Planned future features
- **[Code Improvements](CODE_IMPROVEMENTS.md)**: Technical debt and fixes

## 🧪 Testing

Run all tests:
```bash
flutter test
```

Run specific test file:
```bash
flutter test test/blocs/settings_bloc_test.dart
```

Check code coverage:
```bash
flutter test --coverage
```

## 🏛️ Project Structure

```
lib/
├── blocs/              # BLoC state management
├── core/
│   ├── constants/      # App constants
│   ├── managers/       # Business logic managers
│   ├── models/         # Data models
│   ├── services/       # Services (cache, location, error)
│   ├── theme/          # App themes
│   └── utils/          # Utilities
├── screens/            # App screens
└── widgets/            # Reusable widgets
    ├── common/         # Shared UI components
    └── home/           # Home screen widgets
```

## 🔒 Security

- ✅ API keys stored in `.env` (not committed to git)
- ✅ Global error handler prevents sensitive data leaks
- ✅ Location permissions properly requested
- ⚠️ Review security checklist in IMPLEMENTATION_GUIDE.md

## 🐛 Known Issues

1. HomeScreen needs full refactor to use new managers (~300 lines reduction)
2. 8 empty catch blocks need proper error handling
3. 141 deprecated API warnings (run `dart fix --apply`)
4. Calendar and Media widgets need loading/error states

See [IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md) for details.

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- BLoC library maintainers
- Tenor API for GIF support
- Open-Meteo for weather data

## 📧 Contact

For questions or support, please open an issue on GitHub.

---

**Version**: 2.0.0  
**Last Updated**: January 9, 2026  
**Status**: Active Development

# 📊 BMI Health Tracker & Analytics App

A premium, fully responsive, and feature-rich Flutter application designed to track Body Mass Index (BMI), visualize weight progression, and manage family profiles. Engineered with state-of-the-art Flutter development practices, featuring beautiful dark/light adaptive aesthetics, smart analytics, and smooth micro-animations.

---

## 🌟 Premium UX & Core Features

### 1. 🌓 Persistent & Adaptive Dark Mode
- **Reactivity**: Built using a StateNotifier provider linked directly with **Hive** database storage to persist preference states across app restarts.
- **Adaptive Coloring**: Hand-tailored palettes targeting high readability in healthcare interfaces. Automatically supports Light, Dark, and System settings.
- **Dynamic Rebuild System**: Real-time theme changes propagate instantly to all screens (including cached tabs inside the navigation shell) using reactive Riverpod watch hooks.

### 2. 📈 Smart BMI Trend Insights
- **Intelligent Analytics**: The dashboard automatically calculates weight shifts by comparing your latest log with historical data from the past 7 days (or the oldest available).
- **Interactive Badging**: Displays styled badges inside the main stats card:
  - 🟢 **Weight Loss**: (e.g. `↓ 3.2 lbs this week • BMI trending down 🎉`) - Highlighting success.
  - 🟡 **Weight Gain**: (e.g. `↑ 1.2 lbs this week • Stay active!`) - Encouraging active habits.
  - ⚪ **Stable Weight**: (e.g. `Weight stable this week • Consistent progress!`) - Promoting consistency.
  - 🔵 **Log Prompts**: (e.g. `Log weight again in 7 days to see trends`) - Prompting new entries.

### 3. 🚀 Seamless Onboarding Tour
- **Interactive Slideshow**: A 3-screen PageView flow explaining key functionalities (Health Metrics, Weight Trends, Multi-Profile management).
- **Smooth Page Indicators**: Interactive dot indicators scale dynamically as you swipe between views.
- **Persistent Access**: Stores setup state to skip the tour for existing users, directly route-protecting the onboarding sequence in the GoRouter navigation tree.

### 4. ⏳ Skeleton Screen Loaders
- **Pre-emptive Rendering**: Shimmering layout placeholders cycle opacity to mirror the dashboard structure.
- **No Blank Frames**: Shown during the async Hive box and Firebase bootstrapping phase, ensuring users perceive the app as extremely fast and responsive.

### 5. 📱 App-Wide Responsiveness & Accessibility
- **Screen Agnostic Layouts**: Formulated with `Flexible` and `Expanded` widgets to guarantee perfect rendering on narrow Android screens (320px-360px) up to large flagship phones (430px+).
- **Text Scaling Defenses**: Labels, values, and status badges wrap or truncate gracefully with ellipsis (`TextOverflow.ellipsis`) so layout borders are never broken, even when large accessibility fonts are enabled.
- **Adaptive Spacing**: Padding adjusts programmatically to optimize space on smaller screens without compromising design breathing room.

### 6. 📊 Interactive Progress Chart
- **Line Visualization**: Implemented using the premium `fl_chart` package.
- **Smart Bounds**: Graph limits, intervals, and Y-axis labels calculate dynamically according to the user's logged weights.
- **Localized Units**: Adapts its grid labels instantly when units are toggled between `kg` and `lbs`.

### 7. 👥 Multi-Profile Management
- **Family Accounts**: Track data for multiple family members independently.
- **Interactive Avatar System**: Encodes images directly to base64 for lightweight database preservation and cross-platform offline utility.

---

## 🛠️ Technology Stack & Architecture

- **Core Framework**: Flutter (Web, Android, iOS)
- **State Management**: Flutter Riverpod (StateNotifier Providers)
- **Navigation & Routing**: GoRouter (including route-guard redirects)
- **Database (Local Storage)**: Hive & Hive Flutter (encrypted-ready key-value offline storage)
- **Backend Integrations**: Firebase Core & Auth
- **Data Visualization**: `fl_chart`
- **Date Formatting**: `intl`

### Folder Directory Hierarchy (Feature-First)
```
lib/
├── core/
│   ├── theme/           # AppColors dynamic palette, AppTheme, ThemeProvider
│   └── widgets/         # CustomBottomNavBar, ProfileAvatar, Shimmering Skeletons
├── features/
│   ├── auth/            # Login, Signup, Onboarding, Forgot Password
│   ├── bmi/             # BmiDashboard, Trend Insight, Progress Ring
│   ├── history/         # WeightHistory list, Dismissible logs, LineChart
│   ├── profile/         # UserDetailsForm, ProfileSwitcher, Active Profile provider
│   └── settings/        # Preferences (Unit toggles, theme settings)
├── app_router.dart      # Central GoRouter routing config & guards
└── main.dart            # Async bootstrappers & MaterialApp entry
```

---

## 🚀 Installation & Running Locally

### Prerequisites
Make sure you have Flutter SDK installed (Version `>=3.0.0`).

### 1. Clone the project
```bash
git clone <repository-url>
cd assignment
```

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Generate Local Code (if applicable)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Run the application
```bash
# Run on connected device (e.g. Chrome, Android emulator, iOS simulator)
flutter run
```

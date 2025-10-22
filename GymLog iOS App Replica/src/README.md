# GymLog iOS App Replica

A production-ready fitness tracking web application built with React and Tailwind CSS, faithfully replicating the GymLog iOS app design specifications.

## Features

### 🏠 Home Screen
- Personalized greeting based on time of day
- User profile avatar with accent ring
- Quick action buttons (New Workout, Add Exercise, Rest Timer)
- Weekly statistics dashboard (Workouts, Sets, Total Weight)
- Recent workouts list with detailed metrics
- Achievement badges showcase
- Gradient overlay for depth

### 💪 Exercises Screen
- Comprehensive exercise library
- Search functionality
- Category filtering (Chest, Back, Legs, Shoulders, Arms, Abs, Other)
- Category chips with active state
- Exercise cards with category badges
- Empty state with illustration

### 📋 Workouts Screen
- Complete workout history
- Search and filter capabilities
- Date-based filtering (All, Week, Month)
- Workout cards with colored accent strips
- Detailed metrics (exercises, sets, reps, total weight)
- Swipe-to-delete functionality (design)

### 📊 Progress Screen
- Period selector (Week, Month, Year)
- General statistics grid with trend indicators
- Interactive line chart with area fill
- Category breakdown with progress bars
- Top 5 exercises by volume
- Personal Records management
- Add/Edit/Delete PR functionality

### 🏆 Achievements Screen
- Summary statistics (Total, Unlocked, Progress %)
- Achievement cards with custom icons and colors
- Progress bars for locked achievements
- Visual distinction between locked/unlocked states
- Achievement categories:
  - Workout milestones (1, 5, 10, 20, 50)
  - Weight milestones (50k, 500k, 1M, 10M, 100M kg)

### 👤 Profile Screen
- User profile header with gradient background
- Statistics overview (4-tile grid)
- Recent achievements showcase
- Settings shortcuts
- Activity timeline
- Edit profile functionality

### ⚙️ Settings Screen
- User profile quick access
- Theme picker integration
- Data management (Add test data, Clear data)
- App version information
- Organized sections with dividers

### 🎨 Theme Picker
- System theme option
- Light theme
- Dark theme
- Visual preview with hero icon
- Selected state indicator

### Modal Sheets

#### Add Workout
- Workout name input
- Date/time picker
- Intensity selector (Low, Medium, High)
- Exercise list builder
- Create/Cancel actions

#### Add Exercise
- Exercise name input
- Muscle group category selector
- Description textarea
- Image upload placeholder
- Add/Cancel actions

#### Rest Timer
- Circular progress indicator
- Time picker (minutes/seconds)
- Quick presets (30s, 60s, 90s, 120s)
- Start/Pause functionality
- Visual countdown display

#### Add/Edit Personal Record
- Exercise selector dropdown
- Weight input with "kg" suffix
- Date picker
- Notes textarea
- Delete button (edit mode only)
- Save/Cancel actions

## Design System

### Colors
- **Light Mode:**
  - Background: `#FFFFFF`, `#F2F2F7`
  - Cards: `#FFFFFF` with subtle shadows
  - Accent: `#007AFF` (iOS Blue)
  - Text: `#1C1C1E` (primary), `#6C6C70` (secondary)
  - Dividers: `#E5E5EA`

- **Dark Mode:**
  - Background: `#000000` (pure black)
  - Cards: `#1C1C1E` with minimal shadows
  - Accent: `#7A7A7C` for icons, `#0A84FF` for text
  - Text: `#FFFFFF` (primary), `rgba(235,235,245,0.6)` (secondary)
  - Dividers: `rgba(255,255,255,0.08)`

- **Category Colors:**
  - Chest: `#FF3B30` (Red)
  - Back: `#34C759` (Green)
  - Legs: `#FF9500` (Orange)
  - Shoulders: `#AF52DE` (Purple)
  - Arms: `#5AC8FA` (Cyan)
  - Abs: `#FF2D55` (Pink)
  - Other: `#8E8E93` (Gray)

### Typography
- Display titles: 32px (SF Pro Rounded Bold equivalent)
- Section titles: 20px (SF Pro Rounded Semibold equivalent)
- Body primary: 16px (SF Pro Text Regular equivalent)
- Secondary captions: 14px
- Badges/labels: 12px

### Spacing
- Base unit: 4pt
- Section gaps: 24pt (6 units)
- Card padding: 20pt (5 units)
- Horizontal padding: 16pt (4 units)

### Corner Radii
- Cards: 16pt (rounded-2xl)
- Hero sections: 20pt (rounded-[20px])
- Chips: 8pt (rounded-lg)
- Buttons: 12pt (rounded-xl)
- Avatars: circular

### Shadows
- Light mode: `0 4px 12px rgba(0,0,0,0.05)`
- Dark mode: `0 4px 12px rgba(0,0,0,0.08)` (minimal)

## Navigation

The app uses a tab bar navigation with 5 main sections:
1. Home (Главная)
2. Exercises (Упражнения)
3. Progress (Прогресс)
4. Achievements (Награды)
5. Profile (Профиль)

Additional screens accessible via navigation:
- Settings (from Profile)
- Theme Picker (from Settings)

Modal sheets overlay the main content and can be dismissed by:
- Tapping the close button (X)
- Tapping the backdrop
- Pressing Cancel button

## Mock Data

The app includes realistic mock data:
- 12 total workouts across different muscle groups
- 10 predefined exercises
- 8 achievements with progress tracking
- 3 personal records
- Weekly statistics calculations
- Chart data for progress visualization

## Responsive Design

The app is designed for iPhone 15 Pro dimensions (393 × 852 pt) but adapts gracefully to different screen sizes. The layout uses:
- Flexible grid systems
- Scrollable content areas
- Safe area insets for iOS devices
- Backdrop blur effects
- Tab bar with safe area padding

## Theme Toggle

A demo theme toggle button (moon/sun icon) is included in the top-right corner to easily switch between light and dark modes for testing and demonstration purposes.

## Technical Implementation

- **Framework:** React with TypeScript
- **Styling:** Tailwind CSS v4.0
- **Icons:** Lucide React (SF Symbols equivalent)
- **Charts:** Recharts library
- **Animations:** CSS animations with slide-up transitions
- **State Management:** React hooks (useState)

## Browser Compatibility

Optimized for modern browsers with support for:
- CSS Grid
- Flexbox
- Backdrop filters
- CSS custom properties
- CSS animations

import { useState } from 'react';
import { HomeView } from './components/HomeView';
import { ExerciseListView } from './components/ExerciseListView';
import { WorkoutListView } from './components/WorkoutListView';
import { ProgressStatsView } from './components/ProgressStatsView';
import { ProfileView } from './components/ProfileView';
import { SettingsView } from './components/SettingsView';
import { ThemePickerView } from './components/ThemePickerView';
import { AddWorkoutSheet } from './components/AddWorkoutSheet';
import { AddExerciseSheet } from './components/AddExerciseSheet';
import { RestTimerSheet } from './components/RestTimerSheet';
import { AddPersonalRecordSheet } from './components/AddPersonalRecordSheet';
import { Home, Dumbbell, Activity, Award, User } from 'lucide-react';

export type Theme = 'system' | 'light' | 'dark';
export type Screen = 'home' | 'exercises' | 'workouts' | 'progress' | 'achievements' | 'profile' | 'settings' | 'themePicker';
export type Sheet = 'addWorkout' | 'addExercise' | 'restTimer' | 'addPR' | 'editPR' | null;

function App() {
  const [currentScreen, setCurrentScreen] = useState<Screen>('home');
  const [currentSheet, setCurrentSheet] = useState<Sheet>(null);
  const [theme, setTheme] = useState<Theme>('system');
  const [isDark, setIsDark] = useState(false);
  const [selectedPR, setSelectedPR] = useState<any>(null);

  // Toggle theme for demo purposes
  const toggleTheme = () => {
    setIsDark(!isDark);
  };

  const openSheet = (sheet: Sheet) => {
    setCurrentSheet(sheet);
  };

  const closeSheet = () => {
    setCurrentSheet(null);
    setSelectedPR(null);
  };

  const openEditPR = (pr: any) => {
    setSelectedPR(pr);
    setCurrentSheet('editPR');
  };

  // Sample data to mimic SwiftUI app
  const sampleData = {
    greeting: 'Добрый вечер!',
    weeklyStats: { workouts: 5, sets: 120, weight: 18400 },
    recentWorkouts: [
      { id: 1, name: 'Верх тела', date: 'Понедельник, 16 сентября', exercises: 4, sets: 15 },
      { id: 2, name: 'Ноги', date: 'Воскресенье, 15 сентября', exercises: 3, sets: 12 },
      // Add more as per SwiftUI
    ],
    achievements: [
      { id: 1, title: 'Первая тренировка', icon: 'play.circle.fill', unlocked: true, color: '#34C759' },
      { id: 2, title: 'Начало пути', icon: '5.circle.fill', unlocked: true, color: '#007AFF' },
      { id: 3, title: 'Регулярность', icon: '10.circle.fill', unlocked: false, color: '#5856D6' },
    ],
  };

  return (
    <div className={isDark ? 'dark' : ''}>
      <div className="relative min-h-screen bg-[#F2F2F7] dark:bg-[#000000] text-[#1C1C1E] dark:text-[#FFFFFF] transition-colors duration-300">
        {/* iPhone Frame */}
        <div className="mx-auto max-w-[393px] min-h-screen bg-[#F2F2F7] dark:bg-[#000000] relative overflow-hidden pt-[47px] pb-[34px]">
          
          {/* Top Gradient Blend for Home */}
          <div className="absolute top-0 left-0 right-0 h-[150px] bg-gradient-to-b from-black/80 via-black/60 to-black/40 dark:from-black dark:via-black dark:to-transparent z-10"></div>
          
          {/* Main Content */}
          <div className="h-screen flex flex-col">
            {currentScreen === 'home' && (
              <HomeView 
                onNavigate={setCurrentScreen} 
                onOpenSheet={openSheet}
                isDark={isDark}
                data={sampleData}
              />
            )}
            {currentScreen === 'exercises' && (
              <ExerciseListView 
                onNavigate={setCurrentScreen}
                onOpenSheet={openSheet}
                isDark={isDark}
              />
            )}
            {currentScreen === 'workouts' && (
              <WorkoutListView 
                onNavigate={setCurrentScreen}
                isDark={isDark}
              />
            )}
            {currentScreen === 'progress' && (
              <ProgressStatsView 
                onNavigate={setCurrentScreen}
                onOpenSheet={openSheet}
                onEditPR={openEditPR}
                isDark={isDark}
              />
            )}
            {currentScreen === 'achievements' && (
              <AchievementsView 
                onNavigate={setCurrentScreen}
                isDark={isDark}
              />
            )}
            {currentScreen === 'profile' && (
              <ProfileView 
                onNavigate={setCurrentScreen}
                isDark={isDark}
              />
            )}
            {currentScreen === 'settings' && (
              <SettingsView 
                onNavigate={setCurrentScreen}
                isDark={isDark}
              />
            )}
            {currentScreen === 'themePicker' && (
              <ThemePickerView 
                onNavigate={setCurrentScreen}
                currentTheme={theme}
                onThemeChange={setTheme}
                isDark={isDark}
              />
            )}

            {/* Tab Bar */}
            <div className="absolute bottom-0 left-0 right-0 bg-white/80 dark:bg-[#1C1C1E]/95 backdrop-blur-xl border-t border-[#E5E5EA]/50 dark:border-white/8 z-20">
              <div className="flex justify-around items-center h-20 pb-6">
                <TabBarItem
                  icon={Home}
                  label="Главная"
                  active={currentScreen === 'home'}
                  onClick={() => setCurrentScreen('home')}
                  isDark={isDark}
                />
                <TabBarItem
                  icon={Dumbbell}
                  label="Упражнения"
                  active={currentScreen === 'exercises'}
                  onClick={() => setCurrentScreen('exercises')}
                  isDark={isDark}
                />
                <TabBarItem
                  icon={Activity}
                  label="Прогресс"
                  active={currentScreen === 'progress'}
                  onClick={() => setCurrentScreen('progress')}
                  isDark={isDark}
                />
                <TabBarItem
                  icon={Award}
                  label="Награды"
                  active={currentScreen === 'achievements'}
                  onClick={() => setCurrentScreen('achievements')}
                  isDark={isDark}
                />
                <TabBarItem
                  icon={User}
                  label="Профиль"
                  active={currentScreen === 'profile'}
                  onClick={() => setCurrentScreen('profile')}
                  isDark={isDark}
                />
              </div>
            </div>
          </div>

          {/* Sheets */}
          {currentSheet === 'addWorkout' && (
            <AddWorkoutSheet onClose={closeSheet} isDark={isDark} />
          )}
          {currentSheet === 'addExercise' && (
            <AddExerciseSheet onClose={closeSheet} isDark={isDark} />
          )}
          {currentSheet === 'restTimer' && (
            <RestTimerSheet onClose={closeSheet} isDark={isDark} />
          )}
          {currentSheet === 'addPR' && (
            <AddPersonalRecordSheet onClose={closeSheet} isDark={isDark} />
          )}
          {currentSheet === 'editPR' && selectedPR && (
            <AddPersonalRecordSheet 
              onClose={closeSheet} 
              isDark={isDark}
              editMode={true}
              initialData={selectedPR}
            />
          )}

          {/* Theme Toggle (for demo) */}
          <button
            onClick={toggleTheme}
            className="absolute top-4 right-4 z-50 w-10 h-10 rounded-full bg-white/10 dark:bg-white/20 backdrop-blur-sm flex items-center justify-center"
          >
            {isDark ? '☀️' : '🌙'}
          </button>
        </div>
      </div>
    </div>
  );
}

function TabBarItem({ 
  icon: Icon, 
  label, 
  active, 
  onClick,
  isDark 
}: { 
  icon: any; 
  label: string; 
  active: boolean; 
  onClick: () => void;
  isDark: boolean;
}) {
  return (
    <button
      onClick={onClick}
      className="flex flex-col items-center gap-1 min-w-[60px]"
    >
      <Icon 
        size={24} 
        className={active 
          ? 'text-[#007AFF] dark:text-[#0A84FF]' 
          : 'text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)]'
        }
        strokeWidth={active ? 2.5 : 2}
      />
      <span className={`text-[10px] ${active 
        ? 'text-[#007AFF] dark:text-[#0A84FF]' 
        : 'text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)]'
      }`}>
        {label}
      </span>
    </button>
  );
}

export default App;

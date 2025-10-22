import React from 'react';
import { useState } from 'react';
import { Dumbbell, PlayCircle, CalendarBadgeClock, Repeat, Scalemass, Trophy, Lock } from 'lucide-react';

interface HomeViewProps {
  onNavigate: (screen: string) => void;
  onOpenSheet: (sheet: string) => void;
  isDark: boolean;
  data: any;
}

const HomeView: React.FC<HomeViewProps> = ({ onNavigate, onOpenSheet, isDark, data }) => {
  const { greeting, weeklyStats, recentWorkouts, achievements } = data;

  return (
    <div className="flex flex-col space-y-6 px-4 pb-5">
      {/* Header Card */}
      <div className={`rounded-3xl p-5 bg-white dark:bg-[#1C1C1E] shadow-lg dark:shadow-black/8 ${isDark ? 'shadow-[0_0px_12px_rgba(0,0,0,0.08)]' : 'shadow-[0_0px_12px_rgba(0,0,0,0.05)]'}`}>
        <div className="flex items-center justify-between mb-4">
          <div className="flex flex-col items-start">
            <Dumbbell size={24} className="text-[#007AFF] mb-1" />
            <h1 className="text-3xl font-bold text-[#1C1C1E] dark:text-white">Главная</h1>
            <p className="text-xl font-medium text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)]">{greeting}</p>
          </div>
          <div className="flex items-center">
            <p className="text-base font-medium text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)]">Готов к тренировке?</p>
          </div>
        </div>
        <div className="flex items-center justify-end -mt-5">
          <div className="w-15 h-15 rounded-full border-3 border-[#007AFF] bg-[#007AFF]/10 p-1">
            <img src="/api/placeholder/60/60" alt="Profile" className="w-full h-full rounded-full" />
          </div>
        </div>
      </div>

      {/* Quick Actions Card */}
      <div className={`rounded-2xl p-5 bg-white dark:bg-[#1C1C1E] shadow-lg dark:shadow-black/8 ${isDark ? 'shadow-[0_0px_8px_rgba(0,0,0,0.08)]' : 'shadow-[0_0px_8px_rgba(0,0,0,0.05)]'}`}>
        <h2 className="text-xl font-semibold text-[#1C1C1E] dark:text-white mb-4">Быстрые действия</h2>
        <div className="grid grid-cols-3 gap-3">
          <button className="flex flex-col items-center p-3 rounded-xl bg-[#007AFF]/10 hover:bg-[#007AFF]/20">
            <PlayCircle size={48} className="text-[#007AFF] mb-2" />
            <span className="text-sm font-medium text-[#1C1C1E] dark:text-white text-center">Новая тренировка</span>
          </button>
          <button className="flex flex-col items-center p-3 rounded-xl bg-[#007AFF]/10 hover:bg-[#007AFF]/20">
            <Dumbbell size={48} className="text-[#007AFF] mb-2" />
            <span className="text-sm font-medium text-[#1C1C1E] dark:text-white text-center">Добавить упражнение</span>
          </button>
          <button className="flex flex-col items-center p-3 rounded-xl bg-[#007AFF]/10 hover:bg-[#007AFF]/20">
            <svg className="w-12 h-12 mb-2" fill="currentColor" viewBox="0 0 20 20">
              <path d="M10 2a8 8 0 100 16 8 8 0 000-16zm0 14a6 6 0 110-12 6 6 0 010 12z" />
              <path fillRule="evenodd" d="M13.293 7.707a1 1 0 010-1.414l-5-5a1 1 0 011.414-1.414l5 5a1 1 0 010 1.414l-5 5a1 1 0 01-1.414-1.414l4.293-4.293z" />
            </svg>
            <span className="text-sm font-medium text-[#1C1C1E] dark:text-white text-center">Таймер отдыха</span>
          </button>
        </div>
      </div>

      {/* Weekly Stats Card */}
      <div className={`rounded-2xl p-5 bg-white dark:bg-[#1C1C1E] shadow-lg dark:shadow-black/8 ${isDark ? 'shadow-[0_0px_8px_rgba(0,0,0,0.08)]' : 'shadow-[0_0px_8px_rgba(0,0,0,0.05)]'}`}>
        <h2 className="text-xl font-semibold text-[#1C1C1E] dark:text-white mb-4">Статистика недели</h2>
        <div className="grid grid-cols-3 gap-4">
          <div className="flex flex-col items-center p-4 rounded-xl bg-[#007AFF]/5">
            <CalendarBadgeClock size={24} className="text-[#007AFF] mb-1" />
            <span className="text-2xl font-bold text-[#1C1C1E] dark:text-white">{weeklyStats.workouts}</span>
            <span className="text-xs text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)]">Тренировок</span>
          </div>
          <div className="flex flex-col items-center p-4 rounded-xl bg-[#34C759]/5">
            <Repeat size={24} className="text-[#34C759] mb-1" />
            <span className="text-2xl font-bold text-[#1C1C1E] dark:text-white">{weeklyStats.sets}</span>
            <span className="text-xs text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)]">Подходов</span>
          </div>
          <div className="flex flex-col items-center p-4 rounded-xl bg-[#FF3B30]/5">
            <Scalemass size={24} className="text-[#FF3B30] mb-1" />
            <span className="text-2xl font-bold text-[#1C1C1E] dark:text-white">{weeklyStats.weight.toLocaleString()}</span>
            <span className="text-xs text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)]">кг</span>
          </div>
        </div>
      </div>

      {/* Recent Workouts Card */}
      <div className={`rounded-2xl p-5 bg-white dark:bg-[#1C1C1E] shadow-lg dark:shadow-black/8 ${isDark ? 'shadow-[0_0px_8px_rgba(0,0,0,0.08)]' : 'shadow-[0_0px_8px_rgba(0,0,0,0.05)]'}`}>
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-xl font-semibold text-[#1C1C1E] dark:text-white">Последние тренировки</h2>
          <button className="text-sm text-[#007AFF] dark:text-[#0A84FF]">Все</button>
        </div>
        <div className="space-y-3">
          {recentWorkouts.slice(0, 5).map((workout) => (
            <div key={workout.id} className="flex items-center justify-between p-4 border border-[#E5E5EA]/50 dark:border-white/8 rounded-lg">
              <div className="flex flex-col">
                <p className="text-base font-medium text-[#1C1C1E] dark:text-white">{workout.date}</p>
                <p className="text-sm text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)]">{workout.exercises} упражнений • {workout.sets} подходов</p>
              </div>
              <svg className="w-4 h-4 text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
              </svg>
            </div>
          ))}
        </div>
      </div>

      {/* Achievements Card */}
      <div className={`rounded-2xl p-5 bg-white dark:bg-[#1C1C1E] shadow-lg dark:shadow-black/8 ${isDark ? 'shadow-[0_0px_8px_rgba(0,0,0,0.08)]' : 'shadow-[0_0px_8px_rgba(0,0,0,0.05)]'}`}>
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-xl font-semibold text-[#1C1C1E] dark:text-white">Достижения</h2>
          <button className="text-sm text-[#007AFF] dark:text-[#0A84FF] flex items-center gap-1">
            Все
            <svg className="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
            </svg>
          </button>
        </div>
        <div className="flex gap-3">
          {achievements.slice(0, 3).map((achievement) => (
            <div key={achievement.id} className="flex flex-col items-center p-3 rounded-lg bg-[#007AFF]/10">
              <div className={`w-8 h-8 rounded-full bg-[${achievement.color}] flex items-center justify-center mb-1`}>
                <span className="text-white text-xs">{achievement.icon}</span>
              </div>
              <span className="text-xs text-center text-[#1C1C1E] dark:text-white max-w-[80px] line-clamp-2">{achievement.title}</span>
            </div>
          ))}
          {achievements.length < 3 && (
            <div className="flex flex-col items-center p-3 rounded-lg bg-gray-200 dark:bg-gray-700">
              <Lock size={16} className="text-gray-400 mb-1" />
              <span className="text-xs text-center text-gray-500 dark:text-gray-400">Заблокировано</span>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default HomeView;

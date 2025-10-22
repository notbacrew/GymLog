import { User, Palette, ChevronRight, AlertTriangle } from 'lucide-react';
import { Screen } from '../App';

interface SettingsViewProps {
  onNavigate: (screen: Screen) => void;
  isDark: boolean;
}

export function SettingsView({ onNavigate, isDark }: SettingsViewProps) {
  return (
    <div className="flex-1 flex flex-col overflow-hidden">
      {/* Navigation Header */}
      <div className="bg-white/80 dark:bg-[#1C1C1E]/95 backdrop-blur-xl border-b border-[#E5E5EA] dark:border-white/[0.08] px-4 pt-12 pb-4">
        <h1 className="text-[28px]">Настройки</h1>
      </div>

      {/* Content */}
      <div className="flex-1 overflow-y-auto bg-[#F2F2F7] dark:bg-black">
        <div className="px-4 py-4 space-y-4 pb-28">
          
          {/* Profile Card */}
          <div
            onClick={() => onNavigate('profile')}
            className="bg-white dark:bg-[#1C1C1E] rounded-2xl p-5 shadow-[0_4px_12px_rgba(0,0,0,0.05)] dark:shadow-[0_4px_12px_rgba(0,0,0,0.08)] cursor-pointer hover:bg-[#F9F9F9] dark:hover:bg-[#2C2C2E] transition-colors"
          >
            <div className="flex items-center gap-4">
              <div className="w-[60px] h-[60px] rounded-full bg-[#007AFF]/10 dark:bg-[#7A7A7C]/10 flex items-center justify-center">
                <User size={32} className="text-[#007AFF] dark:text-[#7A7A7C]" />
              </div>
              <div className="flex-1">
                <h3 className="text-[18px] mb-0.5">Иван Иванов</h3>
                <p className="text-[14px] text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)]">
                  ivan.ivanov@example.com
                </p>
              </div>
              <ChevronRight size={20} className="text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)]" />
            </div>
          </div>

          {/* Appearance Section */}
          <div className="bg-white dark:bg-[#1C1C1E] rounded-2xl overflow-hidden shadow-[0_4px_12px_rgba(0,0,0,0.05)] dark:shadow-[0_4px_12px_rgba(0,0,0,0.08)]">
            <div className="px-5 py-3 border-b border-[#E5E5EA] dark:border-white/[0.08]">
              <h3 className="text-[13px] text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)] uppercase tracking-wide">
                Оформление
              </h3>
            </div>
            
            <button
              onClick={() => onNavigate('themePicker')}
              className="w-full flex items-center justify-between px-5 py-4 hover:bg-[#F2F2F7] dark:hover:bg-black/40 transition-colors"
            >
              <div className="flex items-center gap-3">
                <div className="w-8 h-8 rounded-full bg-[#007AFF]/10 dark:bg-[#7A7A7C]/10 flex items-center justify-center">
                  <Palette size={16} className="text-[#007AFF] dark:text-[#7A7A7C]" />
                </div>
                <span className="text-[16px]">Тема</span>
              </div>
              <div className="flex items-center gap-2">
                <span className="text-[14px] text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)]">
                  {isDark ? 'Темная' : 'Светлая'}
                </span>
                <ChevronRight size={20} className="text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)]" />
              </div>
            </button>
          </div>

          {/* Data Section */}
          <div className="bg-white dark:bg-[#1C1C1E] rounded-2xl overflow-hidden shadow-[0_4px_12px_rgba(0,0,0,0.05)] dark:shadow-[0_4px_12px_rgba(0,0,0,0.08)]">
            <div className="px-5 py-3 border-b border-[#E5E5EA] dark:border-white/[0.08]">
              <h3 className="text-[13px] text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)] uppercase tracking-wide">
                Данные
              </h3>
            </div>
            
            <button
              className="w-full flex items-center justify-between px-5 py-4 hover:bg-[#F2F2F7] dark:hover:bg-black/40 transition-colors"
            >
              <span className="text-[16px]">Добавить тестовые данные</span>
            </button>
            
            <div className="h-[1px] bg-[#E5E5EA] dark:bg-white/[0.08] mx-5" />
            
            <button
              className="w-full flex items-center justify-between px-5 py-4 hover:bg-[#F2F2F7] dark:hover:bg-black/40 transition-colors"
            >
              <div className="flex items-center gap-3">
                <div className="w-8 h-8 rounded-full bg-[#FF3B30]/10 flex items-center justify-center">
                  <AlertTriangle size={16} className="text-[#FF3B30]" />
                </div>
                <span className="text-[16px] text-[#FF3B30]">Очистить данные</span>
              </div>
            </button>
          </div>

          {/* About Section */}
          <div className="bg-white dark:bg-[#1C1C1E] rounded-2xl overflow-hidden shadow-[0_4px_12px_rgba(0,0,0,0.05)] dark:shadow-[0_4px_12px_rgba(0,0,0,0.08)]">
            <div className="px-5 py-3 border-b border-[#E5E5EA] dark:border-white/[0.08]">
              <h3 className="text-[13px] text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)] uppercase tracking-wide">
                О приложении
              </h3>
            </div>
            
            <div className="px-5 py-4">
              <div className="flex items-center justify-between">
                <span className="text-[16px]">Версия</span>
                <span className="text-[14px] text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)]">
                  1.0.0
                </span>
              </div>
            </div>
          </div>

          {/* Footer */}
          <div className="text-center py-4">
            <p className="text-[12px] text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)]">
              GymLog © 2025
            </p>
            <p className="text-[12px] text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)] mt-1">
              Версия 1.0.0 (Сборка 1)
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}

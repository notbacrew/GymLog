import { Palette, Check, ChevronLeft } from 'lucide-react';
import { Screen, Theme } from '../App';

interface ThemePickerViewProps {
  onNavigate: (screen: Screen) => void;
  currentTheme: Theme;
  onThemeChange: (theme: Theme) => void;
  isDark: boolean;
}

const themes = [
  { id: 'system' as Theme, name: 'Системная', description: 'Следовать настройкам системы' },
  { id: 'light' as Theme, name: 'Светлая', description: 'Светлая тема для дневного использования' },
  { id: 'dark' as Theme, name: 'Темная', description: 'Темная тема для ночного использования' },
];

export function ThemePickerView({ onNavigate, currentTheme, onThemeChange, isDark }: ThemePickerViewProps) {
  return (
    <div className="flex-1 flex flex-col overflow-hidden">
      {/* Navigation Header */}
      <div className="bg-white/80 dark:bg-[#1C1C1E]/95 backdrop-blur-xl border-b border-[#E5E5EA] dark:border-white/[0.08] px-4 pt-12 pb-4">
        <div className="flex items-center gap-3">
          <button
            onClick={() => onNavigate('settings')}
            className="w-9 h-9 rounded-full bg-[#007AFF]/10 dark:bg-[#7A7A7C]/10 flex items-center justify-center"
          >
            <ChevronLeft size={20} className="text-[#007AFF] dark:text-[#7A7A7C]" />
          </button>
          <h1 className="text-[28px]">Тема</h1>
        </div>
      </div>

      {/* Content */}
      <div className="flex-1 overflow-y-auto bg-[#F2F2F7] dark:bg-black">
        <div className="px-4 py-8 pb-28">
          
          {/* Hero Icon */}
          <div className="flex flex-col items-center text-center mb-8">
            <div className="w-24 h-24 rounded-full bg-[#007AFF]/10 dark:bg-[#7A7A7C]/10 flex items-center justify-center mb-4">
              <Palette size={48} className="text-[#007AFF] dark:text-[#7A7A7C]" />
            </div>
            <h2 className="text-[28px] mb-2">Выберите тему</h2>
            <p className="text-[16px] text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)] max-w-[280px]">
              Настройте внешний вид приложения под свои предпочтения
            </p>
          </div>

          {/* Theme Options */}
          <div className="space-y-3">
            {themes.map((theme) => (
              <button
                key={theme.id}
                onClick={() => onThemeChange(theme.id)}
                className={`w-full p-5 rounded-2xl transition-all ${
                  currentTheme === theme.id
                    ? 'bg-[#007AFF]/10 dark:bg-[#7A7A7C]/10 ring-2 ring-[#007AFF] dark:ring-[#7A7A7C]'
                    : 'bg-white dark:bg-[#1C1C1E] shadow-[0_4px_12px_rgba(0,0,0,0.05)] dark:shadow-[0_4px_12px_rgba(0,0,0,0.08)]'
                }`}
              >
                <div className="flex items-center justify-between">
                  <div className="text-left">
                    <h3 className={`text-[18px] mb-1 ${
                      currentTheme === theme.id ? 'text-[#007AFF] dark:text-[#7A7A7C]' : ''
                    }`}>
                      {theme.name}
                    </h3>
                    <p className="text-[14px] text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)]">
                      {theme.description}
                    </p>
                  </div>
                  
                  {currentTheme === theme.id && (
                    <div className="w-6 h-6 rounded-full bg-[#007AFF] dark:bg-[#7A7A7C] flex items-center justify-center flex-shrink-0 ml-3">
                      <Check size={14} className="text-white" strokeWidth={3} />
                    </div>
                  )}
                </div>
              </button>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

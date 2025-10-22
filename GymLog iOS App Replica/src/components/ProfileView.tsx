import { User, Calendar, Repeat, Hash, Weight, Trophy, Settings, ChevronRight, Edit } from 'lucide-react';
import { Screen } from '../App';

interface ProfileViewProps {
  onNavigate: (screen: Screen) => void;
  isDark: boolean;
}

const recentAchievements = [
  { id: 1, title: 'Первая тренировка', color: '#FF3B30', icon: '🔥' },
  { id: 2, title: '5 тренировок', color: '#34C759', icon: '📅' },
  { id: 3, title: '10 тренировок', color: '#007AFF', icon: '🎯' },
];

const recentWorkouts = [
  { id: 1, name: 'Грудь и Трицепс', date: '2025-10-18', sets: 24 },
  { id: 2, name: 'Спина и Бицепс', date: '2025-10-17', sets: 28 },
  { id: 3, name: 'Ноги', date: '2025-10-16', sets: 20 },
];

export function ProfileView({ onNavigate, isDark }: ProfileViewProps) {
  return (
    <div className="flex-1 flex flex-col overflow-hidden">
      {/* Navigation Header */}
      <div className="bg-white/80 dark:bg-[#1C1C1E]/95 backdrop-blur-xl border-b border-[#E5E5EA] dark:border-white/[0.08] px-4 pt-12 pb-4">
        <div className="flex items-center justify-between">
          <h1 className="text-[28px]">Профиль</h1>
          <button
            onClick={() => onNavigate('settings')}
            className="w-9 h-9 rounded-full bg-[#007AFF]/10 dark:bg-[#7A7A7C]/10 flex items-center justify-center"
          >
            <Settings size={20} className="text-[#007AFF] dark:text-[#7A7A7C]" />
          </button>
        </div>
      </div>

      {/* Content */}
      <div className="flex-1 overflow-y-auto bg-[#F2F2F7] dark:bg-black">
        <div className="pb-28">
          
          {/* Profile Header with Gradient */}
          <div className="relative bg-gradient-to-b from-[#007AFF]/20 to-transparent dark:from-[#7A7A7C]/20 px-4 pt-6 pb-8">
            <div className="flex flex-col items-center text-center">
              <div className="w-[90px] h-[90px] rounded-full bg-[#007AFF]/10 dark:bg-[#7A7A7C]/10 flex items-center justify-center ring-4 ring-[#007AFF]/20 dark:ring-[#7A7A7C]/20 mb-3">
                <User size={48} className="text-[#007AFF] dark:text-[#7A7A7C]" />
              </div>
              <h2 className="text-[24px] mb-1">Иван Иванов</h2>
              <p className="text-[14px] text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)] mb-4">
                ivan.ivanov@example.com
              </p>
              <button className="flex items-center gap-2 px-4 py-2 rounded-xl bg-[#007AFF]/10 dark:bg-[#7A7A7C]/10 text-[#007AFF] dark:text-[#7A7A7C]">
                <Edit size={16} />
                <span className="text-[14px]">Редактировать профиль</span>
              </button>
            </div>
          </div>

          <div className="px-4 space-y-4">
            
            {/* Statistics Grid */}
            <div className="grid grid-cols-2 gap-3">
              <StatCard
                icon={Calendar}
                label="Тренировок"
                value="12"
                isDark={isDark}
              />
              <StatCard
                icon={Repeat}
                label="Подходов"
                value="288"
                isDark={isDark}
              />
              <StatCard
                icon={Hash}
                label="Повторений"
                value="2 304"
                isDark={isDark}
              />
              <StatCard
                icon={Weight}
                label="Общий вес"
                value="49 200 кг"
                isDark={isDark}
              />
            </div>

            {/* Recent Achievements */}
            <div className="bg-white dark:bg-[#1C1C1E] rounded-2xl p-5 shadow-[0_4px_12px_rgba(0,0,0,0.05)] dark:shadow-[0_4px_12px_rgba(0,0,0,0.08)]">
              <div className="flex items-center justify-between mb-4">
                <h2>Последние награды</h2>
                <button
                  onClick={() => onNavigate('achievements')}
                  className="flex items-center gap-1 text-[#007AFF] dark:text-[#0A84FF]"
                >
                  <span className="text-[14px]">Все</span>
                  <ChevronRight size={16} />
                </button>
              </div>
              
              <div className="flex gap-3">
                {recentAchievements.map((achievement) => (
                  <div
                    key={achievement.id}
                    className="flex-1 aspect-square rounded-2xl flex flex-col items-center justify-center p-3"
                    style={{ backgroundColor: `${achievement.color}20` }}
                  >
                    <div className="text-[32px] mb-1">{achievement.icon}</div>
                    <p className="text-[11px] text-center text-[#1C1C1E] dark:text-white leading-tight">
                      {achievement.title}
                    </p>
                  </div>
                ))}
              </div>
            </div>

            {/* Settings Shortcuts */}
            <div className="bg-white dark:bg-[#1C1C1E] rounded-2xl overflow-hidden shadow-[0_4px_12px_rgba(0,0,0,0.05)] dark:shadow-[0_4px_12px_rgba(0,0,0,0.08)]">
              <SettingsRow
                title="Редактировать профиль"
                onClick={() => {}}
                isDark={isDark}
              />
              <div className="h-[1px] bg-[#E5E5EA] dark:bg-white/[0.08] mx-5" />
              <SettingsRow
                title="Изменить пароль"
                onClick={() => {}}
                isDark={isDark}
              />
            </div>

            {/* Activity Timeline */}
            <div className="bg-white dark:bg-[#1C1C1E] rounded-2xl p-5 shadow-[0_4px_12px_rgba(0,0,0,0.05)] dark:shadow-[0_4px_12px_rgba(0,0,0,0.08)]">
              <h2 className="mb-4">Активность</h2>
              <div className="space-y-3">
                {recentWorkouts.map((workout) => (
                  <div
                    key={workout.id}
                    className="flex items-center justify-between p-3 rounded-xl bg-[#F2F2F7] dark:bg-black/40"
                  >
                    <div>
                      <p className="text-[14px] mb-0.5">{workout.name}</p>
                      <p className="text-[12px] text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)]">
                        {new Date(workout.date).toLocaleDateString('ru-RU', {
                          day: 'numeric',
                          month: 'long',
                        })}
                      </p>
                    </div>
                    <div className="text-right">
                      <p className="text-[14px] text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)]">
                        {workout.sets} подходов
                      </p>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

function StatCard({ icon: Icon, label, value, isDark }: any) {
  return (
    <div className="bg-white dark:bg-[#1C1C1E] rounded-2xl p-4 shadow-[0_4px_12px_rgba(0,0,0,0.05)] dark:shadow-[0_4px_12px_rgba(0,0,0,0.08)]">
      <Icon size={20} className="text-[#007AFF] dark:text-[#7A7A7C] mb-2" />
      <p className="text-[24px] mb-1">{value}</p>
      <p className="text-[12px] text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)]">
        {label}
      </p>
    </div>
  );
}

function SettingsRow({ title, onClick, isDark }: any) {
  return (
    <button
      onClick={onClick}
      className="w-full flex items-center justify-between px-5 py-4 hover:bg-[#F2F2F7] dark:hover:bg-black/40 transition-colors"
    >
      <span className="text-[16px]">{title}</span>
      <ChevronRight size={20} className="text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)]" />
    </button>
  );
}

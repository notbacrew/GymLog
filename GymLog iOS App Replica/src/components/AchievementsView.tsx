import { Trophy, Flame, Calendar, Target, Award, Dumbbell, Weight } from 'lucide-react';
import { Screen } from '../App';

interface AchievementsViewProps {
  onNavigate: (screen: Screen) => void;
  isDark: boolean;
}

const achievements = [
  {
    id: 1,
    title: 'Первые шаги',
    description: 'Завершите первую тренировку',
    icon: Flame,
    color: '#FF3B30',
    progress: 1,
    max: 1,
    unlocked: true,
  },
  {
    id: 2,
    title: '5 тренировок',
    description: 'Завершите 5 тренировок',
    icon: Calendar,
    color: '#34C759',
    progress: 5,
    max: 5,
    unlocked: true,
  },
  {
    id: 3,
    title: '10 тренировок',
    description: 'Завершите 10 тренировок',
    icon: Target,
    color: '#007AFF',
    progress: 10,
    max: 10,
    unlocked: true,
  },
  {
    id: 4,
    title: '20 тренировок',
    description: 'Завершите 20 тренировок',
    icon: Award,
    color: '#AF52DE',
    progress: 12,
    max: 20,
    unlocked: false,
  },
  {
    id: 5,
    title: '50 тренировок',
    description: 'Завершите 50 тренировок',
    icon: Trophy,
    color: '#FF9500',
    progress: 12,
    max: 50,
    unlocked: false,
  },
  {
    id: 6,
    title: 'Поднял 50 000 кг',
    description: 'Поднимите 50 000 кг за все время',
    icon: Weight,
    color: '#5AC8FA',
    progress: 18400,
    max: 50000,
    unlocked: false,
  },
  {
    id: 7,
    title: 'Поднял 500 000 кг',
    description: 'Поднимите 500 000 кг за все время',
    icon: Dumbbell,
    color: '#FF2D55',
    progress: 18400,
    max: 500000,
    unlocked: false,
  },
  {
    id: 8,
    title: 'Поднял 1 000 000 кг',
    description: 'Поднимите 1 000 000 кг за все время',
    icon: Trophy,
    color: '#FFD60A',
    progress: 18400,
    max: 1000000,
    unlocked: false,
  },
];

export function AchievementsView({ onNavigate, isDark }: AchievementsViewProps) {
  const unlockedCount = achievements.filter(a => a.unlocked).length;
  const totalCount = achievements.length;
  const completionPercentage = Math.round((unlockedCount / totalCount) * 100);

  return (
    <div className="flex-1 flex flex-col overflow-hidden">
      {/* Navigation Header */}
      <div className="bg-white/80 dark:bg-[#1C1C1E]/95 backdrop-blur-xl border-b border-[#E5E5EA] dark:border-white/[0.08] px-4 pt-12 pb-4">
        <h1 className="text-[28px]">Достижения</h1>
      </div>

      {/* Content */}
      <div className="flex-1 overflow-y-auto bg-[#F2F2F7] dark:bg-black">
        <div className="px-4 py-4 space-y-4 pb-28">
          
          {/* Summary Card */}
          <div className="bg-white dark:bg-[#1C1C1E] rounded-2xl p-5 shadow-[0_4px_12px_rgba(0,0,0,0.05)] dark:shadow-[0_4px_12px_rgba(0,0,0,0.08)]">
            <div className="grid grid-cols-3 gap-4">
              <div className="text-center">
                <div className="w-12 h-12 mx-auto mb-2 rounded-full bg-[#007AFF]/10 dark:bg-[#7A7A7C]/10 flex items-center justify-center">
                  <Dumbbell size={24} className="text-[#007AFF] dark:text-[#7A7A7C]" />
                </div>
                <p className="text-[24px] text-[#007AFF] dark:text-[#0A84FF] mb-0.5">
                  {totalCount}
                </p>
                <p className="text-[12px] text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)]">
                  Всего
                </p>
              </div>
              
              <div className="text-center">
                <div className="w-12 h-12 mx-auto mb-2 rounded-full bg-[#34C759]/10 flex items-center justify-center">
                  <Trophy size={24} className="text-[#34C759]" />
                </div>
                <p className="text-[24px] text-[#34C759] mb-0.5">
                  {unlockedCount}
                </p>
                <p className="text-[12px] text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)]">
                  Получено
                </p>
              </div>
              
              <div className="text-center">
                <div className="w-12 h-12 mx-auto mb-2 rounded-full bg-[#FF9500]/10 flex items-center justify-center">
                  <Target size={24} className="text-[#FF9500]" />
                </div>
                <p className="text-[24px] text-[#FF9500] mb-0.5">
                  {completionPercentage}%
                </p>
                <p className="text-[12px] text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)]">
                  Прогресс
                </p>
              </div>
            </div>
          </div>

          {/* Achievements List */}
          <div className="space-y-3">
            {achievements.map((achievement) => (
              <div
                key={achievement.id}
                className={`bg-white dark:bg-[#1C1C1E] rounded-2xl p-5 shadow-[0_4px_12px_rgba(0,0,0,0.05)] dark:shadow-[0_4px_12px_rgba(0,0,0,0.08)] ${
                  !achievement.unlocked ? 'opacity-60' : ''
                }`}
              >
                <div className="flex items-start gap-4">
                  <div
                    className="w-14 h-14 rounded-full flex items-center justify-center flex-shrink-0"
                    style={{ backgroundColor: `${achievement.color}20` }}
                  >
                    <achievement.icon
                      size={28}
                      style={{ color: achievement.color }}
                    />
                  </div>
                  
                  <div className="flex-1 min-w-0">
                    <div className="flex items-start justify-between mb-2">
                      <div className="flex-1">
                        <h3 className="text-[18px] mb-0.5">
                          {achievement.title}
                        </h3>
                        <p className="text-[14px] text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)]">
                          {achievement.description}
                        </p>
                      </div>
                      
                      {achievement.unlocked && (
                        <div className="w-6 h-6 rounded-full bg-[#34C759] flex items-center justify-center ml-2 flex-shrink-0">
                          <svg
                            width="14"
                            height="10"
                            viewBox="0 0 14 10"
                            fill="none"
                            xmlns="http://www.w3.org/2000/svg"
                          >
                            <path
                              d="M1 5L5 9L13 1"
                              stroke="white"
                              strokeWidth="2"
                              strokeLinecap="round"
                              strokeLinejoin="round"
                            />
                          </svg>
                        </div>
                      )}
                    </div>
                    
                    {!achievement.unlocked && (
                      <div>
                        <div className="flex items-center justify-between mb-1.5">
                          <span className="text-[12px] text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)]">
                            {achievement.progress.toLocaleString('ru-RU')} / {achievement.max.toLocaleString('ru-RU')}
                          </span>
                          <span className="text-[12px] text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)]">
                            {Math.round((achievement.progress / achievement.max) * 100)}%
                          </span>
                        </div>
                        <div className="h-2 bg-[#F2F2F7] dark:bg-black/40 rounded-full overflow-hidden">
                          <div
                            className="h-full rounded-full transition-all"
                            style={{
                              width: `${Math.min((achievement.progress / achievement.max) * 100, 100)}%`,
                              backgroundColor: achievement.color,
                            }}
                          />
                        </div>
                      </div>
                    )}
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

import { useState } from 'react';
import { Search, Calendar, Dumbbell, X } from 'lucide-react';
import { Screen } from '../App';

interface WorkoutListViewProps {
  onNavigate: (screen: Screen) => void;
  isDark: boolean;
}

const workouts = [
  {
    id: 1,
    name: 'Грудь и Трицепс',
    date: '2025-10-18',
    time: '18:30',
    exercises: 6,
    sets: 24,
    reps: 192,
    totalWeight: 4800,
    color: '#FF3B30',
  },
  {
    id: 2,
    name: 'Спина и Бицепс',
    date: '2025-10-17',
    time: '19:00',
    exercises: 7,
    sets: 28,
    reps: 224,
    totalWeight: 5600,
    color: '#34C759',
  },
  {
    id: 3,
    name: 'Ноги',
    date: '2025-10-16',
    time: '17:45',
    exercises: 5,
    sets: 20,
    reps: 160,
    totalWeight: 6400,
    color: '#FF9500',
  },
  {
    id: 4,
    name: 'Плечи',
    date: '2025-10-15',
    time: '18:15',
    exercises: 6,
    sets: 24,
    reps: 192,
    totalWeight: 3600,
    color: '#AF52DE',
  },
  {
    id: 5,
    name: 'Руки',
    date: '2025-10-14',
    time: '19:30',
    exercises: 4,
    sets: 24,
    reps: 240,
    totalWeight: 2880,
    color: '#5AC8FA',
  },
];

export function WorkoutListView({ onNavigate, isDark }: WorkoutListViewProps) {
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedFilter, setSelectedFilter] = useState('all');

  const filteredWorkouts = workouts.filter(workout =>
    workout.name.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <div className="flex-1 flex flex-col overflow-hidden">
      {/* Navigation Header */}
      <div className="bg-white/80 dark:bg-[#1C1C1E]/95 backdrop-blur-xl border-b border-[#E5E5EA] dark:border-white/[0.08] px-4 pt-12 pb-4">
        <h1 className="text-[28px]">Тренировки</h1>
      </div>

      {/* Filter Section */}
      <div className="bg-black px-4 py-4 space-y-3">
        {/* Search Bar */}
        <div className="relative">
          <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)]" />
          <input
            type="text"
            placeholder="Поиск тренировок..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full h-11 pl-10 pr-10 rounded-xl bg-white dark:bg-[#1C1C1E] border border-[#E5E5EA] dark:border-white/[0.08] text-[#1C1C1E] dark:text-white placeholder:text-[#6C6C70] dark:placeholder:text-[rgba(235,235,245,0.6)] outline-none focus:ring-2 focus:ring-[#007AFF]/20 dark:focus:ring-[#7A7A7C]/20"
          />
          {searchQuery && (
            <button
              onClick={() => setSearchQuery('')}
              className="absolute right-3 top-1/2 -translate-y-1/2"
            >
              <X size={16} className="text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)]" />
            </button>
          )}
        </div>

        {/* Filter Chips */}
        <div className="flex gap-2 overflow-x-auto pb-2 scrollbar-hide">
          {['all', 'week', 'month'].map((filter) => (
            <button
              key={filter}
              onClick={() => setSelectedFilter(filter)}
              className={`flex items-center gap-1.5 px-3 h-8 rounded-lg whitespace-nowrap transition-colors ${
                selectedFilter === filter
                  ? 'bg-[#007AFF]/10 dark:bg-[#7A7A7C]/10 text-[#007AFF] dark:text-[#7A7A7C]'
                  : 'bg-white dark:bg-[#1C1C1E] text-[#1C1C1E] dark:text-white border border-[#E5E5EA] dark:border-white/[0.08]'
              }`}
            >
              <Calendar size={12} />
              <span className="text-[14px]">
                {filter === 'all' ? 'Все' : filter === 'week' ? 'Неделя' : 'Месяц'}
              </span>
            </button>
          ))}
        </div>
      </div>

      {/* Workout List */}
      <div className="flex-1 overflow-y-auto bg-[#F2F2F7] dark:bg-black px-4 py-4">
        <div className="space-y-3 pb-4">
          {filteredWorkouts.map((workout) => (
            <div
              key={workout.id}
              className="bg-white dark:bg-[#1C1C1E] rounded-2xl overflow-hidden shadow-[0_4px_12px_rgba(0,0,0,0.05)] dark:shadow-[0_4px_12px_rgba(0,0,0,0.08)] cursor-pointer hover:bg-[#F9F9F9] dark:hover:bg-[#2C2C2E] transition-colors"
            >
              <div className="flex">
                <div
                  className="w-1 flex-shrink-0"
                  style={{ backgroundColor: workout.color }}
                />
                
                <div className="flex-1 p-5">
                  <div className="flex items-start justify-between mb-3">
                    <div>
                      <h3 className="text-[18px] mb-1">{workout.name}</h3>
                      <div className="flex items-center gap-2 text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)]">
                        <Calendar size={14} />
                        <span className="text-[14px]">
                          {new Date(workout.date).toLocaleDateString('ru-RU', {
                            day: 'numeric',
                            month: 'long',
                          })}{' '}
                          в {workout.time}
                        </span>
                      </div>
                    </div>
                  </div>
                  
                  <div className="grid grid-cols-2 gap-3">
                    <div className="flex items-center gap-2 px-3 py-2 rounded-lg bg-[#F2F2F7] dark:bg-black/40">
                      <Dumbbell size={16} className="text-[#007AFF] dark:text-[#7A7A7C]" />
                      <div>
                        <p className="text-[12px] text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)]">
                          Упражнений
                        </p>
                        <p className="text-[16px]">{workout.exercises}</p>
                      </div>
                    </div>
                    
                    <div className="flex items-center gap-2 px-3 py-2 rounded-lg bg-[#F2F2F7] dark:bg-black/40">
                      <span className="text-[16px] text-[#007AFF] dark:text-[#7A7A7C]">↻</span>
                      <div>
                        <p className="text-[12px] text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)]">
                          Подходов
                        </p>
                        <p className="text-[16px]">{workout.sets}</p>
                      </div>
                    </div>
                    
                    <div className="flex items-center gap-2 px-3 py-2 rounded-lg bg-[#F2F2F7] dark:bg-black/40">
                      <span className="text-[16px] text-[#007AFF] dark:text-[#7A7A7C]">#</span>
                      <div>
                        <p className="text-[12px] text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)]">
                          Повторений
                        </p>
                        <p className="text-[16px]">{workout.reps}</p>
                      </div>
                    </div>
                    
                    <div className="flex items-center gap-2 px-3 py-2 rounded-lg bg-[#F2F2F7] dark:bg-black/40">
                      <span className="text-[16px] text-[#007AFF] dark:text-[#7A7A7C]">⚖</span>
                      <div>
                        <p className="text-[12px] text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)]">
                          Вес
                        </p>
                        <p className="text-[16px]">
                          {workout.totalWeight.toLocaleString('ru-RU')} кг
                        </p>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

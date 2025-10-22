import { useState } from 'react';
import { Plus, Trophy, TrendingUp, TrendingDown, Calendar, Dumbbell, Repeat, Weight, Pencil } from 'lucide-react';
import { Screen, Sheet } from '../App';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Area, AreaChart } from 'recharts';

interface ProgressStatsViewProps {
  onNavigate: (screen: Screen) => void;
  onOpenSheet: (sheet: Sheet) => void;
  onEditPR: (pr: any) => void;
  isDark: boolean;
}

const categoryColors: Record<string, string> = {
  'Грудь': '#FF3B30',
  'Спина': '#34C759',
  'Ноги': '#FF9500',
  'Плечи': '#AF52DE',
  'Руки': '#5AC8FA',
  'Пресс': '#FF2D55',
  'Разное': '#8E8E93',
};

const chartData = [
  { date: 'Пн', weight: 3200 },
  { date: 'Вт', weight: 3800 },
  { date: 'Ср', weight: 4200 },
  { date: 'Чт', weight: 3600 },
  { date: 'Пт', weight: 4800 },
  { date: 'Сб', weight: 4400 },
  { date: 'Вс', weight: 5200 },
];

const categoryBreakdown = [
  { name: 'Грудь', volume: 12400, percentage: 25 },
  { name: 'Спина', volume: 14800, percentage: 30 },
  { name: 'Ноги', volume: 16200, percentage: 33 },
  { name: 'Плечи', volume: 3200, percentage: 6.5 },
  { name: 'Руки', volume: 2600, percentage: 5.5 },
];

const topExercises = [
  { name: 'Приседания со штангой', weight: 16200, sets: 20, reps: 160 },
  { name: 'Становая тяга', weight: 12800, sets: 16, reps: 128 },
  { name: 'Жим штанги лежа', weight: 9600, sets: 24, reps: 192 },
  { name: 'Подтягивания', weight: 4800, sets: 20, reps: 200 },
  { name: 'Жим гантелей сидя', weight: 3200, sets: 18, reps: 144 },
];

const personalRecords = [
  { id: 1, exercise: 'Жим штанги лежа', weight: 120, date: '2025-10-15', note: 'Новый личный рекорд!' },
  { id: 2, exercise: 'Приседания со штангой', weight: 180, date: '2025-10-12', note: '' },
  { id: 3, exercise: 'Становая тяга', weight: 200, date: '2025-10-10', note: 'Отличная форма' },
];

export function ProgressStatsView({ onNavigate, onOpenSheet, onEditPR, isDark }: ProgressStatsViewProps) {
  const [selectedPeriod, setSelectedPeriod] = useState<'week' | 'month' | 'year'>('week');

  return (
    <div className="flex-1 flex flex-col overflow-hidden">
      {/* Navigation Header */}
      <div className="bg-white/80 dark:bg-[#1C1C1E]/95 backdrop-blur-xl border-b border-[#E5E5EA] dark:border-white/[0.08] px-4 pt-12 pb-4">
        <h1 className="text-[28px] text-center">Прогресс</h1>
      </div>

      {/* Content */}
      <div className="flex-1 overflow-y-auto bg-[#F2F2F7] dark:bg-black">
        <div className="px-4 py-4 space-y-6 pb-28">
          
          {/* Period Selector */}
          <div className="bg-white dark:bg-[#1C1C1E] rounded-2xl p-1.5 flex gap-1 shadow-[0_4px_12px_rgba(0,0,0,0.05)] dark:shadow-[0_4px_12px_rgba(0,0,0,0.08)]">
            {(['week', 'month', 'year'] as const).map((period) => (
              <button
                key={period}
                onClick={() => setSelectedPeriod(period)}
                className={`flex-1 h-9 rounded-lg transition-colors ${
                  selectedPeriod === period
                    ? 'bg-[#007AFF] dark:bg-[#7A7A7C] text-white'
                    : 'text-[#1C1C1E] dark:text-white'
                }`}
              >
                <span className="text-[14px]">
                  {period === 'week' ? 'Неделя' : period === 'month' ? 'Месяц' : 'Год'}
                </span>
              </button>
            ))}
          </div>

          {/* General Stats Grid */}
          <div className="grid grid-cols-2 gap-3">
            <StatCard
              icon={Calendar}
              label="Тренировок"
              value="5"
              delta="+2"
              positive={true}
              isDark={isDark}
            />
            <StatCard
              icon={Repeat}
              label="Подходов"
              value="120"
              delta="+24"
              positive={true}
              isDark={isDark}
            />
            <StatCard
              icon={Dumbbell}
              label="Повторений"
              value="960"
              delta="+192"
              positive={true}
              isDark={isDark}
            />
            <StatCard
              icon={Weight}
              label="Общий вес (кг)"
              value="18 400"
              delta="+3200"
              positive={true}
              isDark={isDark}
            />
          </div>

          {/* Progress Chart */}
          <div className="bg-white dark:bg-[#1C1C1E] rounded-2xl p-5 shadow-[0_4px_12px_rgba(0,0,0,0.05)] dark:shadow-[0_4px_12px_rgba(0,0,0,0.08)]">
            <h2 className="mb-4">График прогресса</h2>
            <div className="h-[200px]">
              <ResponsiveContainer width="100%" height="100%">
                <AreaChart data={chartData}>
                  <defs>
                    <linearGradient id="colorWeight" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor={isDark ? '#7A7A7C' : '#007AFF'} stopOpacity={0.3}/>
                      <stop offset="95%" stopColor={isDark ? '#7A7A7C' : '#007AFF'} stopOpacity={0}/>
                    </linearGradient>
                  </defs>
                  <CartesianGrid strokeDasharray="3 3" stroke={isDark ? 'rgba(255,255,255,0.08)' : '#E5E5EA'} />
                  <XAxis 
                    dataKey="date" 
                    stroke={isDark ? 'rgba(235,235,245,0.6)' : '#6C6C70'}
                    style={{ fontSize: '12px' }}
                  />
                  <YAxis 
                    stroke={isDark ? 'rgba(235,235,245,0.6)' : '#6C6C70'}
                    style={{ fontSize: '12px' }}
                  />
                  <Tooltip 
                    contentStyle={{
                      backgroundColor: isDark ? '#1C1C1E' : 'white',
                      border: `1px solid ${isDark ? 'rgba(255,255,255,0.08)' : '#E5E5EA'}`,
                      borderRadius: '8px',
                      color: isDark ? 'white' : '#1C1C1E',
                    }}
                  />
                  <Area 
                    type="monotone" 
                    dataKey="weight" 
                    stroke={isDark ? '#7A7A7C' : '#007AFF'} 
                    strokeWidth={2}
                    fill="url(#colorWeight)" 
                  />
                </AreaChart>
              </ResponsiveContainer>
            </div>
          </div>

          {/* Category Breakdown */}
          <div className="bg-white dark:bg-[#1C1C1E] rounded-2xl p-5 shadow-[0_4px_12px_rgba(0,0,0,0.05)] dark:shadow-[0_4px_12px_rgba(0,0,0,0.08)]">
            <h2 className="mb-4">По группам мышц</h2>
            <div className="space-y-3">
              {categoryBreakdown.map((category) => (
                <div key={category.name}>
                  <div className="flex items-center justify-between mb-1.5">
                    <span className="text-[14px]">{category.name}</span>
                    <span className="text-[14px] text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)]">
                      {category.volume.toLocaleString('ru-RU')} кг
                    </span>
                  </div>
                  <div className="h-2 bg-[#F2F2F7] dark:bg-black/40 rounded-full overflow-hidden">
                    <div
                      className="h-full rounded-full transition-all"
                      style={{
                        width: `${category.percentage}%`,
                        backgroundColor: categoryColors[category.name],
                        minWidth: '8px',
                      }}
                    />
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Top Exercises */}
          <div className="bg-white dark:bg-[#1C1C1E] rounded-2xl p-5 shadow-[0_4px_12px_rgba(0,0,0,0.05)] dark:shadow-[0_4px_12px_rgba(0,0,0,0.08)]">
            <h2 className="mb-4">Топ упражнений</h2>
            <div className="space-y-3">
              {topExercises.map((exercise, index) => (
                <div
                  key={exercise.name}
                  className="flex items-center gap-3 p-3 rounded-xl bg-[#F2F2F7] dark:bg-black/40"
                >
                  <div className="w-8 h-8 rounded-full bg-[#007AFF]/10 dark:bg-[#7A7A7C]/10 flex items-center justify-center flex-shrink-0">
                    <span className="text-[14px] text-[#007AFF] dark:text-[#7A7A7C]">
                      {index + 1}
                    </span>
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-[14px] truncate mb-0.5">{exercise.name}</p>
                    <p className="text-[12px] text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)]">
                      {exercise.sets} × {exercise.reps / exercise.sets} повторений
                    </p>
                  </div>
                  <div className="text-right">
                    <p className="text-[16px]">
                      {exercise.weight.toLocaleString('ru-RU')} кг
                    </p>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Personal Records */}
          <div className="bg-white dark:bg-[#1C1C1E] rounded-2xl p-5 shadow-[0_4px_12px_rgba(0,0,0,0.05)] dark:shadow-[0_4px_12px_rgba(0,0,0,0.08)]">
            <div className="flex items-center justify-between mb-4">
              <h2>Личные рекорды</h2>
              <button
                onClick={() => onOpenSheet('addPR')}
                className="w-8 h-8 rounded-full bg-[#007AFF]/10 dark:bg-[#7A7A7C]/10 flex items-center justify-center"
              >
                <Plus size={16} className="text-[#007AFF] dark:text-[#7A7A7C]" />
              </button>
            </div>

            {personalRecords.length === 0 ? (
              <div className="flex flex-col items-center justify-center py-8 text-center">
                <Trophy size={48} className="text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)] mb-3" />
                <p className="text-[14px] text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)]">
                  Добавьте свой первый личный рекорд
                </p>
              </div>
            ) : (
              <div className="space-y-3">
                {personalRecords.map((record) => (
                  <div
                    key={record.id}
                    className="p-4 rounded-xl bg-[#F2F2F7] dark:bg-black/40"
                  >
                    <div className="flex items-start justify-between mb-2">
                      <div className="flex items-start gap-3 flex-1">
                        <div className="w-10 h-10 rounded-full bg-[#FF9500]/20 flex items-center justify-center flex-shrink-0">
                          <Trophy size={20} className="text-[#FF9500]" />
                        </div>
                        <div className="flex-1">
                          <p className="text-[16px] mb-0.5">{record.exercise}</p>
                          <p className="text-[12px] text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)]">
                            {new Date(record.date).toLocaleDateString('ru-RU', {
                              day: 'numeric',
                              month: 'long',
                              year: 'numeric',
                            })}
                          </p>
                        </div>
                      </div>
                      <div className="flex items-center gap-3">
                        <div className="text-right">
                          <div className="inline-flex items-center px-2 py-1 rounded bg-[#007AFF]/10 dark:bg-[#7A7A7C]/10 mb-1">
                            <span className="text-[12px] text-[#007AFF] dark:text-[#7A7A7C]">
                              PR
                            </span>
                          </div>
                          <p className="text-[18px]">{record.weight} кг</p>
                        </div>
                        <button
                          onClick={() => onEditPR(record)}
                          className="w-8 h-8 rounded-full hover:bg-white/10 dark:hover:bg-white/5 flex items-center justify-center transition-colors"
                        >
                          <Pencil size={16} className="text-[#007AFF] dark:text-[#7A7A7C]" />
                        </button>
                      </div>
                    </div>
                    {record.note && (
                      <p className="text-[14px] text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)] ml-[52px]">
                        {record.note}
                      </p>
                    )}
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}

function StatCard({ icon: Icon, label, value, delta, positive, isDark }: any) {
  return (
    <div className="bg-white dark:bg-[#1C1C1E] rounded-2xl p-4 shadow-[0_4px_12px_rgba(0,0,0,0.05)] dark:shadow-[0_4px_12px_rgba(0,0,0,0.08)]">
      <Icon size={20} className="text-[#007AFF] dark:text-[#7A7A7C] mb-2" />
      <p className="text-[24px] mb-1">{value}</p>
      <div className="flex items-center justify-between">
        <p className="text-[12px] text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)]">
          {label}
        </p>
        {delta && (
          <div className={`flex items-center gap-0.5 px-1.5 py-0.5 rounded ${
            positive 
              ? 'bg-[#34C759]/10 text-[#34C759]' 
              : 'bg-[#FF3B30]/10 text-[#FF3B30]'
          }`}>
            {positive ? <TrendingUp size={10} /> : <TrendingDown size={10} />}
            <span className="text-[10px]">{delta}</span>
          </div>
        )}
      </div>
    </div>
  );
}

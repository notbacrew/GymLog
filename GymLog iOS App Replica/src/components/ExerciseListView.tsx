import React, { useState } from 'react';
import { MagnifyingGlass, Tag, ChevronRight, Dumbbell } from 'lucide-react';

interface ExerciseListViewProps {
  onNavigate: (screen: string) => void;
  onOpenSheet: (sheet: string) => void;
  isDark: boolean;
}

const ExerciseListView: React.FC<ExerciseListViewProps> = ({ onNavigate, onOpenSheet, isDark }) => {
  const [searchText, setSearchText] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('Все');
  const categories = ['Все', 'Грудь', 'Спина', 'Ноги', 'Плечи', 'Руки', 'Пресс', 'Разное'];
  const exercises = [
    { id: 1, name: 'Жим лежа', category: 'Грудь', image: '/api/placeholder/60/60' },
    { id: 2, name: 'Подтягивания', category: 'Спина', image: '/api/placeholder/60/60' },
    // Add more sample exercises
  ];

  const filteredExercises = exercises.filter(ex => 
    ex.name.toLowerCase().includes(searchText.toLowerCase()) &&
    (selectedCategory === 'Все' || ex.category === selectedCategory)
  );

  return (
    <div className="flex flex-col h-screen bg-[#F2F2F7] dark:bg-[#000000] text-[#1C1C1E] dark:text-[#FFFFFF]">
      {/* Filter Section */}
      <div className={`p-4 bg-white dark:bg-[#1C1C1E] rounded-2xl shadow-[0_0px_12px_rgba(0,0,0,0.05)] dark:shadow-[0_0px_8px_rgba(0,0,0,0.08)]`}>
        <div className="space-y-4">
          {/* Search Bar */}
          <div className="flex items-center h-11 rounded-xl bg-white dark:bg-[#1C1C1E] border border-[#E5E5EA] dark:border-white/8 px-4">
            <MagnifyingGlass size={16} className="text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)] mr-3" />
            <input
              type="text"
              placeholder="Поиск упражнений"
              value={searchText}
              onChange={(e) => setSearchText(e.target.value)}
              className="flex-1 bg-transparent text-sm text-[#1C1C1E] dark:text-[#FFFFFF] placeholder-[#6C6C70] dark:placeholder-[rgba(235,235,245,0.6)] outline-none"
            />
          </div>

          {/* Category Chips */}
          <div className="flex space-x-3 overflow-x-auto pb-2">
            {categories.map(category => (
              <button
                key={category}
                onClick={() => setSelectedCategory(category)}
                className={`flex items-center gap-1.5 px-3 py-2 rounded-lg text-sm font-medium min-w-max whitespace-nowrap ${
                  selectedCategory === category
                    ? 'bg-[#007AFF]/10 text-[#007AFF] dark:bg-[#007AFF]/10 dark:text-[#007AFF]'
                    : 'bg-[#F2F2F7] text-[#6C6C70] dark:bg-[#1C1C1E]/50 dark:text-[rgba(235,235,245,0.6)]'
                }`}
              >
                <Tag size={12} />
                {category}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* List Area */}
      <div className="flex-1 overflow-y-auto px-4 py-2 space-y-3">
        {filteredExercises.length === 0 ? (
          // Empty State Watermark
          <div className="flex flex-col items-center justify-center h-full">
            <Dumbbell size={48} className="text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)] mb-4" />
            <h3 className="text-lg font-medium text-[#1C1C1E] dark:text-[#FFFFFF] mb-2">Упражнения не найдены</h3>
            <p className="text-sm text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)] text-center">Попробуйте изменить поисковый запрос или категорию</p>
          </div>
        ) : (
          // Exercise List
          <div className="space-y-3">
            {filteredExercises.map(exercise => (
              <div
                key={exercise.id}
                className={`p-5 bg-white dark:bg-[#1C1C1E] rounded-2xl shadow-[0_0px_8px_rgba(0,0,0,0.05)] dark:shadow-[0_0px_8px_rgba(0,0,0,0.08)] ${
                  isDark ? 'border border-white/8' : 'border border-[#E5E5EA]/50'
                }`}
              >
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-4">
                    <img src={exercise.image} alt={exercise.name} className="w-15 h-15 rounded-3xl" />
                    <div>
                      <h4 className="text-lg font-semibold text-[#1C1C1E] dark:text-[#FFFFFF]">{exercise.name}</h4>
                      <span className="inline-block px-3 py-1 bg-[#007AFF]/10 text-[#007AFF] text-xs font-medium rounded-lg">
                        {exercise.category}
                      </span>
                    </div>
                  </div>
                  <ChevronRight size={14} className="text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)]" />
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Navigation Toolbar */}
      <div className="flex items-center justify-end p-4 border-t border-[#E5E5EA]/50 dark:border-white/8 bg-white dark:bg-[#000000]">
        <button className="p-2">
          <svg className="w-6 h-6 text-[#007AFF]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
          </svg>
        </button>
      </div>
    </div>
  );
};

export default ExerciseListView;

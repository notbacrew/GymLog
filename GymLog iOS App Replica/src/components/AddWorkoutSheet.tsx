import { X, Plus, Calendar } from 'lucide-react';

interface AddWorkoutSheetProps {
  onClose: () => void;
  isDark: boolean;
}

export function AddWorkoutSheet({ onClose, isDark }: AddWorkoutSheetProps) {
  return (
    <div className="absolute inset-0 z-50 flex items-end">
      {/* Backdrop */}
      <div
        className="absolute inset-0 bg-black/50 backdrop-blur-sm"
        onClick={onClose}
      />
      
      {/* Sheet */}
      <div className="relative w-full bg-white dark:bg-[#1C1C1E] rounded-t-[20px] max-h-[90vh] flex flex-col animate-slide-up">
        {/* Header */}
        <div className="flex items-center justify-between px-5 pt-5 pb-4 border-b border-[#E5E5EA] dark:border-white/[0.08]">
          <h2 className="text-[20px]">Новая тренировка</h2>
          <button
            onClick={onClose}
            className="w-8 h-8 rounded-full bg-[#F2F2F7] dark:bg-black/40 flex items-center justify-center"
          >
            <X size={18} className="text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)]" />
          </button>
        </div>

        {/* Content */}
        <div className="flex-1 overflow-y-auto p-5 space-y-4">
          {/* Workout Name */}
          <div>
            <label className="block text-[14px] text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)] mb-2">
              Название тренировки
            </label>
            <input
              type="text"
              placeholder="Например: Грудь и Трицепс"
              className="w-full h-11 px-4 rounded-xl bg-[#F2F2F7] dark:bg-black/40 border border-[#E5E5EA] dark:border-white/[0.08] text-[#1C1C1E] dark:text-white placeholder:text-[#6C6C70] dark:placeholder:text-[rgba(235,235,245,0.6)] outline-none focus:ring-2 focus:ring-[#007AFF]/20 dark:focus:ring-[#7A7A7C]/20"
            />
          </div>

          {/* Date & Time */}
          <div>
            <label className="block text-[14px] text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)] mb-2">
              Дата и время
            </label>
            <div className="flex items-center gap-3 p-3 rounded-xl bg-[#F2F2F7] dark:bg-black/40 border border-[#E5E5EA] dark:border-white/[0.08]">
              <Calendar size={20} className="text-[#007AFF] dark:text-[#7A7A7C]" />
              <span className="text-[16px]">
                {new Date().toLocaleDateString('ru-RU', {
                  day: 'numeric',
                  month: 'long',
                  year: 'numeric',
                })}
              </span>
            </div>
          </div>

          {/* Intensity */}
          <div>
            <label className="block text-[14px] text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)] mb-2">
              Интенсивность
            </label>
            <div className="bg-[#F2F2F7] dark:bg-black/40 rounded-xl p-1.5 flex gap-1">
              {['Низкая', 'Средняя', 'Высокая'].map((intensity) => (
                <button
                  key={intensity}
                  className="flex-1 h-9 rounded-lg transition-colors bg-white dark:bg-[#1C1C1E] text-[#1C1C1E] dark:text-white"
                >
                  <span className="text-[14px]">{intensity}</span>
                </button>
              ))}
            </div>
          </div>

          {/* Exercises Section */}
          <div>
            <div className="flex items-center justify-between mb-2">
              <label className="text-[14px] text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)]">
                Упражнения
              </label>
              <button className="flex items-center gap-1 text-[#007AFF] dark:text-[#0A84FF]">
                <Plus size={16} />
                <span className="text-[14px]">Добавить</span>
              </button>
            </div>
            <div className="p-8 rounded-xl border-2 border-dashed border-[#E5E5EA] dark:border-white/[0.08] text-center">
              <p className="text-[14px] text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)]">
                Упражнения не добавлены
              </p>
            </div>
          </div>
        </div>

        {/* Footer */}
        <div className="px-5 py-4 border-t border-[#E5E5EA] dark:border-white/[0.08] space-y-2">
          <button className="w-full h-12 rounded-xl bg-[#007AFF] dark:bg-[#7A7A7C] text-white transition-opacity hover:opacity-80">
            Создать тренировку
          </button>
          <button
            onClick={onClose}
            className="w-full h-12 rounded-xl bg-[#F2F2F7] dark:bg-black/40 text-[#1C1C1E] dark:text-white transition-opacity hover:opacity-80"
          >
            Отмена
          </button>
        </div>
      </div>
    </div>
  );
}

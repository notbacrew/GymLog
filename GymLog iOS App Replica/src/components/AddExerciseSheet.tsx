import { X, Upload } from 'lucide-react';

interface AddExerciseSheetProps {
  onClose: () => void;
  isDark: boolean;
}

const categories = ['Грудь', 'Спина', 'Ноги', 'Плечи', 'Руки', 'Пресс', 'Разное'];

export function AddExerciseSheet({ onClose, isDark }: AddExerciseSheetProps) {
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
          <h2 className="text-[20px]">Добавить упражнение</h2>
          <button
            onClick={onClose}
            className="w-8 h-8 rounded-full bg-[#F2F2F7] dark:bg-black/40 flex items-center justify-center"
          >
            <X size={18} className="text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)]" />
          </button>
        </div>

        {/* Content */}
        <div className="flex-1 overflow-y-auto p-5 space-y-4">
          {/* Exercise Name */}
          <div>
            <label className="block text-[14px] text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)] mb-2">
              Название упражнения
            </label>
            <input
              type="text"
              placeholder="Например: Жим штанги лежа"
              className="w-full h-11 px-4 rounded-xl bg-[#F2F2F7] dark:bg-black/40 border border-[#E5E5EA] dark:border-white/[0.08] text-[#1C1C1E] dark:text-white placeholder:text-[#6C6C70] dark:placeholder:text-[rgba(235,235,245,0.6)] outline-none focus:ring-2 focus:ring-[#007AFF]/20 dark:focus:ring-[#7A7A7C]/20"
            />
          </div>

          {/* Category */}
          <div>
            <label className="block text-[14px] text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)] mb-2">
              Группа мышц
            </label>
            <select className="w-full h-11 px-4 rounded-xl bg-[#F2F2F7] dark:bg-black/40 border border-[#E5E5EA] dark:border-white/[0.08] text-[#1C1C1E] dark:text-white outline-none focus:ring-2 focus:ring-[#007AFF]/20 dark:focus:ring-[#7A7A7C]/20">
              <option value="">Выберите группу мышц</option>
              {categories.map((category) => (
                <option key={category} value={category}>
                  {category}
                </option>
              ))}
            </select>
          </div>

          {/* Description */}
          <div>
            <label className="block text-[14px] text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)] mb-2">
              Описание (необязательно)
            </label>
            <textarea
              placeholder="Добавьте описание упражнения..."
              rows={4}
              className="w-full px-4 py-3 rounded-xl bg-[#F2F2F7] dark:bg-black/40 border border-[#E5E5EA] dark:border-white/[0.08] text-[#1C1C1E] dark:text-white placeholder:text-[#6C6C70] dark:placeholder:text-[rgba(235,235,245,0.6)] outline-none focus:ring-2 focus:ring-[#007AFF]/20 dark:focus:ring-[#7A7A7C]/20 resize-none"
            />
          </div>

          {/* Image Upload */}
          <div>
            <label className="block text-[14px] text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)] mb-2">
              Изображение (необязательно)
            </label>
            <div className="p-8 rounded-xl border-2 border-dashed border-[#E5E5EA] dark:border-white/[0.08] text-center cursor-pointer hover:bg-[#F2F2F7] dark:hover:bg-black/20 transition-colors">
              <Upload size={32} className="mx-auto mb-2 text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)]" />
              <p className="text-[14px] text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)]">
                Нажмите для загрузки
              </p>
            </div>
          </div>
        </div>

        {/* Footer */}
        <div className="px-5 py-4 border-t border-[#E5E5EA] dark:border-white/[0.08] space-y-2">
          <button className="w-full h-12 rounded-xl bg-[#007AFF] dark:bg-[#7A7A7C] text-white transition-opacity hover:opacity-80">
            Добавить упражнение
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

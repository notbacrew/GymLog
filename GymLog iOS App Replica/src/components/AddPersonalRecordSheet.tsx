import { X, Calendar, Trash2 } from 'lucide-react';

interface AddPersonalRecordSheetProps {
  onClose: () => void;
  isDark: boolean;
  editMode?: boolean;
  initialData?: any;
}

const exercises = [
  'Жим штанги лежа',
  'Приседания со штангой',
  'Становая тяга',
  'Жим гантелей сидя',
  'Подтягивания',
  'Жим ногами',
  'Разводка гантелей',
];

export function AddPersonalRecordSheet({ 
  onClose, 
  isDark, 
  editMode = false,
  initialData 
}: AddPersonalRecordSheetProps) {
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
          <h2 className="text-[20px]">
            {editMode ? 'Редактировать рекорд' : 'Новый личный рекорд'}
          </h2>
          <button
            onClick={onClose}
            className="w-8 h-8 rounded-full bg-[#F2F2F7] dark:bg-black/40 flex items-center justify-center"
          >
            <X size={18} className="text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)]" />
          </button>
        </div>

        {/* Content */}
        <div className="flex-1 overflow-y-auto p-5 space-y-4">
          {/* Exercise Selection */}
          <div>
            <label className="block text-[14px] text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)] mb-2">
              Упражнение
            </label>
            <select 
              defaultValue={initialData?.exercise || ''}
              className="w-full h-11 px-4 rounded-xl bg-[#F2F2F7] dark:bg-black/40 border border-[#E5E5EA] dark:border-white/[0.08] text-[#1C1C1E] dark:text-white outline-none focus:ring-2 focus:ring-[#007AFF]/20 dark:focus:ring-[#7A7A7C]/20"
            >
              <option value="">Выберите упражнение</option>
              {exercises.map((exercise) => (
                <option key={exercise} value={exercise}>
                  {exercise}
                </option>
              ))}
            </select>
          </div>

          {/* Weight Input */}
          <div>
            <label className="block text-[14px] text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)] mb-2">
              Вес (кг)
            </label>
            <div className="relative">
              <input
                type="number"
                placeholder="0"
                defaultValue={initialData?.weight || ''}
                className="w-full h-11 px-4 pr-12 rounded-xl bg-[#F2F2F7] dark:bg-black/40 border border-[#E5E5EA] dark:border-white/[0.08] text-[#1C1C1E] dark:text-white placeholder:text-[#6C6C70] dark:placeholder:text-[rgba(235,235,245,0.6)] outline-none focus:ring-2 focus:ring-[#007AFF]/20 dark:focus:ring-[#7A7A7C]/20"
              />
              <span className="absolute right-4 top-1/2 -translate-y-1/2 text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)]">
                кг
              </span>
            </div>
          </div>

          {/* Date */}
          <div>
            <label className="block text-[14px] text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)] mb-2">
              Дата
            </label>
            <div className="flex items-center gap-3 p-3 rounded-xl bg-[#F2F2F7] dark:bg-black/40 border border-[#E5E5EA] dark:border-white/[0.08]">
              <Calendar size={20} className="text-[#007AFF] dark:text-[#7A7A7C]" />
              <span className="text-[16px]">
                {initialData?.date 
                  ? new Date(initialData.date).toLocaleDateString('ru-RU', {
                      day: 'numeric',
                      month: 'long',
                      year: 'numeric',
                    })
                  : new Date().toLocaleDateString('ru-RU', {
                      day: 'numeric',
                      month: 'long',
                      year: 'numeric',
                    })
                }
              </span>
            </div>
          </div>

          {/* Notes */}
          <div>
            <label className="block text-[14px] text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)] mb-2">
              Заметки (необязательно)
            </label>
            <textarea
              placeholder="Добавьте заметку о рекорде..."
              defaultValue={initialData?.note || ''}
              rows={4}
              className="w-full px-4 py-3 rounded-xl bg-[#F2F2F7] dark:bg-black/40 border border-[#E5E5EA] dark:border-white/[0.08] text-[#1C1C1E] dark:text-white placeholder:text-[#6C6C70] dark:placeholder:text-[rgba(235,235,245,0.6)] outline-none focus:ring-2 focus:ring-[#007AFF]/20 dark:focus:ring-[#7A7A7C]/20 resize-none"
            />
          </div>

          {/* Delete Section (Edit Mode Only) */}
          {editMode && (
            <div className="pt-4">
              <button className="w-full h-12 rounded-xl bg-[#FF3B30]/10 text-[#FF3B30] flex items-center justify-center gap-2 transition-opacity hover:opacity-80">
                <Trash2 size={18} />
                <span>Удалить рекорд</span>
              </button>
            </div>
          )}
        </div>

        {/* Footer */}
        <div className="px-5 py-4 border-t border-[#E5E5EA] dark:border-white/[0.08] space-y-2">
          <button className="w-full h-12 rounded-xl bg-[#007AFF] dark:bg-[#7A7A7C] text-white transition-opacity hover:opacity-80">
            {editMode ? 'Сохранить изменения' : 'Добавить рекорд'}
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

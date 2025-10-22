import { useState } from 'react';
import { X, Play, Pause } from 'lucide-react';

interface RestTimerSheetProps {
  onClose: () => void;
  isDark: boolean;
}

export function RestTimerSheet({ onClose, isDark }: RestTimerSheetProps) {
  const [isRunning, setIsRunning] = useState(false);
  const [minutes, setMinutes] = useState(1);
  const [seconds, setSeconds] = useState(30);

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
          <h2 className="text-[20px]">Таймер отдыха</h2>
          <button
            onClick={onClose}
            className="w-8 h-8 rounded-full bg-[#F2F2F7] dark:bg-black/40 flex items-center justify-center"
          >
            <X size={18} className="text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)]" />
          </button>
        </div>

        {/* Content */}
        <div className="flex-1 overflow-y-auto p-8 flex flex-col items-center justify-center">
          {/* Timer Display */}
          <div className="relative w-64 h-64 mb-8">
            {/* Progress Ring Background */}
            <svg className="absolute inset-0 w-full h-full -rotate-90">
              <circle
                cx="128"
                cy="128"
                r="112"
                fill="none"
                stroke={isDark ? 'rgba(255,255,255,0.08)' : '#E5E5EA'}
                strokeWidth="8"
              />
              {/* Progress Ring */}
              <circle
                cx="128"
                cy="128"
                r="112"
                fill="none"
                stroke={isDark ? '#7A7A7C' : '#007AFF'}
                strokeWidth="8"
                strokeLinecap="round"
                strokeDasharray={`${2 * Math.PI * 112}`}
                strokeDashoffset={`${2 * Math.PI * 112 * 0.3}`}
                className="transition-all duration-1000"
              />
            </svg>
            
            {/* Time Display */}
            <div className="absolute inset-0 flex flex-col items-center justify-center">
              <div className="flex items-baseline gap-1">
                <span className="text-[56px] tabular-nums">
                  {String(minutes).padStart(2, '0')}
                </span>
                <span className="text-[40px] text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)]">:</span>
                <span className="text-[56px] tabular-nums">
                  {String(seconds).padStart(2, '0')}
                </span>
              </div>
            </div>
          </div>

          {/* Time Picker */}
          {!isRunning && (
            <div className="flex items-center gap-4 mb-6">
              <div className="flex flex-col items-center">
                <label className="text-[12px] text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)] mb-2">
                  Минуты
                </label>
                <input
                  type="number"
                  min="0"
                  max="59"
                  value={minutes}
                  onChange={(e) => setMinutes(parseInt(e.target.value) || 0)}
                  className="w-20 h-12 text-center rounded-xl bg-[#F2F2F7] dark:bg-black/40 border border-[#E5E5EA] dark:border-white/[0.08] text-[#1C1C1E] dark:text-white outline-none focus:ring-2 focus:ring-[#007AFF]/20 dark:focus:ring-[#7A7A7C]/20"
                />
              </div>
              
              <span className="text-[24px] text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)] mt-6">:</span>
              
              <div className="flex flex-col items-center">
                <label className="text-[12px] text-[#6C6C70] dark:text-[rgba(235,235,245,0.6)] mb-2">
                  Секунды
                </label>
                <input
                  type="number"
                  min="0"
                  max="59"
                  value={seconds}
                  onChange={(e) => setSeconds(parseInt(e.target.value) || 0)}
                  className="w-20 h-12 text-center rounded-xl bg-[#F2F2F7] dark:bg-black/40 border border-[#E5E5EA] dark:border-white/[0.08] text-[#1C1C1E] dark:text-white outline-none focus:ring-2 focus:ring-[#007AFF]/20 dark:focus:ring-[#7A7A7C]/20"
                />
              </div>
            </div>
          )}

          {/* Quick Presets */}
          {!isRunning && (
            <div className="flex gap-2 mb-8">
              {[30, 60, 90, 120].map((sec) => (
                <button
                  key={sec}
                  onClick={() => {
                    setMinutes(Math.floor(sec / 60));
                    setSeconds(sec % 60);
                  }}
                  className="px-4 py-2 rounded-lg bg-[#F2F2F7] dark:bg-black/40 text-[14px] hover:bg-[#E5E5EA] dark:hover:bg-black/60 transition-colors"
                >
                  {sec}с
                </button>
              ))}
            </div>
          )}

          {/* Start/Stop Button */}
          <button
            onClick={() => setIsRunning(!isRunning)}
            className="w-20 h-20 rounded-full bg-[#007AFF] dark:bg-[#7A7A7C] flex items-center justify-center shadow-lg hover:opacity-90 transition-opacity"
          >
            {isRunning ? (
              <Pause size={32} className="text-white" fill="white" />
            ) : (
              <Play size={32} className="text-white ml-1" fill="white" />
            )}
          </button>
        </div>

        {/* Footer */}
        <div className="px-5 py-4 border-t border-[#E5E5EA] dark:border-white/[0.08]">
          <button
            onClick={onClose}
            className="w-full h-12 rounded-xl bg-[#F2F2F7] dark:bg-black/40 text-[#1C1C1E] dark:text-white transition-opacity hover:opacity-80"
          >
            Закрыть
          </button>
        </div>
      </div>
    </div>
  );
}

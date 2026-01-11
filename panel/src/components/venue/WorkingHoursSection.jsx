import { useState } from 'react';
import Button from '../common/Button';

const DAYS = [
    { id: 'monday', label: 'Pazartesi' },
    { id: 'tuesday', label: 'Salı' },
    { id: 'wednesday', label: 'Çarşamba' },
    { id: 'thursday', label: 'Perşembe' },
    { id: 'friday', label: 'Cuma' },
    { id: 'saturday', label: 'Cumartesi' },
    { id: 'sunday', label: 'Pazar' },
];

export default function WorkingHoursSection({ value = {}, onChange }) {
    const handleChange = (dayId, field, fieldValue) => {
        const dayData = value[dayId] || { is_open: true, open: '09:00', close: '20:00' };
        onChange({
            ...value,
            [dayId]: { ...dayData, [field]: fieldValue }
        });
    };

    const copyToAll = () => {
        const monday = value.monday || { is_open: true, open: '09:00', close: '20:00' };
        const newValue = {};
        DAYS.forEach(day => {
            newValue[day.id] = { ...monday };
        });
        onChange(newValue);
    };

    return (
        <div className="space-y-10 animate-fade-in">
            <div className="flex justify-between items-center">
                <h3 className="text-2xl font-bold text-secondary">Çalışma Saatleri</h3>
                <button
                    onClick={copyToAll}
                    className="flex items-center gap-2 text-xs font-bold text-primary uppercase tracking-wider hover:opacity-80 transition-opacity"
                >
                    <span className="material-symbols-outlined text-[18px]">content_copy</span>
                    Tüm Günlere Uygula
                </button>
            </div>

            <div className="grid gap-3">
                {DAYS.map((day) => {
                    const dayData = value[day.id] || { is_open: true, open: '09:00', close: '20:00' };

                    return (
                        <div key={day.id} className={`flex items-center gap-6 p-4 px-6 rounded-3xl transition-all duration-300 border ${dayData.is_open ? 'bg-white border-gray-100 shadow-sm' : 'bg-gray-50/50 border-transparent opacity-60'}`}>
                            <div className="w-28 font-bold text-sm text-secondary">{day.label}</div>

                            <label className="relative inline-flex items-center cursor-pointer">
                                <input
                                    type="checkbox"
                                    checked={dayData.is_open}
                                    onChange={(e) => handleChange(day.id, 'is_open', e.target.checked)}
                                    className="sr-only peer"
                                />
                                <div className="w-10 h-6 bg-gray-200 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[4px] after:left-[4px] after:bg-white after:border-transparent after:rounded-full after:h-4 after:w-4 after:transition-all peer-checked:bg-primary"></div>
                                <span className="ml-3 text-[11px] font-bold uppercase tracking-wider text-gray-400 w-12">
                                    {dayData.is_open ? 'Açık' : 'Kapalı'}
                                </span>
                            </label>

                            {dayData.is_open && (
                                <div className="flex items-center gap-3 ml-auto">
                                    <input
                                        type="time"
                                        value={dayData.open}
                                        onChange={(e) => handleChange(day.id, 'open', e.target.value)}
                                        className="px-4 py-2 rounded-xl bg-gray-50 border border-transparent focus:bg-white focus:border-primary/20 outline-none text-xs font-bold transition-all"
                                    />
                                    <span className="text-gray-300 font-light">→</span>
                                    <input
                                        type="time"
                                        value={dayData.close}
                                        onChange={(e) => handleChange(day.id, 'close', e.target.value)}
                                        className="px-4 py-2 rounded-xl bg-gray-50 border border-transparent focus:bg-white focus:border-primary/20 outline-none text-xs font-bold transition-all"
                                    />
                                </div>
                            )}
                        </div>
                    );
                })}
            </div>
        </div>
    );
}

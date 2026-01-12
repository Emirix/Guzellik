import { useState, useEffect } from 'react';
import { serviceService } from '../../services/serviceService';
import Input from '../common/Input';
import Button from '../common/Button';
import LoadingSpinner from '../common/LoadingSpinner';

export default function ServicesSection({ venueId, selectedServices = [], onChange }) {
    const [categories, setCategories] = useState([]);
    const [search, setSearch] = useState('');
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        loadCategories();
    }, []);

    const loadCategories = async () => {
        try {
            const data = await serviceService.getCategories();
            setCategories(data);
        } catch (error) {
            console.error('Error loading categories:', error);
        } finally {
            setLoading(false);
        }
    };

    const toggleService = (service) => {
        const isSelected = selectedServices.find(s => s.service_id === service.id);
        if (isSelected) {
            onChange(selectedServices.filter(s => s.service_id !== service.id));
        } else {
            onChange([...selectedServices, {
                service_id: service.id,
                name: service.name,
                price: 0,
                duration_minutes: service.average_duration_minutes || 30
            }]);
        }
    };

    const updateServiceDetail = (serviceId, field, value) => {
        onChange(selectedServices.map(s =>
            s.service_id === serviceId ? { ...s, [field]: value } : s
        ));
    };

    const filteredCategories = categories.filter(c =>
        c.name.toLowerCase().includes(search.toLowerCase())
    );

    return (
        <div className="space-y-10 animate-fade-in">
            <div className="flex justify-between items-center">
                <h3 className="text-2xl font-bold text-secondary">Hizmetler</h3>
                <div className="w-72">
                    <Input
                        placeholder="Hizmet ara..."
                        value={search}
                        onChange={(e) => setSearch(e.target.value)}
                        className="bg-gray-50/50 border-none"
                    />
                </div>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-12 gap-10">
                {/* Selection Area */}
                <div className="lg:col-span-7 space-y-6">
                    <div className="text-[11px] font-bold text-gray-400 uppercase tracking-[0.2em] px-2">Katalog</div>
                    {loading ? (
                        <div className="flex justify-center p-20"><LoadingSpinner size="lg" /></div>
                    ) : (
                        <div className="grid grid-cols-2 gap-3 max-h-[450px] overflow-y-auto pr-4 scrollbar-thin">
                            {filteredCategories.map(cat => {
                                const isSelected = selectedServices.find(s => s.service_id === cat.id);
                                return (
                                    <button
                                        key={cat.id}
                                        type="button"
                                        onClick={() => toggleService(cat)}
                                        className={`p-5 rounded-[24px] border transition-all duration-300 flex items-center gap-4 text-left ${isSelected
                                            ? 'border-primary bg-primary/5 text-primary shadow-sm shadow-primary/5'
                                            : 'border-gray-100 hover:border-primary/20 bg-white shadow-sm shadow-black/5'
                                            }`}
                                    >
                                        <div className={`w-10 h-10 rounded-xl flex items-center justify-center transition-colors ${isSelected ? 'bg-primary text-white' : 'bg-gray-50 text-gray-400'}`}>
                                            <span className="material-symbols-outlined text-xl">{cat.icon || 'spa'}</span>
                                        </div>
                                        <div className="flex-1 min-w-0">
                                            <div className="font-bold text-sm truncate">{cat.name}</div>
                                        </div>
                                        {isSelected && <span className="material-symbols-outlined text-primary text-[20px] animate-fade-in fill-1">check_circle</span>}
                                    </button>
                                );
                            })}
                        </div>
                    )}
                </div>

                {/* Selected Services Configuration */}
                <div className="lg:col-span-5 space-y-6">
                    <div className="flex justify-between items-center px-2">
                        <div className="text-[11px] font-bold text-gray-400 uppercase tracking-[0.2em]">Seçilenler</div>
                        <span className="text-[10px] font-black bg-primary/10 text-primary px-2 py-0.5 rounded-md">{selectedServices.length}</span>
                    </div>

                    <div className="bg-gray-50/50 rounded-[40px] p-8 border border-gray-100 h-full max-h-[500px] overflow-y-auto scrollbar-thin">
                        {selectedServices.length === 0 ? (
                            <div className="flex flex-col items-center justify-center py-20 text-gray-300">
                                <span className="material-symbols-outlined text-5xl mb-4 font-light">list_alt</span>
                                <p className="text-xs font-bold uppercase tracking-widest text-center leading-loose">Sol taraftan hizmet<br />seçerek başlayın</p>
                            </div>
                        ) : (
                            <div className="grid gap-4">
                                {selectedServices.map(service => (
                                    <div key={service.service_id} className="bg-white p-5 rounded-3xl border border-gray-100 shadow-xl shadow-black/5 animate-fade-in space-y-4">
                                        <div className="flex justify-between items-start gap-4">
                                            <div className="flex items-center gap-3 min-w-0">
                                                <div className="w-8 h-8 rounded-lg bg-primary/5 text-primary flex items-center justify-center shrink-0">
                                                    <span className="material-symbols-outlined text-base">task_alt</span>
                                                </div>
                                                <span className="font-bold text-sm text-secondary truncate">{service.name}</span>
                                            </div>
                                            <button
                                                type="button"
                                                onClick={() => toggleService({ id: service.service_id })}
                                                className="w-8 h-8 rounded-lg bg-gray-50 text-gray-400 hover:bg-red-50 hover:text-red-600 transition-all flex items-center justify-center"
                                            >
                                                <span className="material-symbols-outlined text-[18px]">close</span>
                                            </button>
                                        </div>
                                        <div className="grid grid-cols-2 gap-4">
                                            <div className="space-y-1.5">
                                                <label className="text-[10px] font-bold text-gray-400 uppercase tracking-widest ml-1">Fiyat (TL)</label>
                                                <input
                                                    type="number"
                                                    value={service.price}
                                                    onChange={(e) => updateServiceDetail(service.service_id, 'price', e.target.value)}
                                                    className="w-full px-4 py-2.5 rounded-xl bg-gray-50 border border-transparent focus:bg-white focus:border-primary/20 outline-none text-xs font-bold transition-all"
                                                />
                                            </div>
                                            <div className="space-y-1.5">
                                                <label className="text-[10px] font-bold text-gray-400 uppercase tracking-widest ml-1">Süre (Dk)</label>
                                                <input
                                                    type="number"
                                                    value={service.duration_minutes}
                                                    onChange={(e) => updateServiceDetail(service.service_id, 'duration_minutes', e.target.value)}
                                                    className="w-full px-4 py-2.5 rounded-xl bg-gray-50 border border-transparent focus:bg-white focus:border-primary/20 outline-none text-xs font-bold transition-all"
                                                />
                                            </div>
                                        </div>
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

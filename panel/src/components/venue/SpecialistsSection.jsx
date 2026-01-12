import { useState } from 'react';
import Input from '../common/Input';
import Button from '../common/Button';

export default function SpecialistsSection({ specialists = [], onChange }) {
    const addSpecialist = () => {
        onChange([...specialists, {
            name: '',
            title: '',
            bio: '',
            image_url: ''
        }]);
    };

    const removeSpecialist = (index) => {
        onChange(specialists.filter((_, i) => i !== index));
    };

    const updateSpecialist = (index, field, value) => {
        const newList = [...specialists];
        newList[index] = { ...newList[index], [field]: value };
        onChange(newList);
    };

    return (
        <div className="space-y-10 animate-fade-in">
            <div className="flex justify-between items-end">
                <div>
                    <h3 className="text-2xl font-bold text-secondary">Uzman Kadrosu</h3>
                    <p className="text-gray-400 font-medium mt-2">İşletmenizde çalışan uzmanları ekleyin</p>
                </div>
                <Button variant="secondary" onClick={addSpecialist}>
                    <span className="material-symbols-outlined text-[20px]">person_add</span>
                    Yeni Uzman Ekle
                </Button>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                {specialists.map((specialist, index) => (
                    <div key={index} className="bg-white p-8 rounded-[40px] border border-gray-100 shadow-xl shadow-black/5 relative group animate-fade-in">
                        <button
                            type="button"
                            onClick={() => removeSpecialist(index)}
                            className="absolute top-6 right-6 w-9 h-9 bg-gray-50 text-gray-400 rounded-2xl flex items-center justify-center hover:bg-red-50 hover:text-red-500 transition-all z-10"
                        >
                            <span className="material-symbols-outlined text-[20px]">close</span>
                        </button>

                        <div className="flex gap-8">
                            <div className="w-28 h-28 rounded-[32px] bg-gray-50 flex-shrink-0 flex items-center justify-center overflow-hidden border border-gray-100 relative group-hover:shadow-lg transition-all">
                                {specialist.image_url ? (
                                    <img src={specialist.image_url} alt={specialist.name} className="w-full h-full object-cover" />
                                ) : (
                                    <span className="material-symbols-outlined text-gray-300 text-5xl font-light">person</span>
                                )}
                            </div>

                            <div className="flex-1 space-y-6 pt-2">
                                <Input
                                    label="Ad Soyad"
                                    value={specialist.name}
                                    onChange={(e) => updateSpecialist(index, 'name', e.target.value)}
                                    placeholder="Örn: Dr. Ayşe Yılmaz"
                                    className="!py-3"
                                />
                                <Input
                                    label="Ünvan / Uzmanlık"
                                    value={specialist.title}
                                    onChange={(e) => updateSpecialist(index, 'title', e.target.value)}
                                    placeholder="Örn: Estetisyen"
                                    className="!py-3"
                                />
                            </div>
                        </div>

                        <div className="mt-8 space-y-6">
                            <div className="space-y-2">
                                <label className="text-[11px] font-bold text-gray-400 uppercase tracking-widest ml-1">Biyografi (Opsiyonel)</label>
                                <textarea
                                    value={specialist.bio}
                                    onChange={(e) => updateSpecialist(index, 'bio', e.target.value)}
                                    placeholder="Uzman hakkında kısa bilgi..."
                                    rows={3}
                                    className="w-full px-5 py-4 rounded-3xl bg-gray-50/50 border border-transparent focus:bg-white focus:border-primary/20 outline-none text-sm font-medium text-secondary transition-all"
                                />
                            </div>

                            <Input
                                label="Fotoğraf URL"
                                value={specialist.image_url}
                                onChange={(e) => updateSpecialist(index, 'image_url', e.target.value)}
                                placeholder="https://..."
                            />
                        </div>
                    </div>
                ))}

                {specialists.length === 0 && (
                    <div className="col-span-2 py-32 text-center border-2 border-dashed border-gray-100 rounded-[40px] bg-gray-50/30">
                        <div className="w-20 h-20 bg-white rounded-3xl flex items-center justify-center mx-auto mb-6 shadow-sm">
                            <span className="material-symbols-outlined text-4xl text-gray-200 font-light">badge</span>
                        </div>
                        <p className="text-gray-400 font-bold uppercase tracking-widest text-xs">Henüz uzman eklenmemiş</p>
                    </div>
                )}
            </div>
        </div>
    );
}

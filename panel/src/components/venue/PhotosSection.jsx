import { useState, useRef } from 'react';
import { photoService } from '../../services/photoService';
import Button from '../common/Button';
import LoadingSpinner from '../common/LoadingSpinner';

export default function PhotosSection({ venueId, photos = [], onChange }) {
    const [uploading, setUploading] = useState(false);
    const fileInputRef = useRef(null);
    const [draggedIndex, setDraggedIndex] = useState(null);

    const handleFileChange = async (e) => {
        const files = Array.from(e.target.files);
        if (files.length === 0) return;

        try {
            setUploading(true);
            const newUrls = [];
            for (const file of files) {
                const url = await photoService.uploadPhoto(file, venueId || 'temp');
                newUrls.push({ url, is_hero_image: false, sort_order: photos.length + newUrls.length });
            }
            onChange([...photos, ...newUrls]);
        } catch (error) {
            console.error('Upload error:', error);
        } finally {
            setUploading(false);
        }
    };

    const removePhoto = (index) => {
        onChange(photos.filter((_, i) => i !== index));
    };

    const onDragStart = (e, index) => {
        setDraggedIndex(index);
        e.dataTransfer.effectAllowed = 'move';
    };

    const onDragOver = (e, index) => {
        e.preventDefault();
        if (draggedIndex === index) return;

        const newList = [...photos];
        const draggedItem = newList[draggedIndex];
        newList.splice(draggedIndex, 1);
        newList.splice(index, 0, draggedItem);

        setDraggedIndex(index);
        onChange(newList);
    };

    const onDragEnd = () => {
        setDraggedIndex(null);
    };

    return (
        <div className="space-y-10 animate-fade-in">
            <div className="flex justify-between items-end">
                <div>
                    <h3 className="text-2xl font-bold text-secondary">Fotoğraf Galerisi</h3>
                    <p className="text-gray-400 font-medium mt-2">İlk fotoğraf kapak fotoğrafı olacaktır. Sürükleyerek sıralayabilirsiniz.</p>
                </div>
                <input
                    type="file"
                    multiple
                    accept="image/*"
                    className="hidden"
                    ref={fileInputRef}
                    onChange={handleFileChange}
                />
                <Button
                    variant="secondary"
                    onClick={() => fileInputRef.current.click()}
                    disabled={uploading}
                >
                    {uploading ? <LoadingSpinner size="sm" /> : <span className="material-symbols-outlined text-[20px]">add_a_photo</span>}
                    {uploading ? 'Yükleniyor...' : 'Fotoğraf Yükle'}
                </Button>
            </div>

            <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-5 gap-6">
                {photos.map((photo, index) => (
                    <div
                        key={photo.url || index}
                        draggable
                        onDragStart={(e) => onDragStart(e, index)}
                        onDragOver={(e) => onDragOver(e, index)}
                        onDragEnd={onDragEnd}
                        className={`relative aspect-square rounded-[32px] overflow-hidden border-4 transition-all duration-300 cursor-move group ${index === 0 ? 'border-primary' : 'border-white shadow-sm shadow-black/5 hover:shadow-xl hover:shadow-black/10'
                            }`}
                    >
                        <img src={photo.url} alt="" className="w-full h-full object-cover" />

                        {index === 0 && (
                            <div className="absolute top-4 left-4 bg-primary text-white text-[9px] font-bold px-3 py-1.5 rounded-full uppercase tracking-widest shadow-lg shadow-black/10">
                                Kapak
                            </div>
                        )}

                        <button
                            type="button"
                            onClick={() => removePhoto(index)}
                            className="absolute top-3 right-3 w-9 h-9 bg-white text-red-500 rounded-2xl flex items-center justify-center shadow-xl opacity-0 group-hover:opacity-100 transition-all hover:bg-red-500 hover:text-white transform group-hover:scale-110 z-10"
                        >
                            <span className="material-symbols-outlined text-[20px]">delete</span>
                        </button>

                        <div className="absolute inset-x-0 bottom-0 bg-gradient-to-t from-black/60 to-transparent p-4 opacity-0 group-hover:opacity-100 transition-opacity">
                            <span className="text-[10px] text-white/90 font-bold uppercase tracking-wider">Sıra: {index + 1}</span>
                        </div>
                    </div>
                ))}

                <div
                    onClick={() => fileInputRef.current.click()}
                    className="aspect-square border-2 border-dashed border-gray-100 rounded-[32px] flex flex-col items-center justify-center text-gray-400 hover:border-primary/20 hover:text-primary transition-all duration-300 cursor-pointer bg-gray-50/50 hover:bg-white hover:shadow-xl hover:shadow-primary/5 group"
                >
                    <div className="w-12 h-12 rounded-2xl bg-white flex items-center justify-center mb-3 shadow-sm group-hover:shadow-lg transition-all">
                        <span className="material-symbols-outlined text-3xl">add</span>
                    </div>
                    <span className="text-[10px] font-bold uppercase tracking-widest">Ekle</span>
                </div>
            </div>
        </div>
    );
}

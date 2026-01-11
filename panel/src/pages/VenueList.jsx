import { useState, useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { venueService } from '../services/venueService';
import LoadingSpinner from '../components/common/LoadingSpinner';
import Input from '../components/common/Input';
import Button from '../components/common/Button';
import { useToast } from '../contexts/ToastContext';
import Modal from '../components/common/Modal';

export default function VenueList() {
    const [venues, setVenues] = useState([]);
    const [loading, setLoading] = useState(true);
    const [search, setSearch] = useState('');
    const [page, setPage] = useState(1);
    const [totalCount, setTotalCount] = useState(0);
    const [deleteId, setDeleteId] = useState(null);
    const { showToast } = useToast();
    const navigate = useNavigate();

    useEffect(() => {
        loadVenues();
    }, [search, page]);

    const loadVenues = async () => {
        try {
            setLoading(true);
            const { data, count } = await venueService.getAll({ search, page });
            setVenues(data);
            setTotalCount(count);
        } catch (error) {
            showToast(error.message, 'error');
        } finally {
            setLoading(false);
        }
    };

    const handleDelete = async () => {
        try {
            await venueService.delete(deleteId);
            showToast('İşletme başarıyla silindi');
            setDeleteId(null);
            loadVenues();
        } catch (error) {
            showToast(error.message, 'error');
        }
    };

    const totalPages = Math.ceil(totalCount / 20);

    return (
        <div className="max-w-7xl mx-auto space-y-10 animate-fade-in">
            <div className="flex justify-between items-center">
                <div>
                    <h2 className="text-4xl font-bold text-secondary">İşletmeler</h2>
                    <p className="text-gray-400 font-medium mt-2">Toplam {totalCount} işletme yönetiliyor</p>
                </div>
                <Button onClick={() => navigate('/admin/venues/create')}>
                    <span className="material-symbols-outlined text-[20px]">add</span>
                    Yeni İşletme Ekle
                </Button>
            </div>

            <div className="glass-card rounded-[40px] p-10">
                <div className="mb-10">
                    <div className="max-w-md">
                        <Input
                            placeholder="İşletme ara..."
                            value={search}
                            onChange={(e) => {
                                setSearch(e.target.value);
                                setPage(1);
                            }}
                            className="bg-gray-50/50 border-none px-6"
                        />
                    </div>
                </div>

                {loading ? (
                    <div className="flex justify-center py-32">
                        <LoadingSpinner size="lg" />
                    </div>
                ) : venues.length === 0 ? (
                    <div className="text-center py-32">
                        <div className="w-20 h-20 bg-gray-50 rounded-[32px] flex items-center justify-center mx-auto mb-6">
                            <span className="material-symbols-outlined text-4xl text-gray-300">search_off</span>
                        </div>
                        <p className="text-gray-400 font-semibold">Aradığınız kriterde işletme bulunamadı</p>
                    </div>
                ) : (
                    <>
                        <div className="overflow-x-auto">
                            <table className="w-full">
                                <thead>
                                    <tr className="text-left">
                                        <th className="pb-6 px-4 text-[11px] font-bold text-gray-400 uppercase tracking-[0.2em]">İşletme Detayı</th>
                                        <th className="pb-6 px-4 text-[11px] font-bold text-gray-400 uppercase tracking-[0.2em]">Kategori</th>
                                        <th className="pb-6 px-4 text-[11px] font-bold text-gray-400 uppercase tracking-[0.2em]">Konum</th>
                                        <th className="pb-6 px-4 text-[11px] font-bold text-gray-400 uppercase tracking-[0.2em]">Durum</th>
                                        <th className="pb-6 px-4 text-[11px] font-bold text-gray-400 uppercase tracking-[0.2em] text-right">İşlemler</th>
                                    </tr>
                                </thead>
                                <tbody className="divide-y divide-gray-50/50">
                                    {venues.map((venue) => (
                                        <tr key={venue.id} className="hover:bg-gray-50/30 transition-all duration-300 group">
                                            <td className="py-7 px-4">
                                                <div className="font-bold text-secondary text-base">{venue.name}</div>
                                                <div className="text-xs text-gray-400 mt-0.5 font-medium">{venue.phone || 'Telefon belirtilmemiş'}</div>
                                            </td>
                                            <td className="py-7 px-4">
                                                <div className="inline-flex items-center px-4 py-1.5 rounded-full bg-gray-50 text-gray-600 text-xs font-bold uppercase tracking-wider">
                                                    {venue.venue_categories?.name || 'Genel'}
                                                </div>
                                            </td>
                                            <td className="py-7 px-4">
                                                <div className="flex flex-col">
                                                    <span className="text-sm font-semibold text-gray-600">{venue.districts?.name}</span>
                                                    <span className="text-[10px] text-gray-400 font-bold uppercase tracking-widest">{venue.provinces?.name}</span>
                                                </div>
                                            </td>
                                            <td className="py-7 px-4">
                                                {venue.is_verified ? (
                                                    <div className="flex items-center gap-2 text-green-600">
                                                        <span className="material-symbols-outlined text-[18px] fill-1">verified</span>
                                                        <span className="text-xs font-bold uppercase tracking-wider">Doğrulandı</span>
                                                    </div>
                                                ) : (
                                                    <div className="flex items-center gap-2 text-amber-500">
                                                        <span className="material-symbols-outlined text-[18px]">pending</span>
                                                        <span className="text-xs font-bold uppercase tracking-wider">Beklemede</span>
                                                    </div>
                                                )}
                                            </td>
                                            <td className="py-7 px-4 text-right">
                                                <div className="flex justify-end gap-3 opacity-0 group-hover:opacity-100 transition-all duration-300 translate-x-4 group-hover:translate-x-0">
                                                    <button
                                                        onClick={() => navigate(`/admin/venues/${venue.id}/edit`)}
                                                        className="w-11 h-11 rounded-2xl bg-white border border-gray-100 text-gray-400 flex items-center justify-center hover:border-primary hover:text-primary transition-all shadow-sm"
                                                    >
                                                        <span className="material-symbols-outlined text-[18px]">edit</span>
                                                    </button>
                                                    <button
                                                        onClick={() => setDeleteId(venue.id)}
                                                        className="w-11 h-11 rounded-2xl bg-white border border-gray-100 text-gray-400 flex items-center justify-center hover:border-red-500 hover:text-red-500 transition-all shadow-sm"
                                                    >
                                                        <span className="material-symbols-outlined text-[18px]">delete</span>
                                                    </button>
                                                </div>
                                            </td>
                                        </tr>
                                    ))}
                                </tbody>
                            </table>
                        </div>

                        {totalPages > 1 && (
                            <div className="flex justify-between items-center mt-12 pt-8 border-t border-gray-50">
                                <p className="text-sm font-semibold text-gray-400">
                                    Sayfa <span className="text-secondary">{page}</span> / {totalPages}
                                </p>
                                <div className="flex gap-2">
                                    <button
                                        onClick={() => setPage(p => Math.max(1, p - 1))}
                                        disabled={page === 1}
                                        className="w-12 h-12 rounded-2xl bg-white border border-gray-100 flex items-center justify-center disabled:opacity-30 disabled:cursor-not-allowed hover:border-primary transition-all shadow-sm"
                                    >
                                        <span className="material-symbols-outlined text-[20px]">chevron_left</span>
                                    </button>
                                    <button
                                        onClick={() => setPage(p => Math.min(totalPages, p + 1))}
                                        disabled={page === totalPages}
                                        className="w-12 h-12 rounded-2xl bg-white border border-gray-100 flex items-center justify-center disabled:opacity-30 disabled:cursor-not-allowed hover:border-primary transition-all shadow-sm"
                                    >
                                        <span className="material-symbols-outlined text-[20px]">chevron_right</span>
                                    </button>
                                </div>
                            </div>
                        )}
                    </>
                )}
            </div>

            <Modal
                isOpen={!!deleteId}
                onClose={() => setDeleteId(null)}
                onConfirm={handleDelete}
                title="İşletmeyi Sil"
                confirmText="Evet, Kalıcı Olarak Sil"
                type="danger"
            >
                Bu işletmeyi ve tüm ilişkili verilerini silmek üzeresiniz. Bu işlem <span className="text-red-600 font-bold">geri alınamaz</span>.
            </Modal>
        </div>
    );
}

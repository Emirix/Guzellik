import { Calendar } from 'lucide-react';

export default function Appointments() {
    return (
        <div className="animate-fade-in">
            <div className="page-header">
                <h2 className="text-xl font-bold">Randevular</h2>
                <div className="flex gap-2">
                    <button className="btn btn-outline text-sm">Takvim Görünümü</button>
                    <button className="btn btn-primary text-sm">Yeni Randevu</button>
                </div>
            </div>

            <div className="card text-center py-12">
                <div className="w-16 h-16 bg-primary-light rounded-full flex items-center justify-center mx-auto mb-4 text-primary">
                    <Calendar size={32} />
                </div>
                <h3 className="text-lg font-semibold mb-2">Randevu Takvimi</h3>
                <p className="text-gray-500 mb-6">
                    Burada yaklaşan randevularınızı görüntüleyebilir ve yönetebilirsiniz.
                </p>
                <div className="badge badge-warning">YAKINDA</div>
            </div>
        </div>
    );
}

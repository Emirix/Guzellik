import { Bell } from 'lucide-react';

export default function Notifications() {
    return (
        <div className="animate-fade-in">
            <div className="page-header">
                <h2 className="text-xl font-bold">Bildirimler</h2>
                <button className="btn btn-primary">
                    <Bell size={18} />
                    <span>Bildirim Gönder</span>
                </button>
            </div>

            <div className="card text-center py-12">
                <div className="w-16 h-16 bg-primary-light rounded-full flex items-center justify-center mx-auto mb-4 text-primary">
                    <Bell size={32} />
                </div>
                <h3 className="text-lg font-semibold mb-2">Müşterilerinize Ulaşın</h3>
                <p className="text-gray-500 mb-6">
                    Takipçilerinize özel bildirimler ve duyurular gönderin.
                </p>
                <div className="badge badge-warning">YAKINDA</div>
            </div>
        </div>
    );
}

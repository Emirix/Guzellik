import { Users } from 'lucide-react';

export default function Specialists() {
    return (
        <div className="animate-fade-in">
            <div className="page-header">
                <h2 className="text-xl font-bold">Uzman Ekibi</h2>
                <button className="btn btn-primary">
                    <Users size={18} />
                    <span>Uzman Ekle</span>
                </button>
            </div>

            <div className="card text-center py-12">
                <div className="w-16 h-16 bg-primary-light rounded-full flex items-center justify-center mx-auto mb-4 text-primary">
                    <Users size={32} />
                </div>
                <h3 className="text-lg font-semibold mb-2">Ekibinizi Yönetin</h3>
                <p className="text-gray-500 mb-6">
                    Uzmanlarınızı ekleyin, profillerini düzenleyin ve hizmetlerini yönetin.
                </p>
                <div className="badge badge-warning">YAKINDA</div>
            </div>
        </div>
    );
}

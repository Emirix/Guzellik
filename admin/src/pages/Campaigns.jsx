import { Tag } from 'lucide-react';

export default function Campaigns() {
    return (
        <div className="animate-fade-in">
            <div className="page-header">
                <h2 className="text-xl font-bold">Kampanyalar</h2>
                <button className="btn btn-primary">
                    <Tag size={18} />
                    <span>Yeni Kampanya</span>
                </button>
            </div>

            <div className="card text-center py-12">
                <div className="w-16 h-16 bg-primary-light rounded-full flex items-center justify-center mx-auto mb-4 text-primary">
                    <Tag size={32} />
                </div>
                <h3 className="text-lg font-semibold mb-2">Henüz Kampanya Yok</h3>
                <p className="text-gray-500 mb-6 max-w-md mx-auto">
                    Müşterilerinizi çekmek için özel fırsatlar ve kampanyalar oluşturmaya başlayın.
                </p>
                <button className="btn btn-primary">İlk Kampanyayı Oluştur</button>
            </div>
        </div>
    );
}

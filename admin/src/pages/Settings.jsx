import { Settings as SettingsIcon } from 'lucide-react';

export default function Settings() {
    return (
        <div className="animate-fade-in">
            <div className="page-header">
                <h2 className="text-xl font-bold">Ayarlar</h2>
            </div>

            <div className="card text-center py-12">
                <div className="w-16 h-16 bg-primary-light rounded-full flex items-center justify-center mx-auto mb-4 text-primary">
                    <SettingsIcon size={32} />
                </div>
                <h3 className="text-lg font-semibold mb-2">İşletme Ayarları</h3>
                <p className="text-gray-500 mb-6">
                    İşletme bilgilerinizi, çalışma saatlerinizi ve diğer ayarlarınızı buradan yönetin.
                </p>
                <div className="badge badge-warning">YAKINDA</div>
            </div>
        </div>
    );
}

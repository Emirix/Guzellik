import { Image } from 'lucide-react';

export default function Gallery() {
    return (
        <div className="animate-fade-in">
            <div className="page-header">
                <h2 className="text-xl font-bold">Galeri</h2>
                <button className="btn btn-primary">
                    <Image size={18} />
                    <span>Fotoğraf Yükle</span>
                </button>
            </div>

            <div className="card text-center py-12">
                <div className="w-16 h-16 bg-primary-light rounded-full flex items-center justify-center mx-auto mb-4 text-primary">
                    <Image size={32} />
                </div>
                <h3 className="text-lg font-semibold mb-2">Mekan Fotoğrafları</h3>
                <p className="text-gray-500 mb-6">
                    İşletmenizin fotoğraflarını yükleyin ve müşterilerinize gösterin.
                </p>
                <div className="badge badge-warning">YAKINDA</div>
            </div>
        </div>
    );
}

import { Link, useLocation } from 'react-router-dom';

export default function Sidebar() {
    const location = useLocation();

    const navItems = [
        { path: '/admin/venues', label: 'İşletmeler', icon: 'storefront' },
        { path: '/admin/venues/create', label: 'Yeni İşletme', icon: 'add_circle' },
    ];

    const isActive = (path) => location.pathname === path;

    return (
        <aside className="w-64 bg-white border-r border-gray-100 p-6 flex flex-col gap-10 min-h-screen">
            <div className="flex items-center gap-3 px-2">
                <div className="w-10 h-10 bg-primary rounded-2xl flex items-center justify-center shadow-lg shadow-primary/20">
                    <span className="material-symbols-outlined text-white font-light">bolt</span>
                </div>
                <h1 className="text-xl font-bold tracking-tight text-secondary">Güzellik</h1>
            </div>

            <nav className="flex-1 flex flex-col gap-1">
                <div className="text-[10px] font-bold text-gray-400 uppercase tracking-widest mb-4 px-4">Yönetim</div>
                {navItems.map((item) => (
                    <Link
                        key={item.path}
                        to={item.path}
                        className={`flex items-center gap-3 px-4 py-3.5 rounded-2xl transition-all duration-300 ${isActive(item.path)
                            ? 'bg-primary/5 text-primary shadow-sm shadow-primary/5'
                            : 'text-gray-500 hover:bg-gray-50 hover:text-gray-900'
                            }`}
                    >
                        <span className={`material-symbols-outlined ${isActive(item.path) ? 'fill-1' : 'font-light'}`}>
                            {item.icon}
                        </span>
                        <span className="font-semibold text-sm">{item.label}</span>
                    </Link>
                ))}
            </nav>

            <div className="p-4 bg-gray-50 rounded-3xl border border-gray-100">
                <p className="text-xs font-semibold text-gray-600 mb-2">Destek</p>
                <p className="text-[10px] text-gray-400 leading-relaxed uppercase font-bold tracking-tighter">
                    Herhangi bir sorun yaşarsanız bizimle iletişime geçebilirsiniz.
                </p>
            </div>
        </aside>
    );
}

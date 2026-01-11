import { NavLink } from 'react-router-dom';
import {
    LayoutDashboard,
    Tag,
    Calendar,
    Users,
    Image,
    Bell,
    Settings,
    LogOut
} from 'lucide-react';
import './Sidebar.css';

const menuItems = [
    { path: '/dashboard', icon: LayoutDashboard, label: 'Dashboard' },
    { path: '/campaigns', icon: Tag, label: 'Kampanyalar' },
    { path: '/appointments', icon: Calendar, label: 'Randevular' },
    { path: '/specialists', icon: Users, label: 'Uzmanlar' },
    { path: '/gallery', icon: Image, label: 'Galeri' },
    { path: '/notifications', icon: Bell, label: 'Bildirimler' },
    { path: '/settings', icon: Settings, label: 'Ayarlar' },
];

export default function Sidebar({ isOpen, onClose, onLogout }) {
    return (
        <>
            {/* Overlay for mobile */}
            {isOpen && (
                <div className="sidebar-overlay" onClick={onClose}></div>
            )}

            {/* Sidebar */}
            <aside className={`sidebar ${isOpen ? 'sidebar-open' : ''}`}>
                {/* Logo */}
                <div className="sidebar-header">
                    <div className="sidebar-logo">
                        <div className="logo-icon">
                            <svg width="32" height="32" viewBox="0 0 32 32" fill="none">
                                <circle cx="16" cy="16" r="16" fill="url(#gradient)" />
                                <path d="M16 8L20 14H12L16 8Z" fill="white" />
                                <path d="M16 24L12 18H20L16 24Z" fill="white" />
                                <defs>
                                    <linearGradient id="gradient" x1="0" y1="0" x2="32" y2="32">
                                        <stop offset="0%" stopColor="#EE2B5B" />
                                        <stop offset="100%" stopColor="#D4316D" />
                                    </linearGradient>
                                </defs>
                            </svg>
                        </div>
                        <span className="logo-text">Güzellik Haritam</span>
                    </div>
                </div>

                {/* Navigation */}
                <nav className="sidebar-nav">
                    {menuItems.map((item) => {
                        const Icon = item.icon;
                        return (
                            <NavLink
                                key={item.path}
                                to={item.path}
                                className={({ isActive }) =>
                                    `sidebar-link ${isActive ? 'sidebar-link-active' : ''}`
                                }
                                onClick={() => {
                                    if (window.innerWidth < 768) {
                                        onClose();
                                    }
                                }}
                            >
                                <Icon size={20} />
                                <span>{item.label}</span>
                            </NavLink>
                        );
                    })}
                </nav>

                {/* Logout Button */}
                <div className="sidebar-footer">
                    <button className="sidebar-logout" onClick={onLogout}>
                        <LogOut size={20} />
                        <span>Çıkış Yap</span>
                    </button>
                </div>
            </aside>
        </>
    );
}

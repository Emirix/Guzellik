import { Menu, Bell, User } from 'lucide-react';
import './Header.css';

export default function Header({ onMenuClick, user, venueName }) {
    return (
        <header className="header">
            <div className="header-left">
                <button className="menu-button" onClick={onMenuClick}>
                    <Menu size={24} />
                </button>
                <div className="header-title">
                    <h1>{venueName || 'Admin Panel'}</h1>
                    <p className="header-subtitle">Yönetim Paneli</p>
                </div>
            </div>

            <div className="header-right">
                <button className="header-icon-button">
                    <Bell size={20} />
                    <span className="notification-badge">3</span>
                </button>

                <div className="header-user">
                    <div className="user-avatar">
                        <User size={20} />
                    </div>
                    <div className="user-info">
                        <p className="user-name">{user?.email || 'Admin'}</p>
                        <p className="user-role">İşletme Sahibi</p>
                    </div>
                </div>
            </div>
        </header>
    );
}

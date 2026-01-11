import {
    Users,
    Calendar,
    Star,
    TrendingUp,
    ArrowUpRight,
    ArrowDownRight
} from 'lucide-react';
import './Dashboard.css';

const StatCard = ({ title, value, change, icon: Icon, trend }) => (
    <div className="card stat-card">
        <div className="stat-header">
            <div className={`stat-icon ${trend === 'up' ? 'bg-success-light' : 'bg-primary-light'}`}>
                <Icon size={24} className={trend === 'up' ? 'text-success' : 'text-primary'} />
            </div>
            {change && (
                <div className={`stat-change ${trend === 'up' ? 'text-success' : 'text-error'}`}>
                    {trend === 'up' ? <ArrowUpRight size={16} /> : <ArrowDownRight size={16} />}
                    <span>{change}</span>
                </div>
            )}
        </div>
        <div className="stat-content">
            <h3 className="stat-value">{value}</h3>
            <p className="stat-title">{title}</p>
        </div>
    </div>
);

export default function Dashboard() {
    return (
        <div className="dashboard animate-fade-in">
            <div className="page-header">
                <h2 className="text-xl font-bold">Genel Bakış</h2>
                <div className="date-filter">
                    <select className="form-select text-sm">
                        <option>Bu Hafta</option>
                        <option>Bu Ay</option>
                        <option>Bu Yıl</option>
                    </select>
                </div>
            </div>

            {/* Stats Grid */}
            <div className="grid grid-cols-4 gap-6 mb-6">
                <StatCard
                    title="Toplam Randevu"
                    value="124"
                    change="+12.5%"
                    trend="up"
                    icon={Calendar}
                />
                <StatCard
                    title="Yeni Müşteriler"
                    value="48"
                    change="+8.2%"
                    trend="up"
                    icon={Users}
                />
                <StatCard
                    title="Ortalama Puan"
                    value="4.8"
                    change="+0.1"
                    trend="up"
                    icon={Star}
                />
                <StatCard
                    title="Gelir"
                    value="₺45.2K"
                    change="-2.4%"
                    trend="down"
                    icon={TrendingUp}
                />
            </div>

            <div className="grid grid-cols-2 gap-6">
                {/* Recent Appointments */}
                <div className="card">
                    <div className="card-header flex justify-between items-center">
                        <h3 className="card-title">Son Randevular</h3>
                        <button className="btn btn-outline text-sm py-1 px-3">Tümünü Gör</button>
                    </div>
                    <div className="appointments-list">
                        {[1, 2, 3, 4, 5].map((item) => (
                            <div key={item} className="appointment-item">
                                <div className="appointment-avatar">
                                    {/* Avatar Placeholder */}
                                    <span className="text-xs font-bold">AB</span>
                                </div>
                                <div className="appointment-info">
                                    <p className="font-semibold text-sm">Ayşe Yılmaz</p>
                                    <p className="text-xs text-gray">Saç Kesimi • 14:30</p>
                                </div>
                                <span className="badge badge-success">Onaylandı</span>
                            </div>
                        ))}
                    </div>
                </div>

                {/* Recent Reviews */}
                <div className="card">
                    <div className="card-header flex justify-between items-center">
                        <h3 className="card-title">Son Değerlendirmeler</h3>
                        <button className="btn btn-outline text-sm py-1 px-3">Tümünü Gör</button>
                    </div>
                    <div className="reviews-list">
                        {[1, 2, 3].map((item) => (
                            <div key={item} className="review-item">
                                <div className="review-header flex justify-between mb-2">
                                    <div className="flex items-center gap-2">
                                        <div className="review-avatar">
                                            <span className="text-xs font-bold">MK</span>
                                        </div>
                                        <span className="font-semibold text-sm">Mehmet K.</span>
                                    </div>
                                    <div className="flex items-center text-warning">
                                        <Star size={14} fill="currentColor" />
                                        <span className="text-xs ml-1 font-bold">5.0</span>
                                    </div>
                                </div>
                                <p className="text-sm text-gray-700">
                                    Harika bir deneyimdi, personel çok ilgiliydi. Kesinlikle tavsiye ederim.
                                </p>
                                <p className="text-xs text-gray-400 mt-2">2 saat önce</p>
                            </div>
                        ))}
                    </div>
                </div>
            </div>
        </div>
    );
}

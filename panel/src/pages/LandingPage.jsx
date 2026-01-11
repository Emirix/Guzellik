import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import {
    FiMapPin,
    FiCheckCircle,
    FiMessageSquare,
    FiBell,
    FiMenu,
    FiX,
    FiArrowRight,
    FiStar,
    FiUsers,
    FiHome
} from 'react-icons/fi';
import mockupImg from '../assets/mockup.png';

const LandingPage = () => {
    const [isScrolled, setIsScrolled] = useState(false);
    const [isMenuOpen, setIsMenuOpen] = useState(false);

    useEffect(() => {
        const handleScroll = () => {
            setIsScrolled(window.scrollY > 50);
        };
        window.addEventListener('scroll', handleScroll);
        return () => window.removeEventListener('scroll', handleScroll);
    }, []);

    const stats = [
        { label: 'Kayıtlı Salon', value: '1,200+', icon: <FiHome /> },
        { label: 'Hizmet Verilen İl', value: '81', icon: <FiMapPin /> },
        { label: 'Mutlu Kullanıcı', value: '50,000+', icon: <FiUsers /> },
        { label: 'Ortalama Puan', value: '4.9', icon: <FiStar /> },
    ];

    const features = [
        {
            title: 'Konum Bazlı Keşif',
            description: 'Harita üzerinden size en yakın ve en iyi puanlanmış salonları saniyeler içinde bulun.',
            icon: <FiMapPin className="text-primary text-2xl" />,
        },
        {
            title: 'Onaylı Mekanlar',
            description: 'Sadece doğrulanmış ve kalite standartlarımıza uygun salonlarla güvenle randevu alın.',
            icon: <FiCheckCircle className="text-primary text-2xl" />,
        },
        {
            title: 'Doğrudan İletişim',
            description: 'Salonlarla anlık mesajlaşın, sorularınızı sorun ve detaylı bilgi alın.',
            icon: <FiMessageSquare className="text-primary text-2xl" />,
        },
        {
            title: 'Anlık Bildirimler',
            description: 'Takip ettiğiniz salonların kampanyalarından ve duyurularından ilk siz haberdar olun.',
            icon: <FiBell className="text-primary text-2xl" />,
        },
    ];

    return (
        <div className="min-h-screen bg-background text-secondary font-sans selection:bg-primary/20">
            {/* Navigation */}
            <nav className={`fixed w-full z-50 transition-all duration-300 ${isScrolled ? 'bg-white/80 backdrop-blur-md shadow-sm py-4' : 'bg-transparent py-6'}`}>
                <div className="container mx-auto px-6 flex justify-between items-center">
                    <div className="flex items-center gap-2">
                        <div className="w-10 h-10 bg-primary rounded-xl flex items-center justify-center shadow-lg shadow-primary/20">
                            <span className="text-white font-bold text-xl">G</span>
                        </div>
                        <span className="text-2xl font-bold tracking-tight">Güzellik</span>
                    </div>

                    {/* Desktop Menu */}
                    <div className="hidden md:flex items-center gap-8">
                        <a href="#hero" className="font-medium hover:text-primary transition-colors">Ana Sayfa</a>
                        <a href="#features" className="font-medium hover:text-primary transition-colors">Özellikler</a>
                        <a href="#about" className="font-medium hover:text-primary transition-colors">Hakkımızda</a>
                        <Link to="/admin" className="btn-primary px-6 py-2.5 rounded-full text-white font-semibold flex items-center gap-2">
                            Panel Girişi <FiArrowRight />
                        </Link>
                    </div>

                    {/* Mobile Menu Toggle */}
                    <button className="md:hidden text-2xl" onClick={() => setIsMenuOpen(!isMenuOpen)}>
                        {isMenuOpen ? <FiX /> : <FiMenu />}
                    </button>
                </div>

                {/* Mobile Menu */}
                {isMenuOpen && (
                    <div className="md:hidden absolute top-full left-0 w-full bg-white border-t p-6 flex flex-col gap-4 shadow-xl animate-fade-in-down">
                        <a href="#hero" onClick={() => setIsMenuOpen(false)} className="font-medium py-2">Ana Sayfa</a>
                        <a href="#features" onClick={() => setIsMenuOpen(false)} className="font-medium py-2">Özellikler</a>
                        <a href="#about" onClick={() => setIsMenuOpen(false)} className="font-medium py-2">Hakkımızda</a>
                        <Link to="/admin" className="btn-primary px-6 py-3 rounded-xl text-white font-semibold flex items-center justify-center gap-2">
                            Panel Girişi <FiArrowRight />
                        </Link>
                    </div>
                )}
            </nav>

            {/* Hero Section */}
            <section id="hero" className="relative pt-32 pb-20 md:pt-48 md:pb-32 overflow-hidden">
                <div className="absolute top-0 right-0 w-1/2 h-full bg-gradient-to-l from-primary/5 to-transparent -z-10 rounded-l-[100px]" />
                <div className="container mx-auto px-6 flex flex-col md:flex-row items-center gap-16">
                    <div className="flex-1 space-y-8 text-center md:text-left">
                        <div className="inline-flex items-center gap-2 px-4 py-2 bg-primary/10 text-primary rounded-full text-sm font-semibold animate-bounce-slow">
                            <FiStar className="fill-primary" /> Yeni Nesil Güzellik Deneyimi
                        </div>
                        <h1 className="text-5xl md:text-7xl font-bold leading-tight">
                            Güzelliğin <br />
                            <span className="text-primary italic">Dijital Adresi</span>
                        </h1>
                        <p className="text-lg text-secondary/70 max-w-xl mx-auto md:mx-0 leading-relaxed">
                            Türkiye'nin en seçkin güzellik salonlarını tek bir platformda keşfedin.
                            Size en yakın uzmanları bulun, randevunuzu saniyeler içinde planlayın.
                        </p>
                        <div className="flex flex-col sm:flex-row items-center justify-center md:justify-start gap-4">
                            <button className="btn-primary w-full sm:w-auto px-8 py-4 rounded-2xl text-white font-bold text-lg shadow-xl shadow-primary/30 hover:scale-105 transition-all">
                                Hemen Keşfet
                            </button>
                            <button className="w-full sm:w-auto px-8 py-4 rounded-2xl border-2 border-primary/20 font-bold text-lg hover:bg-primary/5 transition-all">
                                Nasıl Çalışır?
                            </button>
                        </div>
                    </div>
                    <div className="flex-1 relative animate-float">
                        <div className="relative z-10 w-full max-w-md mx-auto aspect-[9/16] rounded-[40px] overflow-hidden shadow-2xl border-8 border-white">
                            <img src={mockupImg} alt="App Mockup" className="w-full h-full object-cover" />
                        </div>
                        {/* Floating Elements */}
                        <div className="absolute -top-6 -right-6 bg-white p-4 rounded-2xl shadow-xl border border-gray-100 flex items-center gap-3 animate-float-delayed">
                            <div className="w-10 h-10 bg-green-500/10 text-green-500 rounded-lg flex items-center justify-center">
                                <FiCheckCircle />
                            </div>
                            <div>
                                <p className="text-xs text-gray-400 font-medium">Uzman Onaylı</p>
                                <p className="font-bold">Güvenli Randevu</p>
                            </div>
                        </div>
                        <div className="absolute top-1/2 -left-12 bg-white p-4 rounded-2xl shadow-xl border border-gray-100 flex items-center gap-3 animate-float">
                            <div className="w-10 h-10 bg-accent/10 text-accent rounded-lg flex items-center justify-center text-xl">
                                🏆
                            </div>
                            <div>
                                <p className="text-xs text-gray-400 font-medium">En Çok Tercih Edilen</p>
                                <p className="font-bold">Premium Salonlar</p>
                            </div>
                        </div>
                        <div className="absolute bottom-10 -right-10 w-32 h-32 bg-primary/10 rounded-full blur-3xl -z-10" />
                        <div className="absolute top-10 -left-10 w-32 h-32 bg-accent/10 rounded-full blur-3xl -z-10" />
                    </div>
                </div>
            </section>

            {/* Stats Section */}
            <section className="py-20 bg-secondary text-white relative overflow-hidden">
                <div className="absolute inset-0 opacity-10 pointer-events-none">
                    <div className="absolute top-0 left-0 w-full h-full bg-[radial-gradient(circle_at_20%_30%,#ec3c68_0%,transparent_50%)]" />
                </div>
                <div className="container mx-auto px-6">
                    <div className="grid grid-cols-2 md:grid-cols-4 gap-12 text-center">
                        {stats.map((stat, idx) => (
                            <div key={idx} className="space-y-2 group">
                                <div className="text-primary text-3xl mb-4 flex justify-center group-hover:scale-110 transition-transform">
                                    {stat.icon}
                                </div>
                                <h3 className="text-4xl font-extrabold">{stat.value}</h3>
                                <p className="text-gray-400 font-medium uppercase tracking-widest text-xs">{stat.label}</p>
                            </div>
                        ))}
                    </div>
                </div>
            </section>

            {/* Features Section */}
            <section id="features" className="py-32">
                <div className="container mx-auto px-6">
                    <div className="text-center max-w-2xl mx-auto mb-20 space-y-4">
                        <h2 className="text-primary font-bold tracking-widest uppercase text-sm">Neden Biz?</h2>
                        <h3 className="text-4xl md:text-5xl font-bold">Güzellik Süreçlerinizi <span className="text-primary">Kolaylaştırıyoruz</span></h3>
                        <p className="text-secondary/60 leading-relaxed text-lg">
                            Hem kullanıcılar hem de salon sahipleri için tasarlanmış en kapsamlı dijital çözümler.
                        </p>
                    </div>
                    <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
                        {features.map((feature, idx) => (
                            <div key={idx} className="glass-card p-10 rounded-[32px] hover:bg-white hover:shadow-2xl transition-all duration-500 group border-transparent hover:border-primary/10">
                                <div className="w-16 h-16 bg-primary/10 rounded-2xl flex items-center justify-center mb-8 group-hover:bg-primary group-hover:text-white transition-colors duration-500">
                                    {feature.icon}
                                </div>
                                <h4 className="text-xl font-bold mb-4">{feature.title}</h4>
                                <p className="text-secondary/60 leading-relaxed">{feature.description}</p>
                            </div>
                        ))}
                    </div>
                </div>
            </section>

            {/* About / CTA Section */}
            <section id="about" className="py-20">
                <div className="container mx-auto px-6">
                    <div className="bg-gradient-to-br from-primary to-primary-hover rounded-[50px] p-12 md:p-20 text-white relative overflow-hidden shadow-2xl shadow-primary/40">
                        <div className="absolute top-0 right-0 w-1/3 h-full bg-white/5 skew-x-12 -mr-20" />
                        <div className="max-w-3xl relative z-10 space-y-8">
                            <h2 className="text-4xl md:text-6xl font-bold leading-tight">İşletmenizi Dijital Dünyaya Taşıyın</h2>
                            <p className="text-white/80 text-lg md:text-xl leading-relaxed">
                                Salonunuzu sisteme kaydedin, binlerce yeni kullanıcıya ulaşın ve
                                müşteri ilişkilerinizi profesyonelce yönetin.
                            </p>
                            <div className="flex flex-col sm:flex-row gap-4 pt-4">
                                <button className="bg-white text-primary px-10 py-4 rounded-2xl font-bold text-lg hover:scale-105 transition-all shadow-lg">
                                    Hemen Başvur
                                </button>
                                <button className="bg-white/10 backdrop-blur-md border border-white/20 px-10 py-4 rounded-2xl font-bold text-lg hover:bg-white/20 transition-all">
                                    Detaylı Bilgi
                                </button>
                            </div>
                        </div>
                        {/* Decorative icons */}
                        <div className="hidden lg:block absolute right-20 top-1/2 -translate-y-1/2 text-[200px] opacity-10 rotate-12">
                            <FiCheckCircle />
                        </div>
                    </div>
                </div>
            </section>

            {/* Footer */}
            <footer className="pt-20 pb-10 border-t border-gray-100">
                <div className="container mx-auto px-6">
                    <div className="grid md:grid-cols-4 gap-12 mb-16">
                        <div className="col-span-1 md:col-span-2 space-y-6">
                            <div className="flex items-center gap-2">
                                <div className="w-10 h-10 bg-primary rounded-xl flex items-center justify-center">
                                    <span className="text-white font-bold text-xl">G</span>
                                </div>
                                <span className="text-2xl font-bold tracking-tight">Güzellik</span>
                            </div>
                            <p className="text-secondary/60 max-w-sm leading-relaxed">
                                Güzellik ve wellness dünyasının en kapsamlı dijital platformu.
                                Siz harika görünün diye biz gece gündüz çalışıyoruz.
                            </p>
                        </div>
                        <div>
                            <h5 className="font-bold mb-6">Hızlı Bağlantılar</h5>
                            <ul className="space-y-4 text-secondary/60">
                                <li><a href="#hero" className="hover:text-primary transition-colors">Ana Sayfa</a></li>
                                <li><a href="#features" className="hover:text-primary transition-colors">Özellikler</a></li>
                                <li><a href="#about" className="hover:text-primary transition-colors">Hakkımızda</a></li>
                            </ul>
                        </div>
                        <div>
                            <h5 className="font-bold mb-6">İletişim</h5>
                            <ul className="space-y-4 text-secondary/60">
                                <li>destek@guzellik.app</li>
                                <li>+90 544 381 65 90</li>
                                <li>İstanbul, Türkiye</li>
                            </ul>
                        </div>
                    </div>
                    <div className="pt-8 border-t border-gray-100 text-center text-secondary/40 text-sm">
                        <p>&copy; {new Date().getFullYear()} Güzellik Hizmetleri Platformu. Tüm hakları saklıdır.</p>
                    </div>
                </div>
            </footer>

            {/* Global CSS for animations */}
            <style dangerouslySetInnerHTML={{
                __html: `
        @keyframes bounce-slow {
          0%, 100% { transform: translateY(-5%); animation-timing-function: cubic-bezier(0.8,0,1,1); }
          50% { transform: translateY(0); animation-timing-function: cubic-bezier(0,0,0.2,1); }
        }
        .animate-bounce-slow { animation: bounce-slow 3s infinite; }
        
        @keyframes float {
          0%, 100% { transform: translateY(0); }
          50% { transform: translateY(-20px); }
        }
        .animate-float { animation: float 6s ease-in-out infinite; }
        
        @keyframes float-delayed {
          0%, 100% { transform: translateY(0); }
          50% { transform: translateY(-15px); }
        }
        .animate-float-delayed { animation: float-delayed 8s ease-in-out infinite; }

        @keyframes fade-in-down {
          from { opacity: 0; transform: translateY(-10px); }
          to { opacity: 1; transform: translateY(0); }
        }
        .animate-fade-in-down { animation: fade-in-down 0.3s ease-out; }

        #hero h1 {
          word-spacing: 0.1em;
        }

        .primary-hover { background-color: #d6325a; }
      ` }} />
        </div>
    );
};

export default LandingPage;

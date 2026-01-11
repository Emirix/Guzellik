import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { auth, business } from '../lib/supabase';
import { Lock, Mail } from 'lucide-react';
import '../index.css';

export default function Login() {
    const navigate = useNavigate();
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState('');

    useEffect(() => {
        // Check if already logged in
        auth.getSession().then(({ session }) => {
            if (session) checkBusinessAndRedirect(session.user);
        });
    }, []);

    const checkBusinessAndRedirect = async (user) => {
        const { data: profile } = await business.checkBusinessAccount(user.id);

        if (profile?.is_business_account) {
            navigate('/dashboard');
        } else {
            setError('Bu hesaba bağlı bir işletme bulunamadı.');
            await auth.signOut();
        }
    };

    const handleLogin = async (e) => {
        e.preventDefault();
        setLoading(true);
        setError('');

        try {
            const { data, error } = await auth.signIn(email, password);

            if (error) throw error;

            if (data.user) {
                await checkBusinessAndRedirect(data.user);
            }
        } catch (err) {
            setError(err.message || 'Giriş yapılırken bir hata oluştu.');
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="min-h-screen flex items-center justify-center bg-gray-50 px-4">
            <div className="max-w-md w-full">
                {/* Logo */}
                <div className="text-center mb-8">
                    <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-primary-light text-primary mb-4">
                        <svg width="40" height="40" viewBox="0 0 32 32" fill="none">
                            <path d="M16 8L20 14H12L16 8Z" fill="currentColor" />
                            <path d="M16 24L12 18H20L16 24Z" fill="currentColor" />
                        </svg>
                    </div>
                    <h1 className="text-2xl font-bold text-gray-900">Güzellik Haritam</h1>
                    <p className="text-gray-500 mt-2">İşletme Yönetim Paneli</p>
                </div>

                {/* Login Card */}
                <div className="card animate-fade-in">
                    <h2 className="text-xl font-semibold mb-6 text-center">Giriş Yap</h2>

                    {error && (
                        <div className="bg-red-50 text-error text-sm p-3 rounded-lg mb-6 flex items-start gap-2">
                            <span>⚠️</span>
                            <p>{error}</p>
                        </div>
                    )}

                    <form onSubmit={handleLogin}>
                        <div className="form-group">
                            <label className="form-label">E-posta Adresi</label>
                            <div className="relative">
                                <Mail className="absolute left-3 top-3 text-gray-400" size={20} />
                                <input
                                    type="email"
                                    className="form-input pl-10"
                                    placeholder="ornek@isletme.com"
                                    value={email}
                                    onChange={(e) => setEmail(e.target.value)}
                                    required
                                />
                            </div>
                        </div>

                        <div className="form-group">
                            <label className="form-label">Şifre</label>
                            <div className="relative">
                                <Lock className="absolute left-3 top-3 text-gray-400" size={20} />
                                <input
                                    type="password"
                                    className="form-input pl-10"
                                    placeholder="••••••••"
                                    value={password}
                                    onChange={(e) => setPassword(e.target.value)}
                                    required
                                />
                            </div>
                        </div>

                        <button
                            type="submit"
                            className="btn btn-primary w-full justify-center"
                            disabled={loading}
                        >
                            {loading ? (
                                <div className="spinner w-5 h-5 border-2 border-white border-t-transparent" />
                            ) : (
                                'Giriş Yap'
                            )}
                        </button>
                    </form>
                </div>

                <p className="text-center text-sm text-gray-500 mt-8">
                    © 2026 Güzellik Haritam Business. Tüm hakları saklıdır.
                </p>
            </div>
        </div>
    );
}

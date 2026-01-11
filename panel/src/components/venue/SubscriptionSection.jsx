export default function SubscriptionSection({ value = {}, onChange }) {
    const plans = [
        { id: 'free', label: 'Ücretsiz', features: ['Temel Listeleme'] },
        { id: 'standard', label: 'Standart', features: ['Kampanyalar', 'Öncelikli Sıralama'] },
        { id: 'premium', label: 'Premium', features: ['Kampanyalar', 'Gelişmiş Analitik', 'Öncelikli Destek'] },
    ];

    return (
        <div className="space-y-6">
            <h3 className="text-xl font-bold">Abonelik Yönetimi</h3>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                {plans.map((plan) => (
                    <div
                        key={plan.id}
                        onClick={() => onChange({ ...value, plan_id: plan.id })}
                        className={`p-6 rounded-3xl border-2 cursor-pointer transition-all ${value.plan_id === plan.id
                                ? 'border-primary bg-primary/5 shadow-xl shadow-primary/10'
                                : 'border-gray-100 hover:border-gray-200 bg-white'
                            }`}
                    >
                        <div className="flex justify-between items-start mb-4">
                            <span className={`font-bold uppercase tracking-widest text-xs px-3 py-1 rounded-full ${value.plan_id === plan.id ? 'bg-primary text-white' : 'bg-gray-100 text-gray-500'
                                }`}>
                                {plan.label}
                            </span>
                            {value.plan_id === plan.id && <span className="material-symbols-outlined text-primary">verified</span>}
                        </div>

                        <ul className="space-y-3">
                            {plan.features.map(f => (
                                <li key={f} className="flex items-center gap-2 text-sm text-gray-600">
                                    <span className="material-symbols-outlined text-green-500 text-sm">check_circle</span>
                                    {f}
                                </li>
                            ))}
                        </ul>
                    </div>
                ))}
            </div>
        </div>
    );
}

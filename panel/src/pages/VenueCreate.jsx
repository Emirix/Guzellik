import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { venueService } from '../services/venueService';
import { locationService } from '../services/locationService';
import { serviceService } from '../services/serviceService';
import { specialistService } from '../services/specialistService';
import { photoService } from '../services/photoService';
import { useToast } from '../contexts/ToastContext';
import Button from '../components/common/Button';
import Input from '../components/common/Input';
import Select from '../components/common/Select';
import LoadingSpinner from '../components/common/LoadingSpinner';
import WorkingHoursSection from '../components/venue/WorkingHoursSection';
import ServicesSection from '../components/venue/ServicesSection';
import SpecialistsSection from '../components/venue/SpecialistsSection';
import PhotosSection from '../components/venue/PhotosSection';
import SubscriptionSection from '../components/venue/SubscriptionSection';

const TABS = [
    { id: 'basic', label: 'Temel Bilgiler', icon: 'info' },
    { id: 'location', label: 'Konum', icon: 'location_on' },
    { id: 'social', label: 'İletişim & Sosyal', icon: 'share' },
    { id: 'hours', label: 'Çalışma Saatleri', icon: 'schedule' },
    { id: 'services', label: 'Hizmetler', icon: 'spa' },
    { id: 'specialists', label: 'Uzmanlar', icon: 'groups' },
    { id: 'photos', label: 'Fotoğraflar', icon: 'imagesmode' },
    { id: 'details', label: 'Ek Detaylar', icon: 'settings_suggest' },
    { id: 'faq', label: 'SSS', icon: 'quiz' },
    { id: 'subscription', label: 'Abonelik', icon: 'card_membership' },
];

export default function VenueCreate() {
    const navigate = useNavigate();
    const { showToast } = useToast();
    const [activeTab, setActiveTab] = useState('basic');
    const [loading, setLoading] = useState(false);

    // Data for Selects
    const [provinces, setProvinces] = useState([]);
    const [districts, setDistricts] = useState([]);
    const [categories, setCategories] = useState([]);

    // Form State
    const [formData, setFormData] = useState({
        name: '',
        description: '',
        icon: '',
        category_id: '',
        is_verified: false,
        is_preferred: false,
        is_hygienic: false,
        province_id: '',
        district_id: '',
        address: '',
        latitude: '',
        longitude: '',
        social_links: {
            phone: '',
            whatsapp: '',
            instagram: '',
            facebook: '',
            website: ''
        },
        working_hours: {},
        services: [],
        specialists: [],
        photos: [],
        features: [],
        payment_options: [],
        accessibility: {
            wheelchair: false,
            parking: false,
            wifi: false,
            air_conditioning: false
        },
        certifications: [],
        faq: [],
        subscription: { plan_id: 'free' }
    });

    useEffect(() => {
        loadInitialData();
    }, []);

    useEffect(() => {
        if (formData.province_id) {
            loadDistricts(formData.province_id);
        }
    }, [formData.province_id]);

    const loadInitialData = async () => {
        try {
            const [provincesData, categoriesData] = await Promise.all([
                locationService.getProvinces(),
                locationService.getCategories(),
            ]);
            setProvinces(provincesData);
            setCategories(categoriesData);
        } catch (error) {
            showToast(error.message, 'error');
        }
    };

    const loadDistricts = async (provinceId) => {
        try {
            const data = await locationService.getDistricts(provinceId);
            setDistricts(data);
        } catch (error) {
            showToast(error.message, 'error');
        }
    };

    const handleChange = (field, value) => {
        setFormData(prev => ({ ...prev, [field]: value }));
    };

    const handleSocialChange = (field, value) => {
        setFormData(prev => ({
            ...prev,
            social_links: { ...prev.social_links, [field]: value }
        }));
    };

    const handleAccessibilityChange = (field, value) => {
        setFormData(prev => ({
            ...prev,
            accessibility: { ...prev.accessibility, [field]: value }
        }));
    };

    const handleAddFaq = () => {
        setFormData(prev => ({
            ...prev,
            faq: [...prev.faq, { question: '', answer: '' }]
        }));
    };

    const handleUpdateFaq = (index, field, value) => {
        const newFaq = [...formData.faq];
        newFaq[index] = { ...newFaq[index], [field]: value };
        setFormData(prev => ({ ...prev, faq: newFaq }));
    };

    const handleRemoveFaq = (index) => {
        setFormData(prev => ({
            ...prev,
            faq: prev.faq.filter((_, i) => i !== index)
        }));
    };

    const handleSubmit = async (e) => {
        e.preventDefault();

        if (!formData.name || !formData.category_id || !formData.province_id) {
            showToast('Lütfen zorunlu alanları doldurun', 'error');
            setActiveTab('basic');
            return;
        }

        try {
            setLoading(true);

            let locationPoint = null;
            if (formData.latitude && formData.longitude) {
                locationPoint = `POINT(${formData.longitude} ${formData.latitude})`;
            }

            const venuePayload = {
                name: formData.name,
                description: formData.description,
                icon: formData.icon,
                address: formData.address,
                category_id: formData.category_id,
                province_id: parseInt(formData.province_id),
                district_id: formData.district_id,
                location: locationPoint,
                latitude: formData.latitude ? parseFloat(formData.latitude) : null,
                longitude: formData.longitude ? parseFloat(formData.longitude) : null,
                is_verified: formData.is_verified,
                is_preferred: formData.is_preferred,
                is_hygienic: formData.is_hygienic,
                working_hours: formData.working_hours,
                social_links: formData.social_links,
                features: formData.features,
                payment_options: formData.payment_options,
                accessibility: formData.accessibility,
                certifications: formData.certifications,
                faq: formData.faq,
                image_url: formData.photos[0]?.url || null,
                hero_images: formData.photos.slice(0, 5).map(p => p.url),
                expert_team: formData.specialists.map(s => ({ name: s.name, title: s.title }))
            };

            const venue = await venueService.create(venuePayload);
            const venueId = venue.id;

            await Promise.all([
                serviceService.saveVenueServices(venueId, formData.services),
                specialistService.saveSpecialists(venueId, formData.specialists),
                photoService.savePhotoMetadata(venueId, formData.photos)
            ]);

            showToast('İşletme tüm detaylarıyla birlikte oluşturuldu!');
            navigate('/admin/venues');
        } catch (error) {
            showToast(error.message, 'error');
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="max-w-6xl mx-auto space-y-10 animate-fade-in">
            <div className="flex justify-between items-center">
                <div>
                    <h2 className="text-4xl font-bold text-secondary">Yeni İşletme</h2>
                    <p className="text-gray-400 font-medium mt-2">Detaylı işletme profili oluşturun</p>
                </div>
                <div className="flex gap-4">
                    <Button variant="ghost" onClick={() => navigate('/admin/venues')}>İptal</Button>
                    <Button onClick={handleSubmit} disabled={loading} className="min-w-[180px]">
                        {loading ? <LoadingSpinner size="sm" /> : <span className="material-symbols-outlined text-[20px] fill-1">save</span>}
                        {loading ? 'Kaydediliyor...' : 'İşletmeyi Kaydet'}
                    </Button>
                </div>
            </div>

            <div className="flex gap-10">
                {/* Tab Navigation */}
                <div className="w-72 space-y-1 shrink-0">
                    <div className="text-[11px] font-bold text-gray-400 uppercase tracking-[0.2em] mb-4 px-4">Form Bölümleri</div>
                    {TABS.map(tab => (
                        <button
                            key={tab.id}
                            onClick={() => setActiveTab(tab.id)}
                            className={`w-full flex items-center gap-4 px-6 py-4 rounded-2xl transition-all duration-300 font-semibold text-sm ${activeTab === tab.id
                                ? 'bg-white shadow-lg shadow-black/5 text-primary border border-gray-100'
                                : 'text-gray-400 hover:text-gray-600 hover:bg-gray-50/50'
                                }`}
                        >
                            <span className={`material-symbols-outlined text-[22px] ${activeTab === tab.id ? 'fill-1' : 'font-light'}`}>
                                {tab.icon}
                            </span>
                            {tab.label}
                        </button>
                    ))}
                </div>

                {/* Tab Content */}
                <div className="flex-1 glass-card rounded-[40px] p-12 min-h-[700px] relative">
                    {activeTab === 'basic' && (
                        <div className="space-y-10 animate-fade-in">
                            <h3 className="text-2xl font-bold text-secondary">Temel Bilgiler</h3>
                            <div className="grid grid-cols-2 gap-8">
                                <div className="col-span-2">
                                    <Input
                                        label="İşletme Adı"
                                        value={formData.name}
                                        onChange={e => handleChange('name', e.target.value)}
                                        placeholder="Örn: Güzellik Lab"
                                        required
                                    />
                                </div>
                                <Select
                                    label="Kategori"
                                    value={formData.category_id}
                                    onChange={e => handleChange('category_id', e.target.value)}
                                    options={categories.map(c => ({ value: c.id, label: c.name }))}
                                    required
                                />
                                <Input
                                    label="İkon (Material Symbol Adı)"
                                    value={formData.icon}
                                    onChange={e => handleChange('icon', e.target.value)}
                                    placeholder="Örn: spa, content_cut"
                                />
                                <div className="flex items-center gap-6 pt-10">
                                    <label className="flex items-center gap-3 cursor-pointer group">
                                        <input
                                            type="checkbox"
                                            className="w-6 h-6 rounded-lg accent-primary border-gray-200"
                                            checked={formData.is_verified}
                                            onChange={e => handleChange('is_verified', e.target.checked)}
                                        />
                                        <span className="text-sm font-bold text-gray-500 group-hover:text-secondary transition-colors">Onaylı</span>
                                    </label>
                                    <label className="flex items-center gap-3 cursor-pointer group">
                                        <input
                                            type="checkbox"
                                            className="w-6 h-6 rounded-lg accent-primary border-gray-200"
                                            checked={formData.is_preferred}
                                            onChange={e => handleChange('is_preferred', e.target.checked)}
                                        />
                                        <span className="text-sm font-bold text-gray-500 group-hover:text-secondary transition-colors">Tercih Edilen</span>
                                    </label>
                                    <label className="flex items-center gap-3 cursor-pointer group">
                                        <input
                                            type="checkbox"
                                            className="w-6 h-6 rounded-lg accent-primary border-gray-200"
                                            checked={formData.is_hygienic}
                                            onChange={e => handleChange('is_hygienic', e.target.checked)}
                                        />
                                        <span className="text-sm font-bold text-gray-500 group-hover:text-secondary transition-colors">Hijyenik</span>
                                    </label>
                                </div>
                                <div className="col-span-2 space-y-2">
                                    <label className="text-[13px] font-bold text-gray-500 uppercase tracking-wider ml-1">İşletme Tanıtımı</label>
                                    <textarea
                                        value={formData.description}
                                        onChange={e => handleChange('description', e.target.value)}
                                        rows={5}
                                        placeholder="İşletmenizi bir kaç cümle ile tanıtın..."
                                        className="w-full px-5 py-4 rounded-2xl bg-white border border-gray-100 focus:border-primary/30 focus:shadow-lg focus:shadow-primary/5 outline-none transition-all duration-300 text-sm font-medium text-secondary placeholder:text-gray-300"
                                    />
                                </div>
                            </div>
                        </div>
                    )}

                    {activeTab === 'location' && (
                        <div className="space-y-10 animate-fade-in">
                            <h3 className="text-2xl font-bold text-secondary">Konum Bilgileri</h3>
                            <div className="grid grid-cols-2 gap-8">
                                <Select
                                    label="İl"
                                    value={formData.province_id}
                                    onChange={e => handleChange('province_id', e.target.value)}
                                    options={provinces.map(p => ({ value: p.id, label: p.name }))}
                                    required
                                />
                                <Select
                                    label="İlçe"
                                    value={formData.district_id}
                                    onChange={e => handleChange('district_id', e.target.value)}
                                    options={districts.map(d => ({ value: d.id, label: d.name }))}
                                    disabled={!formData.province_id}
                                    required
                                />
                                <div className="col-span-2">
                                    <Input
                                        label="Tam Adres"
                                        value={formData.address}
                                        onChange={e => handleChange('address', e.target.value)}
                                        placeholder="Cadde, sokak, numara ve kat bilgileri..."
                                    />
                                </div>
                                <Input
                                    label="Enlem (Latitiude)"
                                    value={formData.latitude}
                                    onChange={e => handleChange('latitude', e.target.value)}
                                    placeholder="41.0082"
                                />
                                <Input
                                    label="Boylam (Longitude)"
                                    value={formData.longitude}
                                    onChange={e => handleChange('longitude', e.target.value)}
                                    placeholder="28.9784"
                                />
                            </div>
                        </div>
                    )}

                    {activeTab === 'social' && (
                        <div className="space-y-10 animate-fade-in">
                            <h3 className="text-2xl font-bold text-secondary">İletişim & Sosyal Medya</h3>
                            <div className="grid grid-cols-2 gap-8">
                                <Input
                                    label="Telefon Numarası"
                                    value={formData.social_links.phone}
                                    onChange={e => handleSocialChange('phone', e.target.value)}
                                    placeholder="0212 --- -- --"
                                />
                                <Input
                                    label="WhatsApp Numarası"
                                    value={formData.social_links.whatsapp}
                                    onChange={e => handleSocialChange('whatsapp', e.target.value)}
                                    placeholder="05-- --- -- --"
                                />
                                <Input
                                    label="Instagram Kullanıcı Adı"
                                    value={formData.social_links.instagram}
                                    onChange={e => handleSocialChange('instagram', e.target.value)}
                                    placeholder="@..."
                                />
                                <Input
                                    label="Facebook Sayfası"
                                    value={formData.social_links.facebook}
                                    onChange={e => handleSocialChange('facebook', e.target.value)}
                                    placeholder="facebook.com/..."
                                />
                                <div className="col-span-2">
                                    <Input
                                        label="Web Sitesi"
                                        value={formData.social_links.website}
                                        onChange={e => handleSocialChange('website', e.target.value)}
                                        placeholder="https://..."
                                    />
                                </div>
                            </div>
                        </div>
                    )}

                    {activeTab === 'hours' && (
                        <WorkingHoursSection
                            value={formData.working_hours}
                            onChange={val => handleChange('working_hours', val)}
                        />
                    )}

                    {activeTab === 'services' && (
                        <ServicesSection
                            selectedServices={formData.services}
                            onChange={val => handleChange('services', val)}
                        />
                    )}

                    {activeTab === 'specialists' && (
                        <SpecialistsSection
                            specialists={formData.specialists}
                            onChange={val => handleChange('specialists', val)}
                        />
                    )}

                    {activeTab === 'photos' && (
                        <PhotosSection
                            photos={formData.photos}
                            onChange={val => handleChange('photos', val)}
                        />
                    )}

                    {activeTab === 'details' && (
                        <div className="space-y-10 animate-fade-in">
                            <h3 className="text-2xl font-bold text-secondary">Ek Detaylar</h3>

                            <div className="space-y-6">
                                <label className="text-[13px] font-bold text-gray-500 uppercase tracking-wider ml-1">Erişilebilirlik</label>
                                <div className="grid grid-cols-2 gap-4">
                                    {Object.entries({
                                        wheelchair: 'Tekerlekli Sandalye Erişimi',
                                        parking: 'Otopark',
                                        wifi: 'Ücretsiz Wi-Fi',
                                        air_conditioning: 'Klima'
                                    }).map(([key, label]) => (
                                        <label key={key} className="flex items-center gap-4 p-4 rounded-2xl border border-gray-100 bg-gray-50/30 cursor-pointer hover:bg-white transition-all">
                                            <input
                                                type="checkbox"
                                                className="w-5 h-5 rounded-lg accent-primary border-gray-200"
                                                checked={formData.accessibility[key]}
                                                onChange={e => handleAccessibilityChange(key, e.target.checked)}
                                            />
                                            <span className="text-sm font-semibold text-gray-600">{label}</span>
                                        </label>
                                    ))}
                                </div>
                            </div>

                            <div className="space-y-4">
                                <label className="text-[13px] font-bold text-gray-500 uppercase tracking-wider ml-1">Özellikler & İmkanlar (Virgül ile ayırın)</label>
                                <Input
                                    value={formData.features.join(', ')}
                                    onChange={e => handleChange('features', e.target.value.split(',').map(s => s.trim()))}
                                    placeholder="Kahve, Müzik, VIP Oda..."
                                />
                            </div>

                            <div className="space-y-4">
                                <label className="text-[13px] font-bold text-gray-500 uppercase tracking-wider ml-1">Ödeme Seçenekleri (Virgül ile ayırın)</label>
                                <Input
                                    value={formData.payment_options.join(', ')}
                                    onChange={e => handleChange('payment_options', e.target.value.split(',').map(s => s.trim()))}
                                    placeholder="Nakit, Kredi Kartı, Sodexo..."
                                />
                            </div>

                            <div className="space-y-4">
                                <label className="text-[13px] font-bold text-gray-500 uppercase tracking-wider ml-1">Sertifikalar (Virgül ile ayırın)</label>
                                <Input
                                    value={formData.certifications.join(', ')}
                                    onChange={e => handleChange('certifications', e.target.value.split(',').map(s => s.trim()))}
                                    placeholder="ISO 9001, Hijyen Belgesi..."
                                />
                            </div>
                        </div>
                    )}

                    {activeTab === 'faq' && (
                        <div className="space-y-10 animate-fade-in">
                            <div className="flex justify-between items-center">
                                <h3 className="text-2xl font-bold text-secondary">Sıkça Sorulan Sorular</h3>
                                <Button variant="secondary" onClick={handleAddFaq}>
                                    <span className="material-symbols-outlined text-[20px]">add</span>
                                    Yeni SSS Ekle
                                </Button>
                            </div>

                            <div className="space-y-6">
                                {formData.faq.map((item, index) => (
                                    <div key={index} className="bg-gray-50/50 p-6 rounded-3xl border border-gray-100 relative group animate-fade-in">
                                        <button
                                            type="button"
                                            onClick={() => handleRemoveFaq(index)}
                                            className="absolute top-4 right-4 text-gray-400 hover:text-red-500 transition-colors"
                                        >
                                            <span className="material-symbols-outlined">delete</span>
                                        </button>
                                        <div className="space-y-4 pr-10">
                                            <Input
                                                label="Soru"
                                                value={item.question}
                                                onChange={e => handleUpdateFaq(index, 'question', e.target.value)}
                                                placeholder="Örn: Otopark mevcut mu?"
                                            />
                                            <div className="space-y-2">
                                                <label className="text-[11px] font-bold text-gray-400 uppercase tracking-widest ml-1">Cevap</label>
                                                <textarea
                                                    value={item.answer}
                                                    onChange={e => handleUpdateFaq(index, 'answer', e.target.value)}
                                                    rows={3}
                                                    className="w-full px-5 py-4 rounded-2xl bg-white border border-gray-100 focus:border-primary/30 outline-none text-sm font-medium text-secondary"
                                                    placeholder="Cevabınızı yazın..."
                                                />
                                            </div>
                                        </div>
                                    </div>
                                ))}
                                {formData.faq.length === 0 && (
                                    <div className="py-20 text-center border-2 border-dashed border-gray-100 rounded-[40px]">
                                        <p className="text-gray-400 text-sm font-bold uppercase tracking-widest">Henüz SSS eklenmemiş</p>
                                    </div>
                                )}
                            </div>
                        </div>
                    )}

                    {activeTab === 'subscription' && (
                        <SubscriptionSection
                            value={formData.subscription}
                            onChange={val => handleChange('subscription', val)}
                        />
                    )}
                </div>
            </div>
        </div>
    );
}

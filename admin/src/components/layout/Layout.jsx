import { useState, useEffect } from 'react';
import { Outlet } from 'react-router-dom';
import Sidebar from './Sidebar';
import Header from './Header';
import { auth, business } from '../../lib/supabase';

export default function Layout() {
    const [isSidebarOpen, setIsSidebarOpen] = useState(false);
    const [user, setUser] = useState(null);
    const [venue, setVenue] = useState(null);

    useEffect(() => {
        // Get initial user
        auth.getUser().then(({ user }) => {
            setUser(user);
            if (user) loadVenueData(user.id);
        });

        // Listen for auth changes
        const { data: { subscription } } = auth.onAuthStateChange((_event, session) => {
            setUser(session?.user ?? null);
            if (session?.user) loadVenueData(session.user.id);
        });

        return () => subscription.unsubscribe();
    }, []);

    const loadVenueData = async (userId) => {
        // Check if user is business account
        const { data: profile } = await business.checkBusinessAccount(userId);

        if (profile?.is_business_account && profile?.business_venue_id) {
            const { data: venueData } = await business.getBusinessVenue(profile.business_venue_id);
            setVenue(venueData);
        }
    };

    const handleLogout = async () => {
        await auth.signOut();
        // Redirect handled by App.jsx or router guard
    };

    return (
        <div className="layout">
            <Sidebar
                isOpen={isSidebarOpen}
                onClose={() => setIsSidebarOpen(false)}
                onLogout={handleLogout}
            />

            <div className="main-wrapper">
                <Header
                    onMenuClick={() => setIsSidebarOpen(true)}
                    user={user}
                    venueName={venue?.name}
                />

                <main className="main-content">
                    <Outlet />
                </main>
            </div>
        </div>
    );
}

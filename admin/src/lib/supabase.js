import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
    throw new Error('Missing Supabase environment variables');
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

// Auth helpers
export const auth = {
    async signIn(email, password) {
        const { data, error } = await supabase.auth.signInWithPassword({
            email,
            password,
        });
        return { data, error };
    },

    async signOut() {
        const { error } = await supabase.auth.signOut();
        return { error };
    },

    async getSession() {
        const { data: { session }, error } = await supabase.auth.getSession();
        return { session, error };
    },

    async getUser() {
        const { data: { user }, error } = await supabase.auth.getUser();
        return { user, error };
    },

    onAuthStateChange(callback) {
        return supabase.auth.onAuthStateChange(callback);
    },
};

// Business helpers
export const business = {
    async checkBusinessAccount(userId) {
        const { data, error } = await supabase
            .from('profiles')
            .select('is_business_account, business_venue_id')
            .eq('id', userId)
            .single();
        return { data, error };
    },

    async getBusinessVenue(venueId) {
        const { data, error } = await supabase
            .from('venues')
            .select('*')
            .eq('id', venueId)
            .single();
        return { data, error };
    },

    async getBusinessStats(venueId) {
        const { data, error } = await supabase
            .rpc('get_business_stats', { venue_id_param: venueId });
        return { data, error };
    },
};

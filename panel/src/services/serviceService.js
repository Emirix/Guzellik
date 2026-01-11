import { supabase } from './supabaseClient';

export const serviceService = {
    async getCategories() {
        const { data, error } = await supabase
            .from('service_categories')
            .select('*')
            .order('name');

        if (error) throw error;
        return data;
    },

    async getVenueServices(venueId) {
        const { data, error } = await supabase
            .from('venue_services')
            .select(`
        *,
        service_categories (*)
      `)
            .eq('venue_id', venueId);

        if (error) throw error;
        return data;
    },

    async saveVenueServices(venueId, services) {
        // Delete existing
        await supabase.from('venue_services').delete().eq('venue_id', venueId);

        if (services.length === 0) return;

        // Insert new
        const { error } = await supabase
            .from('venue_services')
            .insert(services.map(s => ({
                venue_id: venueId,
                service_id: s.service_id,
                price: s.price,
                duration_minutes: s.duration_minutes,
                is_active: true
            })));

        if (error) throw error;
    }
};

import { supabase } from './supabaseClient';

export const specialistService = {
    async getVenueSpecialists(venueId) {
        const { data, error } = await supabase
            .from('specialists')
            .select('*')
            .eq('venue_id', venueId)
            .order('created_at');

        if (error) throw error;
        return data;
    },

    async saveSpecialists(venueId, specialists) {
        // Keep track of current IDs to delete ones that are missing
        const currentSpecialists = await this.getVenueSpecialists(venueId);
        const newIds = specialists.filter(s => s.id).map(s => s.id);
        const toDelete = currentSpecialists.filter(s => !newIds.includes(s.id)).map(s => s.id);

        if (toDelete.length > 0) {
            await supabase.from('specialists').delete().in('id', toDelete);
        }

        for (const specialist of specialists) {
            const data = {
                venue_id: venueId,
                name: specialist.name,
                title: specialist.title,
                bio: specialist.bio,
                image_url: specialist.image_url,
                is_active: true
            };

            if (specialist.id) {
                await supabase.from('specialists').update(data).eq('id', specialist.id);
            } else {
                await supabase.from('specialists').insert([data]);
            }
        }
    }
};

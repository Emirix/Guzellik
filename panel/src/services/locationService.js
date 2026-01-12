import { supabase } from './supabaseClient';

export const locationService = {
    async getProvinces() {
        const { data, error } = await supabase
            .from('provinces')
            .select('id, name')
            .order('name');

        if (error) throw error;
        return data;
    },

    async getDistricts(provinceId) {
        const { data, error } = await supabase
            .from('districts')
            .select('id, name')
            .eq('province_id', provinceId)
            .order('name');

        if (error) throw error;
        return data;
    },

    async getCategories() {
        const { data, error } = await supabase
            .from('venue_categories')
            .select('id, name')
            // .eq('is_active', true) // Removed filter as it might be causing empty results
            .order('name');

        if (error) throw error;
        return data;
    },
};

import { supabase } from './supabaseClient';

export const venueService = {
    async getAll({ search = '', page = 1, limit = 20 } = {}) {
        let query = supabase
            .from('venues')
            .select(`
        *,
        venue_categories(name),
        provinces(name),
        districts(name)
      `, { count: 'exact' })
            .order('created_at', { ascending: false });

        if (search) {
            query = query.ilike('name', `%${search}%`);
        }

        const from = (page - 1) * limit;
        const to = from + limit - 1;
        query = query.range(from, to);

        const { data, error, count } = await query;

        if (error) throw error;
        return { data, count };
    },

    async getById(id) {
        const { data, error } = await supabase
            .from('venues')
            .select(`
        *,
        venue_categories(id, name),
        provinces(id, name),
        districts(id, name)
      `)
            .eq('id', id)
            .single();

        if (error) throw error;
        return data;
    },

    async create(venueData) {
        const { data, error } = await supabase
            .from('venues')
            .insert([venueData])
            .select()
            .single();

        if (error) throw error;
        return data;
    },

    async update(id, venueData) {
        const { data, error } = await supabase
            .from('venues')
            .update(venueData)
            .eq('id', id)
            .select()
            .single();

        if (error) throw error;
        return data;
    },

    async delete(id) {
        const { error } = await supabase
            .from('venues')
            .delete()
            .eq('id', id);

        if (error) throw error;
    },
};

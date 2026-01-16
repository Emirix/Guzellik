const API_URL = 'https://guzellikharitam.com/api';
const API_KEY = 'GuzellikHaritam_Secure_2026_Key';

export const photoService = {
    async uploadPhoto(file, venueId) {
        const formData = new FormData();
        formData.append('file', file);
        formData.append('path', `venue-photos/${venueId}`);

        const response = await fetch(`${API_URL}/upload.php`, {
            method: 'POST',
            headers: {
                'Authorization': API_KEY
            },
            body: formData
        });

        const result = await response.json();
        if (!response.ok) throw new Error(result.error || 'Upload failed');

        return result.url;
    },

    async getVenuePhotos(venueId) {
        const { data, error } = await supabase
            .from('venue_photos')
            .select('*')
            .eq('venue_id', venueId)
            .order('sort_order');

        if (error) throw error;
        return data;
    },

    async savePhotoMetadata(venueId, photos) {
        // Delete missing
        const current = await this.getVenuePhotos(venueId);
        const newUrls = photos.map(p => p.url);
        const toDelete = current.filter(p => !newUrls.includes(p.url));

        if (toDelete.length > 0) {
            // In a real app we might want to delete from storage too
            await supabase.from('venue_photos').delete().in('id', toDelete.map(p => p.id));
        }

        // Insert/Update
        for (let i = 0; i < photos.length; i++) {
            const photo = photos[i];
            const data = {
                venue_id: venueId,
                url: photo.url,
                sort_order: i,
                is_hero_image: i === 0, // Mark first as hero
                category: 'interior'
            };

            if (photo.id) {
                await supabase.from('venue_photos').update(data).eq('id', photo.id);
            } else {
                await supabase.from('venue_photos').insert([data]);
            }
        }
    }
};

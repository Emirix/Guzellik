import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
    // Handle CORS
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders })
    }

    try {
        const url = new URL(req.url)
        const venueId = url.searchParams.get('id')

        if (!venueId) {
            return new Response(
                JSON.stringify({ error: 'venue_id is required. Use ?id=UUID' }),
                { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
            )
        }

        const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ''
        const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''

        const supabase = createClient(supabaseUrl, supabaseServiceKey)

        // Fetch venue details including related tables
        const { data, error } = await supabase
            .from('venues')
            .select(`
        *,
        photos:venue_photos(*),
        specialists(*),
        subscription:venues_subscription(*),
        campaigns(*),
        venue_services(
          *,
          services(*)
        ),
        reviews(*),
        province:provinces(name),
        district:districts(name)
      `)
            .eq('id', venueId)
            .single()

        if (error) {
            return new Response(
                JSON.stringify({ error: error.message }),
                { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
            )
        }

        return new Response(
            JSON.stringify(data),
            { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
    } catch (error) {
        return new Response(
            JSON.stringify({ error: error.message }),
            { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
    }
})

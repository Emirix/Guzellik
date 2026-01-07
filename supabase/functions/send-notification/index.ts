import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const FCM_URL = 'https://fcm.googleapis.com/fcm/send'
const SERVER_KEY = Deno.env.get('FCM_SERVER_KEY')

serve(async (req) => {
    try {
        const { token, title, body, data } = await req.json()

        if (!SERVER_KEY) {
            return new Response(
                JSON.stringify({ error: 'FCM_SERVER_KEY not set' }),
                { status: 500, headers: { 'Content-Type': 'application/json' } }
            )
        }

        const res = await fetch(FCM_URL, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `key=${SERVER_KEY}`,
            },
            body: JSON.stringify({
                to: token,
                notification: { title, body },
                data: data || {},
            }),
        })

        const result = await res.json()
        return new Response(JSON.stringify(result), {
            headers: { 'Content-Type': 'application/json' },
        })
    } catch (error) {
        return new Response(JSON.stringify({ error: error.message }), {
            status: 400,
            headers: { 'Content-Type': 'application/json' },
        })
    }
})

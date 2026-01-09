package com.emx.guzellikharitam

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.widget.Button
import android.widget.ImageView
import android.widget.TextView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

/**
 * Native Ad Factory - listTile formatında reklamlar için
 */
class ListTileNativeAdFactory(private val context: Context) : GoogleMobileAdsPlugin.NativeAdFactory {

    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        val adView = LayoutInflater.from(context)
            .inflate(R.layout.native_ad_list_tile, null) as NativeAdView

        // Reklam başlığı
        val headlineView = adView.findViewById<TextView>(R.id.ad_headline)
        headlineView.text = nativeAd.headline
        adView.headlineView = headlineView

        // Reklam gövdesi
        val bodyView = adView.findViewById<TextView>(R.id.ad_body)
        bodyView.text = nativeAd.body
        adView.bodyView = bodyView

        // Reklam ikonu
        val iconView = adView.findViewById<ImageView>(R.id.ad_icon)
        if (nativeAd.icon != null) {
            iconView.setImageDrawable(nativeAd.icon?.drawable)
            iconView.visibility = View.VISIBLE
        } else {
            iconView.visibility = View.GONE
        }
        adView.iconView = iconView

        // Çağrı butonu (CTA)
        val callToActionView = adView.findViewById<Button>(R.id.ad_call_to_action)
        callToActionView.text = nativeAd.callToAction
        adView.callToActionView = callToActionView

        // Reklamveren adı
        val advertiserView = adView.findViewById<TextView>(R.id.ad_advertiser)
        if (nativeAd.advertiser != null) {
            advertiserView.text = nativeAd.advertiser
            advertiserView.visibility = View.VISIBLE
        } else {
            advertiserView.visibility = View.GONE
        }
        adView.advertiserView = advertiserView

        // Native ad'ı görünüme bağla
        adView.setNativeAd(nativeAd)

        return adView
    }
}

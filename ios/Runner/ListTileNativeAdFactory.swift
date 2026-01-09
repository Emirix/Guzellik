import Foundation
import google_mobile_ads

/// Native Ad Factory - listTile formatında reklamlar için
class ListTileNativeAdFactory: FLTNativeAdFactory {
    
    func createNativeAd(_ nativeAd: GADNativeAd, customOptions: [AnyHashable : Any]? = nil) -> GADNativeAdView? {
        // xib dosyasından view yükle
        let nibView = Bundle.main.loadNibNamed("ListTileNativeAdView", owner: nil, options: nil)?.first
        guard let nativeAdView = nibView as? GADNativeAdView else {
            return nil
        }
        
        // Başlık
        (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
        
        // Açıklama
        (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
        nativeAdView.bodyView?.isHidden = nativeAd.body == nil
        
        // CTA Button
        (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        nativeAdView.callToActionView?.isHidden = nativeAd.callToAction == nil
        
        // Icon
        (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        nativeAdView.iconView?.isHidden = nativeAd.icon == nil
        
        // Reklamveren
        (nativeAdView.advertiserView as? UILabel)?.text = nativeAd.advertiser
        nativeAdView.advertiserView?.isHidden = nativeAd.advertiser == nil
        
        // Native ad'ı view'a bağla
        nativeAdView.nativeAd = nativeAd
        
        return nativeAdView
    }
}

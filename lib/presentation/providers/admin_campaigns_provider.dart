import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/models/campaign.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/services/storage_service.dart';

class AdminCampaignsProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  final _storageService = StorageService();

  List<Campaign> _campaigns = [];
  bool _isLoading = false;
  String? _error;

  List<Campaign> get campaigns => _campaigns;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCampaigns(String venueId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('campaigns')
          .select()
          .eq('venue_id', venueId)
          .order('created_at', ascending: false);

      _campaigns = (response as List)
          .map((json) => Campaign.fromJson(json))
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createCampaign(
    String venueId, {
    required String title,
    String? description,
    int? discountPercentage,
    double? discountAmount,
    DateTime? startDate,
    DateTime? endDate,
    File? imageFile,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _storageService.uploadImage(
          bucket: 'campaigns',
          path: venueId,
          imageFile: imageFile,
        );
      }

      await _supabase.from('campaigns').insert({
        'venue_id': venueId,
        'title': title,
        'description': description,
        'discount_percentage': discountPercentage,
        'discount_amount': discountAmount,
        'start_date': startDate?.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
        'image_url': imageUrl,
        'is_active': true,
      });

      await fetchCampaigns(venueId);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCampaign(
    String campaignId, {
    String? title,
    String? description,
    int? discountPercentage,
    double? discountAmount,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    File? newImageFile,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updates = <String, dynamic>{};
      if (title != null) updates['title'] = title;
      if (description != null) updates['description'] = description;
      updates['discount_percentage'] = discountPercentage;
      updates['discount_amount'] = discountAmount;
      if (startDate != null) {
        updates['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) updates['end_date'] = endDate.toIso8601String();
      if (isActive != null) updates['is_active'] = isActive;

      if (newImageFile != null) {
        final current = _campaigns.firstWhere((c) => c.id == campaignId);
        final venueId = current.venueId;

        // Delete old image if exists
        if (current.imageUrl != null) {
          _storageService.deleteFileByUrl(current.imageUrl!);
        }

        updates['image_url'] = await _storageService.uploadImage(
          bucket: 'campaigns',
          path: venueId,
          imageFile: newImageFile,
        );
      }

      await _supabase.from('campaigns').update(updates).eq('id', campaignId);

      final current = _campaigns.firstWhere((c) => c.id == campaignId);
      await fetchCampaigns(current.venueId);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCampaign(String campaignId) async {
    try {
      final current = _campaigns.firstWhere((c) => c.id == campaignId);
      final venueId = current.venueId;

      await _supabase.from('campaigns').delete().eq('id', campaignId);

      if (current.imageUrl != null) {
        await _storageService.deleteFileByUrl(current.imageUrl!);
      }

      await fetchCampaigns(venueId);
    } catch (e) {
      rethrow;
    }
  }
}

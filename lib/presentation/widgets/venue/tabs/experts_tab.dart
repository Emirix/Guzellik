import 'package:flutter/material.dart';
import '../../common/empty_state.dart';
import '../../../../data/models/venue.dart';
import '../../../../data/models/expert.dart';
import '../../../../data/models/specialist.dart';

import '../components/expert_card.dart';
import '../components/specialist_detail_bottom_sheet.dart';

class ExpertsTab extends StatelessWidget {
  final Venue venue;
  final List<Specialist> specialists;

  const ExpertsTab({super.key, required this.venue, required this.specialists});

  @override
  Widget build(BuildContext context) {
    final bool hasRealSpecialists = specialists.isNotEmpty;
    final bool hasExpertTeam = venue.expertTeam.isNotEmpty;

    if (!hasRealSpecialists && !hasExpertTeam) {
      return Center(
        child: EmptyState(
          icon: Icons.people_outline_rounded,
          title: 'Uzman Bulunamadı',
          message: 'Bu mekan için henüz kayıtlı uzman bilgisi bulunmuyor.',
        ),
      );
    }

    final List<Specialist> displaySpecialists = hasRealSpecialists
        ? specialists
        : venue.expertTeam.map((expertData) {
            if (expertData is Specialist) return expertData;

            final Map<String, dynamic> data = expertData is Map<String, dynamic>
                ? expertData
                : {};

            return Specialist(
              id: data['id']?.toString() ?? '',
              venueId: venue.id,
              name: data['name'] ?? 'İsimsiz Uzman',
              profession: data['specialty'] ?? data['title'] ?? 'Uzman',
              photoUrl: data['photo_url'] ?? data['image'],
              bio: data['bio'],
              gender: data['gender'],
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
          }).toList();

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: displaySpecialists.length,
      itemBuilder: (context, index) {
        final specialist = displaySpecialists[index];
        final expert = Expert(
          id: specialist.id,
          name: specialist.name,
          title: specialist.profession,
          photoUrl: specialist.photoUrl,
          specialty: specialist.profession,
          gender: specialist.gender,
        );

        return ExpertCard(
          expert: expert,
          onTap: () => _showSpecialistDetails(context, specialist),
        );
      },
    );
  }

  void _showSpecialistDetails(BuildContext context, Specialist specialist) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SpecialistDetailBottomSheet(specialist: specialist),
    );
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:guzellik_app/core/utils/avatar_utils.dart';
import 'package:guzellik_app/core/theme/app_colors.dart';

void main() {
  group('AvatarUtils.getAvatarBackgroundColor', () {
    test('returns male color for "male"', () {
      expect(
        AvatarUtils.getAvatarBackgroundColor('male'),
        AppColors.avatarMale,
      );
    });

    test('returns male color for "MALE" (case-insensitive)', () {
      expect(
        AvatarUtils.getAvatarBackgroundColor('MALE'),
        AppColors.avatarMale,
      );
    });

    test('returns male color for "erkek"', () {
      expect(
        AvatarUtils.getAvatarBackgroundColor('erkek'),
        AppColors.avatarMale,
      );
    });

    test('returns male color for "e"', () {
      expect(AvatarUtils.getAvatarBackgroundColor('e'), AppColors.avatarMale);
    });

    test('returns female color for "female"', () {
      expect(
        AvatarUtils.getAvatarBackgroundColor('female'),
        AppColors.avatarFemale,
      );
    });

    test('returns female color for "kadın"', () {
      expect(
        AvatarUtils.getAvatarBackgroundColor('kadın'),
        AppColors.avatarFemale,
      );
    });

    test('returns female color for "f"', () {
      expect(AvatarUtils.getAvatarBackgroundColor('f'), AppColors.avatarFemale);
    });

    test('returns female color for "k"', () {
      expect(AvatarUtils.getAvatarBackgroundColor('k'), AppColors.avatarFemale);
    });

    test('returns neutral color for null', () {
      expect(
        AvatarUtils.getAvatarBackgroundColor(null),
        AppColors.avatarNeutral,
      );
    });

    test('returns neutral color for empty string', () {
      expect(AvatarUtils.getAvatarBackgroundColor(''), AppColors.avatarNeutral);
    });

    test('returns neutral color for unknown gender', () {
      expect(
        AvatarUtils.getAvatarBackgroundColor('other'),
        AppColors.avatarNeutral,
      );
    });
  });

  group('AvatarUtils.getAvatarIconColor', () {
    test('returns male icon color for "male"', () {
      expect(AvatarUtils.getAvatarIconColor('male'), AppColors.avatarMaleIcon);
    });

    test('returns female icon color for "female"', () {
      expect(
        AvatarUtils.getAvatarIconColor('female'),
        AppColors.avatarFemaleIcon,
      );
    });

    test('returns neutral icon color for null', () {
      expect(AvatarUtils.getAvatarIconColor(null), AppColors.avatarNeutralIcon);
    });
  });
}

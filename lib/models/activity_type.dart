enum ActivityType {
  football,
  aerobics,
  jogging,
  yoga,
  gym,
  swimming,
  basketball,
  tennis,
  hiking,
  cycling,
}

extension ActivityTypeExtension on ActivityType {
  String get displayName {
    switch (this) {
      case ActivityType.football:
        return 'Football';
      case ActivityType.aerobics:
        return 'Aerobics';
      case ActivityType.jogging:
        return 'Jogging';
      case ActivityType.yoga:
        return 'Yoga';
      case ActivityType.gym:
        return 'Gym';
      case ActivityType.swimming:
        return 'Swimming';
      case ActivityType.basketball:
        return 'Basketball';
      case ActivityType.tennis:
        return 'Tennis';
      case ActivityType.hiking:
        return 'Hiking';
      case ActivityType.cycling:
        return 'Cycling';
    }
  }

  String get emoji {
    switch (this) {
      case ActivityType.football:
        return '⚽';
      case ActivityType.aerobics:
        return '💃';
      case ActivityType.jogging:
        return '🏃';
      case ActivityType.yoga:
        return '🧘';
      case ActivityType.gym:
        return '🏋️';
      case ActivityType.swimming:
        return '🏊';
      case ActivityType.basketball:
        return '🏀';
      case ActivityType.tennis:
        return '🎾';
      case ActivityType.hiking:
        return '🥾';
      case ActivityType.cycling:
        return '🚴';
    }
  }
}

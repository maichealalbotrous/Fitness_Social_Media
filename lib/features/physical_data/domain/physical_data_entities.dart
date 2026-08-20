enum PhysicalSex { male, female }

extension PhysicalSexX on PhysicalSex {
  String get apiValue => this == PhysicalSex.male ? 'Male' : 'Female';
  String get label => this == PhysicalSex.male ? 'Male' : 'Female';
  static PhysicalSex? fromApi(String? value) {
    if (value == null) return null;
    return value.toLowerCase() == 'female' ? PhysicalSex.female : value.toLowerCase() == 'male' ? PhysicalSex.male : null;
  }
}

class WeightEntry {
  const WeightEntry({required this.weightKg, required this.addedAt});
  final double weightKg;
  final DateTime addedAt;
}

class PersonalRecord {
  const PersonalRecord({required this.exerciseId, required this.exerciseName, required this.maxWeightKg, required this.date});
  final String exerciseId;
  final String exerciseName;
  final double maxWeightKg;
  final DateTime date;
}

class UserPhysicalData {
  const UserPhysicalData({required this.userId, this.heightCm, required this.heightIsPrivate, required this.weights, required this.weightsIsPrivate, this.sex, required this.sexIsPrivate, this.birthday, required this.birthdayIsPrivate, required this.personalRecords, required this.personalRecordsIsPrivate});
  final String userId;
  final double? heightCm;
  final bool heightIsPrivate;
  final List<WeightEntry> weights;
  final bool weightsIsPrivate;
  final PhysicalSex? sex;
  final bool sexIsPrivate;
  final DateTime? birthday;
  final bool birthdayIsPrivate;
  final List<PersonalRecord> personalRecords;
  final bool personalRecordsIsPrivate;
}

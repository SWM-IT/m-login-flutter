sealed class MLoginVerificationType {
  const MLoginVerificationType();

  String get anchor;
}

class PhotoVerification extends MLoginVerificationType {
  const PhotoVerification();

  @override
  String get anchor => 'photo';
}

class DriverLicenseVerification extends MLoginVerificationType {
  const DriverLicenseVerification();

  @override
  String get anchor => 'driver_license';
}

class StudentStatusVerification extends MLoginVerificationType {
  const StudentStatusVerification();

  @override
  String get anchor => 'student';
}

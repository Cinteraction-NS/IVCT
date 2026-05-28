

import '../../../../domain/entities/user.dart';
import '../provider/user_mock_provider.dart';

class ProfileRepository {
  const ProfileRepository({
    required this.profileProvider,
  });

  final ProfileProvider profileProvider;

  Stream<User?> getUserStream() {
    return profileProvider.getUserStream();
  }

  void logOut() {
    profileProvider.triggerLoggedOut();
  }
}

import '../../../../core/utils/result.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class RevokeDeviceUseCase {
  final ProfileRepository _repository;

  RevokeDeviceUseCase(this._repository);

  Future<Result<UserProfile>> call(String deviceId) async {
    return await _repository.revokeDevice(deviceId);
  }
}

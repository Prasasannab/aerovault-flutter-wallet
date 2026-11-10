import '../../../../core/utils/result.dart';
import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<Result<UserProfile>> getUserProfile();
  Future<Result<UserProfile>> updateLimits({
    required double dailyWireLimit,
    required double monthlyCardCap,
  });
  Future<Result<UserProfile>> revokeDevice(String deviceId);
}

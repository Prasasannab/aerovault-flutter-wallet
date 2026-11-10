import '../../../../core/utils/result.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class UpdateTransferLimitsUseCase {
  final ProfileRepository _repository;

  UpdateTransferLimitsUseCase(this._repository);

  Future<Result<UserProfile>> call({
    required double dailyWireLimit,
    required double monthlyCardCap,
  }) async {
    return await _repository.updateLimits(
      dailyWireLimit: dailyWireLimit,
      monthlyCardCap: monthlyCardCap,
    );
  }
}

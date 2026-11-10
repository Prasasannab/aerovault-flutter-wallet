import '../../../../core/utils/result.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class GetUserProfileUseCase {
  final ProfileRepository _repository;

  GetUserProfileUseCase(this._repository);

  Future<Result<UserProfile>> call() async {
    return await _repository.getUserProfile();
  }
}

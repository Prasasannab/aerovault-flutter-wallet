import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileDataSource _dataSource;

  ProfileRepositoryImpl(this._dataSource);

  @override
  Future<Result<UserProfile>> getUserProfile() async {
    try {
      final profile = await _dataSource.getUserProfile();
      return Result.success(profile);
    } on ServerException catch (e) {
      return Result.error(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Result.error(ServerFailure(message: 'Failed to retrieve profile: $e'));
    }
  }

  @override
  Future<Result<UserProfile>> updateLimits({
    required double dailyWireLimit,
    required double monthlyCardCap,
  }) async {
    try {
      final profile = await _dataSource.updateLimits(
        dailyWireLimit: dailyWireLimit,
        monthlyCardCap: monthlyCardCap,
      );
      return Result.success(profile);
    } on ServerException catch (e) {
      return Result.error(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Result.error(ServerFailure(message: 'Failed to update banking limits: $e'));
    }
  }

  @override
  Future<Result<UserProfile>> revokeDevice(String deviceId) async {
    try {
      final profile = await _dataSource.revokeDevice(deviceId);
      return Result.success(profile);
    } on ServerException catch (e) {
      return Result.error(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Result.error(ServerFailure(message: 'Failed to revoke device: $e'));
    }
  }
}

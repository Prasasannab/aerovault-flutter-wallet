import '../../../../core/utils/result.dart';
import '../entities/concierge_session.dart';

abstract class ConciergeRepository {
  Future<Result<ConciergeSession>> getSession();
  Future<Result<ConciergeSession>> sendMessage(String text);
  Future<Result<ConciergeSession>> resetSession();
}

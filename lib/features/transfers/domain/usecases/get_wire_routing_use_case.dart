import '../../../../core/utils/result.dart';
import '../entities/wire_routing_info.dart';
import '../repositories/transfers_repository.dart';

class GetWireRoutingUseCase {
  final TransfersRepository repository;

  const GetWireRoutingUseCase(this.repository);

  Future<Result<WireRoutingInfo>> call() => repository.getWireRoutingInfo();
}

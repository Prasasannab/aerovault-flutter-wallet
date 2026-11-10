import '../../../../core/utils/result.dart';
import '../entities/fx_rate.dart';
import '../repositories/transfers_repository.dart';

class GetFxRatesUseCase {
  final TransfersRepository repository;

  const GetFxRatesUseCase(this.repository);

  Future<Result<List<FxRate>>> call() => repository.getFxRates();
}

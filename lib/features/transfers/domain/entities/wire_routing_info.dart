import 'package:equatable/equatable.dart';

/// Banking wire specifications for international SWIFT, SEPA, and Fedwire transfers
class WireRoutingInfo extends Equatable {
  final String institutionName;
  final String swissIban;
  final String swiftBic;
  final String clearingCode;
  final String fedwireRouting;
  final String accountHolder;
  final String address;

  const WireRoutingInfo({
    required this.institutionName,
    required this.swissIban,
    required this.swiftBic,
    required this.clearingCode,
    required this.fedwireRouting,
    required this.accountHolder,
    required this.address,
  });

  @override
  List<Object?> get props => [
        institutionName,
        swissIban,
        swiftBic,
        clearingCode,
        fedwireRouting,
        accountHolder,
        address,
      ];
}

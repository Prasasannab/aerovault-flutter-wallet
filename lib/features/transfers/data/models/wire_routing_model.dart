import '../../domain/entities/wire_routing_info.dart';

class WireRoutingModel extends WireRoutingInfo {
  const WireRoutingModel({
    required super.institutionName,
    required super.swissIban,
    required super.swiftBic,
    required super.clearingCode,
    required super.fedwireRouting,
    required super.accountHolder,
    required super.address,
  });

  factory WireRoutingModel.fromJson(Map<String, dynamic> json) {
    return WireRoutingModel(
      institutionName: json['institutionName'] as String,
      swissIban: json['swissIban'] as String,
      swiftBic: json['swiftBic'] as String,
      clearingCode: json['clearingCode'] as String,
      fedwireRouting: json['fedwireRouting'] as String,
      accountHolder: json['accountHolder'] as String,
      address: json['address'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'institutionName': institutionName,
      'swissIban': swissIban,
      'swiftBic': swiftBic,
      'clearingCode': clearingCode,
      'fedwireRouting': fedwireRouting,
      'accountHolder': accountHolder,
      'address': address,
    };
  }
}

import 'package:flutter/foundation.dart';
import 'package:monetization/src/models/entitlement.dart';
import 'package:monetization/src/services/monetization_service.dart';

abstract class EntitlementService extends ChangeNotifier {
  bool has(Entitlement entitlement);
}

class MonetizationEntitlementService extends EntitlementService {
  MonetizationEntitlementService({
    required MonetizationService monetizationService,
    Set<Entitlement> freeEntitlements = const <Entitlement>{},
    Set<Entitlement> premiumEntitlements = const <Entitlement>{},
  }) : _monetizationService = monetizationService,
       _freeEntitlements = Set<Entitlement>.unmodifiable(freeEntitlements),
       _premiumEntitlements = Set<Entitlement>.unmodifiable(
         premiumEntitlements,
       ) {
    _monetizationService.addListener(_handleMonetizationChanged);
  }

  final MonetizationService _monetizationService;
  final Set<Entitlement> _freeEntitlements;
  final Set<Entitlement> _premiumEntitlements;

  @override
  bool has(Entitlement entitlement) {
    if (_freeEntitlements.contains(entitlement)) {
      return true;
    }

    return _monetizationService.isPremium &&
        _premiumEntitlements.contains(entitlement);
  }

  void _handleMonetizationChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _monetizationService.removeListener(_handleMonetizationChanged);
    super.dispose();
  }
}

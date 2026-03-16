import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'package:monetization/src/paywall/paywall_controller.dart';
import 'package:ui_kit/ui_kit.dart';

Future<void> showPaywallSheet({
  required BuildContext context,
  required PaywallController controller,
}) async {
  await controller.initialize();

  if (!context.mounted) {
    controller.dispose();
    return;
  }

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.background,
    builder: (BuildContext context) {
      return _PaywallSheet(controller: controller);
    },
  );

  controller.dispose();
}

class _PaywallSheet extends StatelessWidget {
  const _PaywallSheet({required this.controller});

  final PaywallController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) {
        final ThemeData theme = Theme.of(context);
        final monthlyProduct = controller.monthlyProduct;
        final yearlyProduct = controller.yearlyProduct;

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.xl,
              right: AppSpacing.xl,
              top: AppSpacing.lg,
              bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          controller.content.title,
                          style: theme.textTheme.headlineMedium,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    controller.content.subtitle,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    controller.content.freeTierNote,
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  PremiumCalloutCard(
                    title: 'Premium keeps the experience focused',
                    subtitle:
                        'Remove light banner ads and unlock advanced features without changing the calm core flow.',
                    badgeLabel: 'Upgrade',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SectionCard(
                    title: 'Premium unlocks',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: controller.content.benefits
                          .map(
                            (String benefit) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.sm,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  const Padding(
                                    padding: EdgeInsets.only(top: 2),
                                    child: Icon(
                                      Icons.check_circle_rounded,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(child: Text(benefit)),
                                ],
                              ),
                            ),
                          )
                          .toList(growable: false),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SectionCard(
                    title: 'Choose a plan',
                    subtitle:
                        controller.isPremium
                            ? 'Premium is already active.'
                            : 'Subscriptions remove ads and unlock the advanced tools. Free use stays available.',
                    child: Column(
                      children: <Widget>[
                        AppPrimaryButton(
                          label:
                              'Monthly  ${monthlyProduct?.priceLabel ?? controller.content.monthlyFallbackPrice}',
                          onPressed:
                              controller.isBusy || controller.isPremium
                                  ? null
                                  : controller.purchaseMonthly,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppSecondaryButton(
                          label:
                              'Yearly  ${yearlyProduct?.priceLabel ?? controller.content.yearlyFallbackPrice}',
                          onPressed:
                              controller.isBusy || controller.isPremium
                                  ? null
                                  : controller.purchaseYearly,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppSecondaryButton(
                          label: controller.content.restoreLabel,
                          icon: const Icon(Icons.restore_rounded),
                          onPressed:
                              controller.isBusy
                                  ? null
                                  : controller.restorePurchases,
                        ),
                        if (controller.message case final String message
                            when message.isNotEmpty) ...<Widget>[
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            message,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(controller.content.closeLabel),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

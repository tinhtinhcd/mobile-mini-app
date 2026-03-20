import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

class AppDrawerItem {
  const AppDrawerItem({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
}

class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.title,
    this.trailing,
    this.hasDrawer = false,
  });

  final String title;
  final Widget? trailing;
  final bool hasDrawer;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;

    return Material(
      color: theme.colorScheme.surface,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.65),
            ),
          ),
        ),
        child: SizedBox(
          height: AppShellMetrics.headerHeight,
          child: Row(
            children: <Widget>[
              if (hasDrawer)
                Builder(
                  builder:
                      (BuildContext context) => IconButton(
                        tooltip: l10n.shellOpenMenuTooltip,
                        icon: const Icon(Icons.menu_rounded),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                )
              else
                const SizedBox(width: AppSpacing.xxxl + AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: trailing ?? const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.title,
    required this.body,
    this.headerTrailing,
    this.footer,
    this.drawerItems = const <AppDrawerItem>[],
    this.scrollable = true,
    this.contentMaxWidth = 720,
    this.contentPadding,
  });

  final String title;
  final Widget body;
  final Widget? headerTrailing;
  final Widget? footer;
  final List<AppDrawerItem> drawerItems;
  final bool scrollable;
  final double contentMaxWidth;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool hasDrawer = drawerItems.isNotEmpty;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: hasDrawer ? AppDrawer(title: title, items: drawerItems) : null,
      body: Column(
        children: <Widget>[
          SafeArea(
            bottom: false,
            child: AppHeader(
              title: title,
              trailing: headerTrailing,
              hasDrawer: hasDrawer,
            ),
          ),
          Expanded(
            child: AppContentFrame(
              maxWidth: contentMaxWidth,
              scrollable: scrollable,
              includeTopSafeArea: false,
              includeBottomSafeArea: false,
              contentPadding: contentPadding,
              child: body,
            ),
          ),
          AppFooter(child: footer),
        ],
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, required this.title, required this.items});

  final String title;
  final List<AppDrawerItem> items;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;

    return Drawer(
      width: AppShellMetrics.drawerWidth,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xs,
                AppSpacing.xs,
                AppSpacing.xs,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: theme.textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    l10n.shellUtilityAppMenu,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            for (final AppDrawerItem item in items) ...<Widget>[
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                leading: Icon(item.icon, size: AppIconSize.large),
                title: Text(item.label),
                onTap: () {
                  Navigator.of(context).pop();
                  item.onTap();
                },
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
          ],
        ),
      ),
    );
  }
}

class AppFooter extends StatelessWidget {
  const AppFooter({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool hasCustomFooter = child != null;

    return SafeArea(
      top: false,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Color.alphaBlend(
            theme.colorScheme.primary.withValues(alpha: 0.025),
            theme.colorScheme.surface,
          ),
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.75),
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: hasCustomFooter ? AppSpacing.xxs : AppSpacing.xs,
          ),
          child: Center(
            child:
                child ??
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: AppShellMetrics.footerHeight,
                  ),
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.55,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                  ),
                ),
          ),
        ),
      ),
    );
  }
}

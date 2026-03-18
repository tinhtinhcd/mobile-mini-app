import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

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

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
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
  Size get preferredSize => const Size.fromHeight(AppShellMetrics.headerHeight);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: AppShellMetrics.headerHeight,
      titleSpacing: AppSpacing.xs,
      leading:
          hasDrawer
              ? Builder(
                builder:
                    (BuildContext context) => IconButton(
                      tooltip: 'Open menu',
                      icon: const Icon(Icons.menu_rounded),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
              )
              : null,
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurface,
        ),
      ),
      actions:
          trailing == null
              ? null
              : <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: Center(child: trailing!),
                ),
              ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(
          height: 1,
          thickness: 1,
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.65),
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
  });

  final String title;
  final Widget body;
  final Widget? headerTrailing;
  final Widget? footer;
  final List<AppDrawerItem> drawerItems;
  final bool scrollable;
  final double contentMaxWidth;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool hasDrawer = drawerItems.isNotEmpty;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppHeader(
        title: title,
        trailing: headerTrailing,
        hasDrawer: hasDrawer,
      ),
      drawer: hasDrawer ? AppDrawer(title: title, items: drawerItems) : null,
      body: AppContentFrame(
        maxWidth: contentMaxWidth,
        scrollable: scrollable,
        includeTopSafeArea: false,
        includeBottomSafeArea: false,
        child: body,
      ),
      bottomNavigationBar: AppFooter(child: footer),
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
                  Text('Utility app menu', style: theme.textTheme.bodySmall),
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
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppShellMetrics.footerHeight,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            child: Center(
              child:
                  child ??
                  Container(
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
    );
  }
}

import 'package:flutter/material.dart';

import '../products/products_screen.dart';
import '../marketing_studio/marketing_studio_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String businessName;
  final String category;

  const DashboardScreen({
    super.key,
    required this.businessName,
    required this.category,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const Color primary = Color(0xFFFF6D1F);
  static const Color dark = Color(0xFF222222);
  static const Color muted = Color(0x99222222);
  static const Color background = Color(0xFFFAF3E1);
  static const Color surface = Color(0xFFF5E7C6);

  static const List<BoxShadow> _softShadow = [
    BoxShadow(color: Color(0x14222222), blurRadius: 16, offset: Offset(0, 6)),
  ];

  int _selectedIndex = 0;

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature is coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openProducts() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProductsScreen()),
    );
  }

  void _openMarketing() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MarketingStudioScreen()),
    );
  }

  void _onNavigationTap(int index) {
    if (index == 0) {
      setState(() => _selectedIndex = 0);
    } else if (index == 1) {
      _openProducts();
    } else if (index == 2) {
      _openMarketing();
    } else {
      _showComingSoon('Profile');
    }
  }

  Widget _surfaceCard({
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    double radius = 20,
    Color color = surface,
    Border? border,
  }) {
    final borderRadius = BorderRadius.circular(radius);

    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
        border: border,
        boxShadow: _softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'GOOD MORNING 👋',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: muted,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.businessName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: dark,
                  height: 1.15,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: primary.withValues(alpha: 0.55)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        widget.category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: dark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: primary,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => _showComingSoon('Business profile'),
              child: const Icon(
                Icons.storefront_rounded,
                color: dark,
                size: 26,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGrowthBanner({required bool desktop}) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: dark,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33222222),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: -34,
            bottom: -54,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: -36,
            top: -36,
            child: Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const Positioned(
            right: 14,
            top: 14,
            child: Icon(Icons.rocket_launch_rounded, size: 36, color: dark),
          ),
          Padding(
            padding: EdgeInsets.all(desktop ? 30 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'YOUR GROWTH JOURNEY',
                    style: TextStyle(
                      color: primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  desktop
                      ? 'Ready to grow your business?'
                      : 'Ready to grow\nyour business?',
                  style: TextStyle(
                    color: background,
                    fontSize: desktop ? 28 : 24,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Create content, showcase products and reach more customers.',
                  style: TextStyle(
                    color: background.withValues(alpha: 0.8),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: _openMarketing,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: dark,
                    elevation: 0,
                    minimumSize: const Size(0, 48),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Explore AI Marketing',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeading(String title, String action) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: dark,
                letterSpacing: -0.2,
              ),
            ),
          ),
          TextButton(
            onPressed: () => _showComingSoon(action),
            style: TextButton.styleFrom(
              foregroundColor: dark,
              minimumSize: const Size(48, 44),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'View all',
                  style: TextStyle(
                    color: dark,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, color: primary, size: 15),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    Color iconColor = dark,
  }) {
    return _surfaceCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 14),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: dark,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: dark,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: muted, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    Color iconColor = dark,
    Border? tileBorder,
  }) {
    return _surfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
              border: tileBorder,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: dark,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: background,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_forward_rounded,
              color: dark,
              size: 17,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard() {
    return _surfaceCard(
      padding: const EdgeInsets.all(16),
      border: Border.all(color: primary.withValues(alpha: 0.4), width: 1.2),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TipIcon(),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Growth tip of the day',
                  style: TextStyle(
                    color: dark,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Add clear product photos and detailed descriptions to help customers understand what you offer.',
                  style: TextStyle(color: muted, fontSize: 12, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return _surfaceCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.storefront_outlined, color: dark, size: 21),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to UdyamBoost!',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: dark,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Your business journey starts here.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: muted, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.check_circle, color: primary, size: 22),
        ],
      ),
    );
  }

  Widget _buildStats(double width) {
    final cards = [
      _buildStatCard(
        title: 'Products',
        value: '0',
        subtitle: 'In catalogue',
        icon: Icons.inventory_2_outlined,
        color: primary,
      ),
      _buildStatCard(
        title: 'Content',
        value: '0',
        subtitle: 'Created',
        icon: Icons.auto_awesome_outlined,
        color: dark,
        iconColor: background,
      ),
      _buildStatCard(
        title: 'Reach',
        value: '0',
        subtitle: 'Interactions',
        icon: Icons.trending_up_rounded,
        color: primary.withValues(alpha: 0.28),
      ),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < cards.length; i++) ...[
          Expanded(child: cards[i]),
          if (i != cards.length - 1) SizedBox(width: width < 500 ? 8 : 14),
        ],
      ],
    );
  }

  Widget _buildQuickActions(double width) {
    final columns = width >= 1100
        ? 3
        : width >= 650
        ? 2
        : 1;
    const spacing = 14.0;
    final itemWidth = (width - spacing * (columns - 1)) / columns;

    final actions = [
      _buildQuickAction(
        title: 'Add a product',
        description: 'Build your digital product catalogue',
        icon: Icons.add_box_outlined,
        color: primary,
        onTap: () => _showComingSoon('Product catalogue'),
      ),
      _buildQuickAction(
        title: 'AI Marketing Assistant',
        description: 'Generate captions and promotions',
        icon: Icons.auto_awesome,
        color: dark,
        iconColor: background,
        onTap: _openMarketing,
      ),
      _buildQuickAction(
        title: 'Create a poster',
        description: 'Design attractive business posters',
        icon: Icons.palette_outlined,
        color: background,
        tileBorder: Border.all(color: primary, width: 1.5),
        onTap: () => _showComingSoon('Poster Creator'),
      ),
    ];

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: actions.map((action) {
        return SizedBox(width: itemWidth, child: action);
      }).toList(),
    );
  }

  Widget _buildHomeContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final desktop = availableWidth >= 1000;
        final horizontalPadding = availableWidth >= 1200
            ? 36.0
            : availableWidth >= 700
            ? 28.0
            : 20.0;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            24,
            horizontalPadding,
            40,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 26),
                  _buildGrowthBanner(desktop: desktop),
                  const SizedBox(height: 32),

                  _buildSectionHeading('Business overview', 'Analytics'),
                  _buildStats(availableWidth),
                  const SizedBox(height: 32),

                  _buildSectionHeading('Quick actions', 'Features'),
                  _buildQuickActions(availableWidth),
                  const SizedBox(height: 32),

                  _buildSectionHeading('Grow your business', 'Tips'),
                  _buildTipCard(),
                  const SizedBox(height: 32),

                  _buildSectionHeading('Recent activity', 'Activity'),
                  _buildRecentActivity(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final selected = _selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      child: Material(
        color: selected ? primary : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _onNavigationTap(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: selected ? dark : muted, size: 21),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? dark : muted,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopSidebar() {
    return Container(
      width: 240,
      decoration: const BoxDecoration(
        color: surface,
        border: Border(right: BorderSide(color: Color(0x1A222222), width: 1)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 24, 18, 32),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.storefront_rounded,
                      color: dark,
                      size: 23,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Flexible(
                    child: Text(
                      'UdyamBoost',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: dark,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(22, 0, 12, 12),
              child: Text(
                'MENU',
                style: TextStyle(
                  color: muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.3,
                ),
              ),
            ),
            _buildNavItem(icon: Icons.home_rounded, label: 'Home', index: 0),
            _buildNavItem(
              icon: Icons.inventory_2_outlined,
              label: 'Products',
              index: 1,
            ),
            _buildNavItem(
              icon: Icons.add_circle_outline_rounded,
              label: 'Create',
              index: 2,
            ),
            _buildNavItem(
              icon: Icons.person_outline_rounded,
              label: 'Profile',
              index: 3,
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_outline_rounded, color: primary),
                    SizedBox(height: 8),
                    Text(
                      'Grow your business',
                      style: TextStyle(
                        color: dark,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Create content and reach more customers.',
                      style: TextStyle(color: muted, fontSize: 11, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavPill(IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: dark, size: 22),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: const BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1F222222),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onNavigationTap,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            selectedItemColor: primary,
            unselectedItemColor: muted,
            selectedFontSize: 11,
            unselectedFontSize: 11,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined),
                activeIcon: _buildNavPill(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.inventory_2_outlined),
                activeIcon: _buildNavPill(Icons.inventory_2_rounded),
                label: 'Products',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.add_circle_outline_rounded),
                activeIcon: _buildNavPill(Icons.add_circle_rounded),
                label: 'Create',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_outline_rounded),
                activeIcon: _buildNavPill(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 1000;

        return Scaffold(
          backgroundColor: background,
          body: SafeArea(
            child: desktop
                ? Row(
                    children: [
                      _buildDesktopSidebar(),
                      Expanded(child: _buildHomeContent()),
                    ],
                  )
                : _buildHomeContent(),
          ),
          bottomNavigationBar: desktop ? null : _buildBottomNavigation(),
        );
      },
    );
  }
}

class _TipIcon extends StatelessWidget {
  const _TipIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: _DashboardScreenState.primary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(
        Icons.lightbulb_outline_rounded,
        color: _DashboardScreenState.dark,
        size: 24,
      ),
    );
  }
}

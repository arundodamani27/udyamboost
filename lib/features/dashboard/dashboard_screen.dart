
import 'package:flutter/material.dart';
import '../products/products_screen.dart';

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
  static const Color primary = Color(0xFF2457E6);
  static const Color dark = Color(0xFF14213D);
  static const Color muted = Color(0xFF64748B);
  static const Color background = Color(0xFFF7F9FC);

  int _selectedIndex = 0;

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature is coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
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
                  letterSpacing: 1,
                  color: muted,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.businessName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: dark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.category,
                style: const TextStyle(
                  fontSize: 12,
                  color: muted,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => _showComingSoon('Business profile'),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF0FF),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.storefront_rounded,
              color: primary,
              size: 25,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGrowthBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2457E6),
            Color(0xFF4778F5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -18,
            child: Icon(
              Icons.rocket_launch_rounded,
              size: 115,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.17),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'YOUR GROWTH JOURNEY',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Ready to grow\nyour business?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                'Create content, showcase products and reach more customers.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 17),
              ElevatedButton(
                onPressed: () => _showComingSoon('AI Marketing'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 11,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Explore AI Marketing',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(width: 7),
                    Icon(Icons.arrow_forward_rounded, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeading(String title, String action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: dark,
          ),
        ),
        TextButton(
          onPressed: () => _showComingSoon(action),
          child: const Text(
            'View all',
            style: TextStyle(
              color: primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: const Color(0xFFEAEFF5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: color, size: 19),
            ),
            const SizedBox(height: 13),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: dark,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              title,
              style: const TextStyle(
                color: dark,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: muted,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: const Color(0xFFEAEFF5)),
        ),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: color, size: 23),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: dark,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      color: muted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: muted,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFEFFBF5),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFD6F3E3)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            color: Color(0xFF059669),
            size: 25,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Growth tip of the day',
                  style: TextStyle(
                    color: Color(0xFF047857),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Add clear product photos and detailed descriptions to help customers understand what you offer.',
                  style: TextStyle(
                    color: Color(0xFF365B4C),
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFEAEFF5)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 39,
                height: 39,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF0FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.storefront_outlined,
                  color: primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to UdyamBoost!',
                      style: TextStyle(
                        color: dark,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Your business journey starts here.',
                      style: TextStyle(
                        color: muted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.check_circle,
                color: Color(0xFF10B981),
                size: 19,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 23),
          _buildGrowthBanner(),
          const SizedBox(height: 25),

          _buildSectionHeading('Business overview', 'Analytics'),
          Row(
            children: [
              _buildStatCard(
                title: 'Products',
                value: '0',
                subtitle: 'In catalogue',
                icon: Icons.inventory_2_outlined,
                color: primary,
              ),
              const SizedBox(width: 11),
              _buildStatCard(
                title: 'Content',
                value: '0',
                subtitle: 'Created',
                icon: Icons.auto_awesome_outlined,
                color: const Color(0xFF8B5CF6),
              ),
              const SizedBox(width: 11),
              _buildStatCard(
                title: 'Reach',
                value: '0',
                subtitle: 'Interactions',
                icon: Icons.trending_up_rounded,
                color: const Color(0xFF10B981),
              ),
            ],
          ),

          const SizedBox(height: 24),
          _buildSectionHeading('Quick actions', 'Features'),
          _buildQuickAction(
            title: 'Add a product',
            description: 'Build your digital product catalogue',
            icon: Icons.add_box_outlined,
            color: primary,
            onTap: () => _showComingSoon('Product catalogue'),
          ),
          const SizedBox(height: 11),
          _buildQuickAction(
            title: 'AI Marketing Assistant',
            description: 'Generate captions and promotions',
            icon: Icons.auto_awesome,
            color: const Color(0xFF8B5CF6),
            onTap: () => _showComingSoon('AI Marketing Assistant'),
          ),
          const SizedBox(height: 11),
          _buildQuickAction(
            title: 'Create a poster',
            description: 'Design attractive business posters',
            icon: Icons.palette_outlined,
            color: const Color(0xFFF97316),
            onTap: () => _showComingSoon('Poster Creator'),
          ),

          const SizedBox(height: 24),
          _buildSectionHeading('Grow your business', 'Tips'),
          _buildTipCard(),

          const SizedBox(height: 24),
          _buildSectionHeading('Recent activity', 'Activity'),
          _buildRecentActivity(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: _buildHomeContent(),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xFFEAEFF5)),
          ),
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
  if (index == 1) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProductsScreen(),
      ),
    );
    return;
  }

  if (index == 0) {
    setState(() => _selectedIndex = 0);
    return;
  }

  const labels = ['Home', 'Products', 'Create', 'Profile'];
  _showComingSoon(labels[index]);
},
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: primary,
            unselectedItemColor: muted,
            selectedFontSize: 10,
            unselectedFontSize: 10,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.inventory_2_outlined),
                label: 'Products',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_circle_outline_rounded),
                label: 'Create',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

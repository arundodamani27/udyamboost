import 'package:flutter/material.dart';
import 'app_theme.dart';
import '../features/onboarding/brand_identity_screen.dart';
import '../features/authentication/signup_screen.dart';
import '../features/authentication/login_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BRAND PALETTE (shared by every screen in this file)
// ─────────────────────────────────────────────────────────────────────────────
class _Palette {
  static const Color cream = Color(0xFFFAF3E1);
  static const Color beige = Color(0xFFF5E7C6);
  static const Color tangerine = Color(0xFFFF6D1F);
  static const Color charcoal = Color(0xFF222222);

  // Tints of charcoal (for light backgrounds).
  static const Color muted = Color(0xB3222222); // ~70%
  static const Color subtle = Color(0x73222222); // ~45%
  static const Color line = Color(0x24222222); // ~14%

  // Tints of cream (for charcoal backgrounds).
  static const Color creamMuted = Color(0xB8FAF3E1); // ~72%
  static const Color creamLine = Color(0x33FAF3E1); // ~20%
  static const Color creamFaint = Color(0x14FAF3E1); // ~8%

  // Darker shade of the brand orange, used only for validation errors so
  // they stay readable on cream.
  static const Color error = Color(0xFFB83A0A);
}

/// Width at which pages switch to their full desktop layouts.
const double _splitBreakpoint = 960;

/// Pane width at which the onboarding form pairs fields side by side.
const double _pairBreakpoint = 680;

/// Maximum width of inner content (backgrounds always span the full screen).
const double _contentMaxWidth = 1200;

/// Responsive helper derived from the available width.
class _Ui {
  const _Ui(this.width);

  final double width;

  bool get wide => width >= _splitBreakpoint;
  bool get threeCol => width >= 760;
  bool get roomy => width >= 640;
  bool get showNavCta => width >= 480;

  double get pad => wide ? 48 : (roomy ? 32 : 20);
  double get sectionV => wide ? 96 : (roomy ? 72 : 56);

  double get h1 {
    if (width >= 1280) return 60;
    if (width >= 1100) return 54;
    if (width >= 640) return 46;
    return 36;
  }

  double get h2 => wide ? 40 : (roomy ? 34 : 28);
}

class UdyamBoostApp extends StatelessWidget {
  const UdyamBoostApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UdyamBoost',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const WelcomeScreen(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────────────────
class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    this.fullWidth = true,
    this.compact = false,
    this.dark = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool fullWidth;
  final bool compact;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final double height = compact ? 40 : 56;

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: dark ? _Palette.charcoal : _Palette.tangerine,
          foregroundColor: dark ? _Palette.cream : _Palette.charcoal,
          elevation: 0,
          minimumSize: Size(0, height),
          padding: EdgeInsets.symmetric(horizontal: compact ? 18 : 28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(compact ? 10 : 12),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: compact ? 13.5 : 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.1,
              ),
            ),
            if (!compact) ...[
              const SizedBox(width: 10),
              const Icon(Icons.arrow_forward_rounded, size: 20),
            ],
          ],
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.label,
    required this.onPressed,
    this.fullWidth = true,
    this.compact = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool fullWidth;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final double height = compact ? 40 : 56;

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: _Palette.charcoal,
          minimumSize: Size(0, height),
          padding: EdgeInsets.symmetric(horizontal: compact ? 18 : 28),
          side: const BorderSide(color: _Palette.charcoal, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(compact ? 10 : 12),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: compact ? 13.5 : 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({this.compact = false, this.onDark = false});

  final bool compact;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final double size = compact ? 36 : 44;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            color: onDark ? _Palette.tangerine : _Palette.charcoal,
            borderRadius: BorderRadius.circular(compact ? 10 : 12),
          ),
          child: Icon(
            Icons.storefront_rounded,
            color: onDark ? _Palette.charcoal : _Palette.tangerine,
            size: compact ? 20 : 25,
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'UdyamBoost',
              style: TextStyle(
                fontSize: compact ? 18 : 21,
                fontWeight: FontWeight.w800,
                color: onDark ? _Palette.cream : _Palette.charcoal,
                letterSpacing: -0.6,
              ),
            ),
            if (!compact)
              Text(
                'GROW YOUR BUSINESS',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: onDark ? _Palette.creamMuted : _Palette.muted,
                  letterSpacing: 1.6,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Full-width coloured band with centred, width-limited inner content.
class _Band extends StatelessWidget {
  const _Band({
    required this.ui,
    required this.color,
    required this.child,
    this.vertical,
    this.topLine = false,
    this.bottomExtra = 0,
  });

  final _Ui ui;
  final Color color;
  final Widget child;
  final double? vertical;
  final bool topLine;
  final double bottomExtra;

  @override
  Widget build(BuildContext context) {
    final double v = vertical ?? ui.sectionV;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        border: topLine
            ? const Border(top: BorderSide(color: _Palette.line))
            : null,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: _contentMaxWidth + ui.pad * 2,
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(ui.pad, v, ui.pad, v + bottomExtra),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.ui,
    required this.eyebrow,
    required this.title,
    this.subtitle,
    this.onDark = false,
  });

  final _Ui ui;
  final String eyebrow;
  final String title;
  final String? subtitle;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final Color main = onDark ? _Palette.cream : _Palette.charcoal;
    final Color soft = onDark ? _Palette.creamMuted : _Palette.muted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(height: 3, width: 22, color: _Palette.tangerine),
            const SizedBox(width: 10),
            Text(
              eyebrow,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.6,
                color: main,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Text(
            title,
            style: TextStyle(
              fontSize: ui.h2,
              height: 1.12,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
              color: main,
            ),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Text(
              subtitle!,
              style: TextStyle(fontSize: 16, height: 1.6, color: soft),
            ),
          ),
        ],
      ],
    );
  }
}

/// Lays three items side by side on wide screens, stacked on narrow ones.
Widget _threeUp(_Ui ui, List<Widget> items) {
  if (ui.threeCol) {
    final double gap = ui.wide ? 48 : 28;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0) SizedBox(width: gap),
          Expanded(child: items[i]),
        ],
      ],
    );
  }
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (int i = 0; i < items.length; i++) ...[
        if (i > 0) const SizedBox(height: 36),
        items[i],
      ],
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// WELCOME SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _howKey = GlobalKey();

  void _openSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SignupScreen(),
      ),
    );
  }

  void _openLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  void _scrollTo(GlobalKey key) {
    final BuildContext? target = key.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Palette.cream,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final _Ui ui = _Ui(constraints.maxWidth);

          return Column(
            children: [
              SafeArea(bottom: false, child: _buildNav(ui)),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHero(ui),
                      KeyedSubtree(
                        key: _featuresKey,
                        child: _buildFeatures(ui),
                      ),
                      KeyedSubtree(
                        key: _howKey,
                        child: _buildHowItWorks(ui),
                      ),
                      _buildClosingCta(ui),
                      _buildFooter(ui),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── NAVIGATION BAR ─────────────────────────────────────────────────────────
  Widget _buildNav(_Ui ui) {
    final ButtonStyle linkStyle = TextButton.styleFrom(
      foregroundColor: _Palette.charcoal,
      textStyle: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    );

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: _Palette.cream,
        border: Border(bottom: BorderSide(color: _Palette.line)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: _contentMaxWidth + ui.pad * 2,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: ui.pad),
            child: SizedBox(
              height: ui.wide ? 76 : 64,
              child: Row(
                children: [
                  _Logo(compact: !ui.wide),
                  if (ui.wide) ...[
                    const SizedBox(width: 40),
                    TextButton(
                      style: linkStyle,
                      onPressed: () => _scrollTo(_featuresKey),
                      child: const Text('Features'),
                    ),
                    TextButton(
                      style: linkStyle,
                      onPressed: () => _scrollTo(_howKey),
                      child: const Text('How It Works'),
                    ),
                  ],
                  const Spacer(),
                  if (ui.showNavCta) ...[
                    TextButton(
                      style: linkStyle,
                      onPressed: _openLogin,
                      child: const Text('Login'),
                    ),
                    const SizedBox(width: 8),
                    _PrimaryButton(
                      label: 'Get Started',
                      compact: true,
                      fullWidth: false,
                      onPressed: _openSignup,
                    ),
                  ] else
                    _SecondaryButton(
                      label: 'Login',
                      compact: true,
                      fullWidth: false,
                      onPressed: _openLogin,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── HERO ───────────────────────────────────────────────────────────────────
  Widget _buildHero(_Ui ui) {
    final Widget text = _buildHeroText(ui);
    final Widget preview = _ProductPreview(roomy: ui.roomy);

    return _Band(
      ui: ui,
      color: _Palette.cream,
      vertical: ui.wide ? 80 : 40,
      child: ui.wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 11, child: text),
                const SizedBox(width: 64),
                Expanded(flex: 10, child: preview),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                text,
                const SizedBox(height: 40),
                preview,
              ],
            ),
    );
  }

  Widget _buildHeroText(_Ui ui) {
    final TextStyle headlineStyle = TextStyle(
      fontSize: ui.h1,
      height: 1.08,
      fontWeight: FontWeight.w800,
      color: _Palette.charcoal,
      letterSpacing: ui.h1 > 40 ? -1.8 : -1.1,
    );

    final Widget ctas = ui.roomy
        ? Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _PrimaryButton(
                label: 'Get Started',
                fullWidth: false,
                onPressed: _openSignup,
              ),
              _SecondaryButton(
                label: 'See How It Works',
                fullWidth: false,
                onPressed: () => _scrollTo(_howKey),
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PrimaryButton(label: 'Get Started', onPressed: _openSignup),
              const SizedBox(height: 12),
              _SecondaryButton(
                label: 'See How It Works',
                onPressed: () => _scrollTo(_howKey),
              ),
            ],
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _Palette.beige,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 7,
                width: 7,
                decoration: const BoxDecoration(
                  color: _Palette.tangerine,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 9),
              const Flexible(
                child: Text(
                  'YOUR DIGITAL GROWTH PARTNER',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: _Palette.charcoal,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text.rich(
          TextSpan(
            style: headlineStyle,
            children: [
              const TextSpan(text: 'Take your business from local to '),
              TextSpan(
                text: 'online.',
                style: headlineStyle.copyWith(
                  decoration: TextDecoration.underline,
                  decorationColor: _Palette.tangerine,
                  decorationThickness: 3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Text(
            'UdyamBoost brings an AI marketing assistant, a poster maker '
            'and a digital product catalogue together, so you can promote '
            'your business and reach more customers from one place.',
            style: TextStyle(
              fontSize: ui.wide ? 18 : 16,
              height: 1.6,
              color: _Palette.muted,
            ),
          ),
        ),
        const SizedBox(height: 32),
        ctas,
      ],
    );
  }

  // ── FEATURES ───────────────────────────────────────────────────────────────
  Widget _buildFeatures(_Ui ui) {
    return _Band(
      ui: ui,
      color: _Palette.beige,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeading(
            ui: ui,
            eyebrow: 'FEATURES',
            title: 'Everything you need to grow online',
            subtitle: 'Marketing, design and product tools for local '
                'businesses, in one place.',
          ),
          SizedBox(height: ui.wide ? 56 : 36),
          _threeUp(ui, const [
            _FeatureItem(
              icon: Icons.auto_awesome,
              title: 'AI Marketing Assistant',
              description:
                  'Generate marketing captions and promotional content '
                  'for your business.',
            ),
            _FeatureItem(
              icon: Icons.palette_outlined,
              title: 'Creative Poster Maker',
              description:
                  'Create promotional designs for your products.',
            ),
            _FeatureItem(
              icon: Icons.inventory_2_outlined,
              title: 'Digital Product Catalogue',
              description:
                  'Organize and showcase your business products in one '
                  'place.',
            ),
          ]),
        ],
      ),
    );
  }

  // ── HOW IT WORKS ───────────────────────────────────────────────────────────
  Widget _buildHowItWorks(_Ui ui) {
    return _Band(
      ui: ui,
      color: _Palette.charcoal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeading(
            ui: ui,
            eyebrow: 'HOW IT WORKS',
            title: 'Three simple steps to get started',
            onDark: true,
          ),
          SizedBox(height: ui.wide ? 56 : 36),
          _threeUp(ui, const [
            _StepItem(
              number: '01',
              title: 'Set up your business profile',
              description:
                  'Tell us about your business, its category and how '
                  'customers can reach you.',
            ),
            _StepItem(
              number: '02',
              title: 'Create content and manage products',
              description:
                  'Generate marketing content, design posters and '
                  'organize your products.',
            ),
            _StepItem(
              number: '03',
              title: 'Grow your online presence',
              description:
                  'Put your brand in front of more customers online.',
            ),
          ]),
        ],
      ),
    );
  }

  // ── CLOSING CTA ────────────────────────────────────────────────────────────
  Widget _buildClosingCta(_Ui ui) {
    final Widget copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ready to bring your business online?',
          style: TextStyle(
            fontSize: ui.h2,
            height: 1.12,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
            color: _Palette.charcoal,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Create your UdyamBoost account and start building your '
          'online presence.',
          style: TextStyle(
            fontSize: 16,
            height: 1.6,
            color: _Palette.charcoal,
          ),
        ),
      ],
    );

    final Widget buttons = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PrimaryButton(
          label: 'Get Started',
          dark: true,
          onPressed: _openSignup,
        ),
        const SizedBox(height: 12),
        _SecondaryButton(
          label: 'I already have an account',
          onPressed: _openLogin,
        ),
      ],
    );

    return _Band(
      ui: ui,
      color: _Palette.tangerine,
      vertical: ui.wide ? 80 : 56,
      child: ui.wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: copy),
                const SizedBox(width: 64),
                SizedBox(width: 340, child: buttons),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                copy,
                const SizedBox(height: 32),
                buttons,
              ],
            ),
    );
  }

  // ── FOOTER ─────────────────────────────────────────────────────────────────
  Widget _buildFooter(_Ui ui) {
    const Widget tagline = Text(
      'MADE FOR LOCAL BUSINESSES  🇮🇳',
      style: TextStyle(
        fontSize: 10.5,
        letterSpacing: 1.1,
        fontWeight: FontWeight.w600,
        color: _Palette.subtle,
      ),
    );

    return _Band(
      ui: ui,
      color: _Palette.cream,
      vertical: 28,
      bottomExtra: MediaQuery.paddingOf(context).bottom,
      child: ui.roomy
          ? const Row(
              children: [
                _Logo(compact: true),
                Spacer(),
                tagline,
              ],
            )
          : const Column(
              children: [
                _Logo(compact: true),
                SizedBox(height: 14),
                tagline,
              ],
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WELCOME SCREEN PARTS
// ─────────────────────────────────────────────────────────────────────────────
class _FeatureItem extends StatelessWidget {
  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 24),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: _Palette.charcoal, width: 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: _Palette.charcoal,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _Palette.tangerine, size: 22),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: _Palette.charcoal,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 15,
              height: 1.55,
              color: _Palette.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  const _StepItem({
    required this.number,
    required this.title,
    required this.description,
  });

  final String number;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              number,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: _Palette.tangerine,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Container(height: 1, color: _Palette.creamLine),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            height: 1.25,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            color: _Palette.cream,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: const TextStyle(
            fontSize: 15,
            height: 1.55,
            color: _Palette.creamMuted,
          ),
        ),
      ],
    );
  }
}

/// Illustrative mock-up of the UdyamBoost workspace, built from plain
/// Flutter widgets. It shows sample content only and is labelled as such.
class _ProductPreview extends StatelessWidget {
  const _ProductPreview({required this.roomy});

  final bool roomy;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(roomy ? 24 : 14),
      decoration: BoxDecoration(
        color: _Palette.beige,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        padding: EdgeInsets.all(roomy ? 18 : 14),
        decoration: BoxDecoration(
          color: _Palette.cream,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _Palette.line),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14222222),
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _header(),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final bool compact = constraints.maxWidth < 340;
                if (compact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 112, child: _poster()),
                      const SizedBox(height: 10),
                      _caption(),
                    ],
                  );
                }
                return SizedBox(
                  height: 156,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(width: 120, child: _poster()),
                      const SizedBox(width: 12),
                      Expanded(child: _caption()),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'PRODUCT CATALOGUE',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: _Palette.muted,
              ),
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                Expanded(child: _ProductTile()),
                SizedBox(width: 8),
                Expanded(child: _ProductTile()),
                SizedBox(width: 8),
                Expanded(child: _ProductTile()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Container(
          height: 8,
          width: 8,
          decoration: const BoxDecoration(
            color: _Palette.tangerine,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'Your Business',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _Palette.charcoal,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _Palette.line),
          ),
          child: const Text(
            'ILLUSTRATIVE PREVIEW',
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: _Palette.muted,
            ),
          ),
        ),
      ],
    );
  }

  Widget _poster() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _Palette.tangerine,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'POSTER MAKER',
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              color: _Palette.charcoal,
            ),
          ),
          const Spacer(),
          const Text(
            'Festive\nOffer',
            style: TextStyle(
              fontSize: 24,
              height: 1.05,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
              color: _Palette.charcoal,
            ),
          ),
          const SizedBox(height: 8),
          Container(height: 3, width: 28, color: _Palette.charcoal),
        ],
      ),
    );
  }

  Widget _caption() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _Palette.line),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 14, color: _Palette.charcoal),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'AI Marketing Assistant',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: _Palette.charcoal,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '“Fresh arrivals are in! Visit us this weekend and discover '
            'something new.”',
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              height: 1.45,
              color: _Palette.muted,
            ),
          ),
          SizedBox(height: 10),
          _Bar(widthFactor: 0.7, color: _Palette.line),
          SizedBox(height: 5),
          _Bar(widthFactor: 0.45, color: _Palette.line),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.widthFactor, required this.color});

  final double widthFactor;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: widthFactor,
      child: Container(
        height: 5,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _Palette.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: _Palette.beige,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 6),
          const _Bar(widthFactor: 0.65, color: _Palette.line),
          const SizedBox(height: 4),
          const _Bar(widthFactor: 0.35, color: _Palette.tangerine),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BUSINESS ONBOARDING SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class BusinessOnboardingScreen extends StatefulWidget {
  const BusinessOnboardingScreen({super.key});

  @override
  State<BusinessOnboardingScreen> createState() =>
      _BusinessOnboardingScreenState();
}

class _BusinessOnboardingScreenState
    extends State<BusinessOnboardingScreen> {
  static const double _formMaxWidth = 720;

  final _formKey = GlobalKey<FormState>();

  final _businessName = TextEditingController();
  final _ownerName = TextEditingController();
  final _phone = TextEditingController();
  final _location = TextEditingController();
  final _description = TextEditingController();

  String? _category;

  final List<String> _categories = [
    'Clothing & Fashion',
    'Food & Beverages',
    'Grocery & Retail',
    'Beauty & Wellness',
    'Electronics',
    'Handicrafts',
    'Home & Lifestyle',
    'Education',
    'Other',
  ];

  @override
  void dispose() {
    _businessName.dispose();
    _ownerName.dispose();
    _phone.dispose();
    _location.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Palette.cream,
      appBar: AppBar(
        backgroundColor: _Palette.cream,
        surfaceTintColor: Colors.transparent,
        foregroundColor: _Palette.charcoal,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back',
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Business Profile',
          style: TextStyle(
            color: _Palette.charcoal,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: _Palette.line),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < _splitBreakpoint) {
              // Phones and tablets: one scrolling column.
              return _formPane(showIntro: true);
            }

            // Laptops and desktops: brand panel + form pane, full width.
            return Row(
              children: [
                Expanded(flex: 5, child: _sidePanel()),
                Expanded(flex: 7, child: _formPane(showIntro: false)),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── LAYOUT PIECES ──────────────────────────────────────────────────────────
  Widget _sidePanel() {
    return Container(
      width: double.infinity,
      color: _Palette.charcoal,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(56, 48, 56, 48),
        child: Align(
          alignment: Alignment.topRight,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Logo(onDark: true),
                const SizedBox(height: 64),
                _intro(onDark: true, roomy: true),
                const SizedBox(height: 32),
                _privacyNote(onDark: true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _formPane({required bool showIntro}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool roomy = constraints.maxWidth >= _pairBreakpoint;
        final double hPad = roomy ? 40 : 22;

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(hPad, 28, hPad, 32),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: _formMaxWidth),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showIntro) ...[
                            _intro(onDark: false, roomy: roomy),
                            const SizedBox(height: 28),
                          ],
                          ..._sections(roomy),
                          if (showIntro) ...[
                            const SizedBox(height: 12),
                            _privacyNote(onDark: false),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // BOTTOM CONTINUE BUTTON
            Container(
              padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 12),
              decoration: const BoxDecoration(
                color: _Palette.cream,
                border: Border(top: BorderSide(color: _Palette.line)),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _formMaxWidth),
                  child: _PrimaryButton(
                    label: 'Continue',
                    onPressed: _continue,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Progress indicator, heading and description.
  Widget _intro({required bool onDark, required bool roomy}) {
    final Color main = onDark ? _Palette.cream : _Palette.charcoal;
    final Color soft = onDark ? _Palette.creamMuted : _Palette.muted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'STEP 01 OF 03',
              style: TextStyle(
                color: main,
                fontWeight: FontWeight.w800,
                fontSize: 11,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              '33% completed',
              style: TextStyle(color: soft, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: 0.33,
            minHeight: 6,
            backgroundColor: onDark ? _Palette.creamLine : _Palette.beige,
            valueColor: const AlwaysStoppedAnimation(_Palette.tangerine),
          ),
        ),
        SizedBox(height: onDark ? 36 : 30),
        Text(
          'Let’s set up your\nbusiness profile.',
          style: TextStyle(
            fontSize: onDark ? 40 : (roomy ? 34 : 29),
            height: 1.15,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.9,
            color: main,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Tell us a little about your business. '
          'We’ll use these details to personalize '
          'your UdyamBoost experience.',
          style: TextStyle(
            fontSize: onDark ? 16 : 14.5,
            height: 1.6,
            color: soft,
          ),
        ),
      ],
    );
  }

  // PRIVACY NOTE
  Widget _privacyNote({required bool onDark}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: onDark ? _Palette.creamFaint : _Palette.beige,
        borderRadius: BorderRadius.circular(12),
        border: onDark ? Border.all(color: _Palette.creamLine) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: onDark ? _Palette.cream : _Palette.charcoal,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your business information helps us '
              'personalize your marketing experience.',
              style: TextStyle(
                fontSize: 12.5,
                height: 1.5,
                color: onDark ? _Palette.cream : _Palette.charcoal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── FORM SECTIONS (fields, controllers and validators unchanged) ───────────
  List<Widget> _sections(bool roomy) {
    return [
      // BUSINESS IDENTITY
      _section(
        title: 'Business Identity',
        subtitle: 'Basic information about your business',
        showDivider: false,
        children: [
          _pair(
            roomy,
            _labeled(
              'Business Name',
              required: true,
              child: _textField(
                controller: _businessName,
                hint: 'e.g. Arun Fashion Store',
                icon: Icons.store_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your business name';
                  }
                  return null;
                },
              ),
            ),
            _labeled(
              'Owner Name',
              required: true,
              child: _textField(
                controller: _ownerName,
                hint: 'Enter business owner name',
                icon: Icons.person_outline_rounded,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter owner name';
                  }
                  return null;
                },
              ),
            ),
          ),
        ],
      ),

      // CATEGORY
      _section(
        title: 'Business Category',
        subtitle: 'Choose the category that fits your business',
        children: [
          _labeled(
            'Select Category',
            required: true,
            child: DropdownButtonFormField<String>(
              initialValue: _category,
              isExpanded: true,
              borderRadius: BorderRadius.circular(12),
              dropdownColor: _Palette.cream,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: _Palette.muted,
              ),
              decoration: _decoration(
                'Choose business category',
                Icons.grid_view_rounded,
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(
                    category,
                    style: const TextStyle(
                      fontSize: 14.5,
                      color: _Palette.charcoal,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _category = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a category';
                }
                return null;
              },
            ),
          ),
        ],
      ),

      // CONTACT INFORMATION
      _section(
        title: 'Contact Information',
        subtitle: 'Help customers find and contact you',
        children: [
          _pair(
            roomy,
            _labeled(
              'Phone Number',
              required: true,
              child: _textField(
                controller: _phone,
                hint: '10-digit mobile number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null ||
                      !RegExp(r'^[6-9]\d{9}$').hasMatch(value.trim())) {
                    return 'Enter a valid 10-digit mobile number';
                  }
                  return null;
                },
              ),
            ),
            _labeled(
              'Business Location',
              required: true,
              child: _textField(
                controller: _location,
                hint: 'e.g. Mangaluru, Karnataka',
                icon: Icons.location_on_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your location';
                  }
                  return null;
                },
              ),
            ),
          ),
        ],
      ),

      // DESCRIPTION
      _section(
        title: 'About Your Business',
        subtitle: 'Introduce your business to potential customers',
        children: [
          _labeled(
            'Business Description',
            child: TextFormField(
              controller: _description,
              maxLines: 4,
              maxLength: 250,
              style: const TextStyle(
                fontSize: 14.5,
                color: _Palette.charcoal,
              ),
              decoration: _decoration(
                'Describe what your business offers...',
                null,
              ).copyWith(
                alignLabelWithHint: true,
                counterStyle: const TextStyle(
                  color: _Palette.muted,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    ];
  }

  // SECTION WRAPPER: heading, description, divider and spacing.
  Widget _section({
    required String title,
    required String subtitle,
    required List<Widget> children,
    bool showDivider = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showDivider) ...[
          const Divider(height: 1, thickness: 1, color: _Palette.line),
          const SizedBox(height: 24),
        ],
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: _Palette.charcoal,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 12.5, color: _Palette.muted),
        ),
        const SizedBox(height: 18),
        ...children,
        const SizedBox(height: 28),
      ],
    );
  }

  // Two fields side by side when there is room, stacked otherwise.
  Widget _pair(bool roomy, Widget first, Widget second) {
    if (roomy) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: first),
          const SizedBox(width: 16),
          Expanded(child: second),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        first,
        const SizedBox(height: 18),
        second,
      ],
    );
  }

  Widget _labeled(
    String label, {
    required Widget child,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label, required: required),
        child,
      ],
    );
  }

  Widget _fieldLabel(String label, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text.rich(
        TextSpan(
          text: label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _Palette.charcoal,
          ),
          children: [
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: _Palette.tangerine),
              ),
          ],
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 14.5, color: _Palette.charcoal),
      decoration: _decoration(hint, icon),
    );
  }

  InputDecoration _decoration(String hint, IconData? icon) {
    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13.5, color: _Palette.subtle),
      prefixIcon: icon == null
          ? null
          : Icon(icon, color: _Palette.subtle, size: 20),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.65),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 17,
      ),
      errorStyle: const TextStyle(color: _Palette.error, fontSize: 12),
      border: border(_Palette.line),
      enabledBorder: border(const Color(0x40222222)),
      focusedBorder: border(_Palette.tangerine, 2),
      errorBorder: border(_Palette.error),
      focusedErrorBorder: border(_Palette.error, 2),
    );
  }

  void _continue() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BrandIdentityScreen(
          businessName: _businessName.text.trim(),
          ownerName: _ownerName.text.trim(),
          phone: _phone.text.trim(),
          category: _category!,
          location: _location.text.trim(),
          description: _description.text.trim(),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../profile/providers/profile_provider.dart';
import '../../providers/emergency_provider.dart';

class EmergencyScreen extends ConsumerStatefulWidget {
  const EmergencyScreen({super.key});
  @override
  ConsumerState<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends ConsumerState<EmergencyScreen> {
  Timer? _flashTimer;
  bool _flashColorState = false;

  @override
  void initState() {
    super.initState();
    _flashTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (ref.read(emergencyNotifierProvider)) {
        setState(() {
          _flashColorState = !_flashColorState;
        });
      }
    });
  }

  @override
  void dispose() {
    _flashTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEmergencyActive = ref.watch(emergencyNotifierProvider);
    final notifier = ref.read(emergencyNotifierProvider.notifier);

    final currentUser = ref.watch(currentUserProvider);
    final profileState = ref.watch(profileNotifierProvider);
    final userName = profileState.profile?.name ?? currentUser?.name ?? 'Pengguna';
    final userEmail = currentUser?.email ?? 'user@bentara.id';

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.white,
    ));

    if (isEmergencyActive) {
      return _buildActiveEmergencyUI(notifier);
    }

    return Scaffold(
      backgroundColor: AppColors.error,
      body: Stack(
        children: [
          // LAYER 1: SOLID BLUE BACKGROUND (Inherited from Scaffold backgroundColor)

          // CONTENT
          SafeArea(
            bottom: true,
            child: Column(
              children: [
                // LAYER 1: USER HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: Row(
                    children: [
                      // Profile Avatar
                      Expanded(
                        child: GestureDetector(
                          onTap: () => context.pushNamed(RouteNames.profile),
                          behavior: HitTestBehavior.opaque,
                          child: Row(
                            children: [
                              Container(
                                width: 44.0,
                                height: 44.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2.0,
                                  ),
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                                child: const ClipOval(
                                  child: Icon(
                                    Icons.person_rounded,
                                    color: AppColors.error,
                                    size: 26.0,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      userName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w800,
                                        height: 1.2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2.0),
                                    Text(
                                      userEmail,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w500,
                                        height: 1.1,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Notification Bell
                      Container(
                        width: 40.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.9),
                          border: Border.all(color: Colors.white, width: 1.0),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.notifications_outlined,
                            color: AppColors.error,
                            size: 20.0,
                          ),
                          onPressed: () {
                            context.pushNamed(RouteNames.history);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12.0),

                // LAYER 2: SOLID WHITE BOTTOM SHEET
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surface, // Solid White
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(32.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10.0,
                          offset: const Offset(0, -4.0),
                        ),
                      ],
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final availableHeight = constraints.maxHeight;
                        final iconSize = (availableHeight * 0.07).clamp(32.0, 48.0);
                        final titleFontSize = (availableHeight * 0.025).clamp(14.0, 18.0);
                        final buttonHeight = (availableHeight * 0.075).clamp(42.0, 54.0);
                        final buttonFontSize = (availableHeight * 0.02).clamp(12.0, 15.0);
                        final verticalGap = (availableHeight * 0.012).clamp(6.0, 12.0);

                        return Padding(
                          padding: EdgeInsets.fromLTRB(18.0, 20.0, 18.0, 20.0 + MediaQuery.paddingOf(context).bottom),
                          child: Column(
                            children: [
                              // BENTARA BRANDING + MODE DARURAT
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => context.pop(),
                                    child: const Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      color: AppColors.error,
                                      size: 18.0,
                                    ),
                                  ),
                                  const SizedBox(width: 10.0),
                                  Image.asset(
                                    'assets/logos/logo_bentara_biru.webp', // Keep logo asset
                                    height: 20.0,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.shield, color: AppColors.error, size: 20);
                                    },
                                  ),
                                  const SizedBox(width: 8.0),
                                  const Text(
                                    'Mode Darurat',
                                    style: TextStyle(
                                      color: AppColors.error,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),

                              const Spacer(flex: 2),

                              // WARNING ICON
                              Icon(
                                Icons.warning_rounded,
                                size: iconSize,
                                color: AppColors.error,
                              ),
                              const SizedBox(height: 6.0),

                              // TITLE
                              Text(
                                'PILIH PESAN DARURAT',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.error,
                                  fontSize: titleFontSize,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),

                              const Spacer(flex: 3),

                              // FIVE EMERGENCY BUTTONS (Kept semantic red/danger)
                              _EmergencyActionButton(
                                title: 'SAYA BUTUH AMBULANS SEKARANG!',
                                height: buttonHeight,
                                fontSize: buttonFontSize,
                                onTap: () => notifier.activateEmergency(
                                  'Tolong, saya butuh ambulans sekarang! Ini darurat medis!',
                                ),
                              ),
                              SizedBox(height: verticalGap),

                              _EmergencyActionButton(
                                title: 'TOLONG HUBUNGI POLISI!',
                                height: buttonHeight,
                                fontSize: buttonFontSize,
                                onTap: () => notifier.activateEmergency(
                                  'Tolong panggil polisi! Saya dalam bahaya!',
                                ),
                              ),
                              SizedBox(height: verticalGap),

                              _EmergencyActionButton(
                                title: 'BAWA KE RUMAH SAKIT!',
                                height: buttonHeight,
                                fontSize: buttonFontSize,
                                onTap: () => notifier.activateEmergency(
                                  'Tolong bawa saya ke rumah sakit terdekat!',
                                ),
                              ),
                              SizedBox(height: verticalGap),

                              _EmergencyActionButton(
                                title: 'SAYA TERLUKA!',
                                height: buttonHeight,
                                fontSize: buttonFontSize,
                                onTap: () => notifier.activateEmergency(
                                  'Saya terluka parah, tolong bantu saya!',
                                ),
                              ),
                              SizedBox(height: verticalGap),

                              _EmergencyActionButton(
                                title: 'SAYA BUTUH BANTUAN!',
                                height: buttonHeight,
                                fontSize: buttonFontSize,
                                onTap: () => notifier.activateEmergency(
                                  'Tolong, saya butuh bantuan segera!',
                                ),
                              ),

                              const Spacer(flex: 2),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showStopConfirmationDialog(BuildContext context, EmergencyNotifier notifier) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
        title: const Text(
          'Berhenti menyiarkan pesan darurat?',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
        ),
        content: const Text('Tindakan ini akan menghentikan siaran suara darurat.'),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            ),
            child: const Text('Hentikan', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      notifier.deactivateEmergency();
    }
  }

  // ACTIVE EMERGENCY STATE: Professional Emergency Broadcast Screen
  Widget _buildActiveEmergencyUI(EmergencyNotifier notifier) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFF7F0000),
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Color(0xFF7F0000),
    ));

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD32F2F), Color(0xFF7F0000)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 24.0 + bottomInset),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.radio_button_checked_rounded, color: Colors.white, size: 14.0),
                      SizedBox(width: 8.0),
                      Text(
                        'SIARAN DARURAT AKTIF',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.0,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Pulsing Speaker Icon
                const _PulsingSpeakerIcon(),
                const SizedBox(height: 24.0),

                // Main Title
                const Text(
                  'SIARAN DARURAT AKTIF',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6.0),
                Text(
                  'Suara darurat sedang diputar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.0,
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),

                // Message Card Header
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'PESAN YANG DISIARKAN',
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w800,
                      color: Colors.white.withValues(alpha: 0.85),
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),

                // Solid White Message Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 16.0,
                        offset: const Offset(0, 6.0),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD32F2F).withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.campaign_rounded,
                              color: Color(0xFFD32F2F),
                              size: 20.0,
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          const Text(
                            'Pesan Darurat',
                            style: TextStyle(
                              fontSize: 13.0,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14.0),
                      Text(
                        notifier.activeMessage,
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFB71C1C),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),

                // Status Information Subtitle Below Card
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.volume_up_rounded,
                      size: 16.0,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      'Pesan sedang diputar melalui pengeras suara',
                      style: TextStyle(
                        fontSize: 13.0,
                        color: Colors.white.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const Spacer(),

                // CTA Button ("HENTIKAN SIARAN")
                SizedBox(
                  width: double.infinity,
                  height: 56.0,
                  child: ElevatedButton(
                    onPressed: () => _showStopConfirmationDialog(context, notifier),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFB71C1C),
                      elevation: 4.0,
                      shadowColor: Colors.black.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),
                    child: const Text(
                      'HENTIKAN SIARAN',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PulsingSpeakerIcon extends StatefulWidget {
  const _PulsingSpeakerIcon();

  @override
  State<_PulsingSpeakerIcon> createState() => _PulsingSpeakerIconState();
}

class _PulsingSpeakerIconState extends State<_PulsingSpeakerIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _scaleAnim = Tween<double>(begin: 1.0, end: 1.10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: Container(
        padding: const EdgeInsets.all(28.0),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20.0,
              spreadRadius: 4.0,
            ),
          ],
        ),
        child: const Icon(
          Icons.campaign_rounded,
          size: 64.0,
          color: Colors.white,
        ),
      ),
    );
  }
}

// EMERGENCY ACTION BUTTON WIDGET (Maintains semantic danger colors)
class _EmergencyActionButton extends StatelessWidget {
  final String title;
  final double height;
  final double fontSize;
  final VoidCallback onTap;

  const _EmergencyActionButton({
    required this.title,
    required this.height,
    required this.fontSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(14.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withValues(alpha: 0.25),
            blurRadius: 8.0,
            offset: const Offset(0, 4.0),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14.0),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14.0),
          splashColor: Colors.white.withValues(alpha: 0.2),
          highlightColor: Colors.white.withValues(alpha: 0.1),
          child: Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

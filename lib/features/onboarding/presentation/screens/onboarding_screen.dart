import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';

/// ============================================================
/// BENTARA — Authentication Landing / Onboarding Screen
/// ============================================================
/// Halaman awal yang ditampilkan sebelum user login atau register.
///
/// CARA MENGEDIT:
/// - Cari komentar bernomor (// === 1. BACKGROUND === dst.)
///   untuk menemukan bagian yang ingin kamu ubah.
/// - Ubah angka pada SizedBox, fontSize, fontWeight, dll.
/// - Jangan hapus SafeArea, LayoutBuilder, atau IntrinsicHeight
///   karena itu menjaga layout agar tidak overflow.
/// ============================================================
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ukuran layar device saat ini
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Stack(
        children: [
          // =============================================================
          // === 1. BACKGROUND IMAGE ===
          // Asset     : 'assets/images/Authentication_bg.webp'
          // Fit       : BoxFit.cover (mengisi seluruh layar, crop jika perlu)
          // Alignment : Alignment.center (titik fokus di tengah)
          // Untuk menggeser focal point, ubah alignment.
          // Contoh: Alignment(0.0, 0.3) → geser ke bawah.
          // =============================================================
          Positioned.fill(
            child: Image.asset(
              'assets/images/Authentication_bg.webp',
              fit: BoxFit.cover, // Ubah ke BoxFit.contain jika tidak ingin crop
              alignment: Alignment.center, // Ubah untuk geser focal point
            ),
          ),

          // =============================================================
          // === 2. GRADIENT OVERLAY ===
          // Memberikan efek gelap transparan di atas dan bawah
          // agar teks terlihat jelas di atas background.
          //
          // colors[0] : warna di bagian ATAS (alpha = opacity, 0.0–1.0)
          // colors[1] : warna di bagian TENGAH
          // colors[2] : warna di bagian BAWAH
          // stops     : posisi masing-masing warna (0.0=atas, 1.0=bawah)
          //
          // Jika ingin lebih gelap, naikkan angka alpha.
          // Jika ingin lebih terang, turunkan angka alpha.
          // =============================================================
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.10), // Atas — sedikit gelap
                    Colors.transparent,                    // Tengah — transparan
                    Colors.black.withValues(alpha: 0.32), // Bawah — agak gelap
                  ],
                  stops: const [0.0, 0.40, 1.0], // Posisi gradient
                ),
              ),
            ),
          ),

          // =============================================================
          // === 3. FOREGROUND CONTENT (Seluruh konten di atas background) ===
          // SafeArea  : menjaga konten tidak tertutup status bar / nav bar
          // LayoutBuilder : memberikan ukuran area yang tersedia (maxHeight)
          // =============================================================
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxHeight = constraints.maxHeight;

                // =========================================================
                // HORIZONTAL PADDING — mengatur lebar konten (logo, button)
                // Semakin besar padding, semakin sempit konten.
                // Rumus: max(34, screenWidth * 0.095)
                // Hasilnya ≈ 80-82% lebar layar untuk button.
                // Ubah 0.095 menjadi 0.12 untuk button lebih sempit,
                // atau 0.07 untuk button lebih lebar.
                // =========================================================
                final horizontalPadding = math.max(34.0, size.width * 0.095);

                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [

                            // =============================================
                            // === 4. TOP SPACING (jarak dari atas ke logo) ===
                            // Angka 0.25 = 25% dari tinggi layar.
                            // Naikkan angka → logo turun.
                            // Turunkan angka → logo naik.
                            // =============================================
                            SizedBox(height: maxHeight * 0.25),

                            // =============================================
                            // === 5. LOGO BENTARA (Bird Icon + Wordmark) ===
                            // Row berisi 2 elemen:
                            //   1) Image bird icon (height: 46dp)
                            //   2) Text 'BENTARA' (fontSize: 38sp)
                            //
                            // Untuk memperbesar logo:
                            //   - Naikkan height pada Image.asset
                            //   - Naikkan fontSize pada Text
                            // Untuk memperkecil: turunkan angkanya.
                            //
                            // SizedBox(width: 12) = jarak antara bird dan teks.
                            // letterSpacing: 2.5 = jarak antar huruf BENTARA.
                            // =============================================
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // --- Bird Icon ---
                                  Image.asset(
                                    'assets/logos/logo_bentara_biru.webp',
                                    height: 46.0,       // Ubah untuk resize bird icon
                                    fit: BoxFit.contain, // Jaga aspect ratio
                                  ),
                                  const SizedBox(width: 12.0), // Jarak bird ↔ teks
                                  // --- Wordmark "BENTARA" ---
                                  Text(
                                    'BENTARA',
                                    style: TextStyle(
                                      color: Colors.white,         // Warna teks
                                      fontSize: 38.0,              // Ukuran font
                                      fontWeight: FontWeight.w900, // Ketebalan (w100–w900)
                                      letterSpacing: 2.5,          // Jarak antar huruf
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withValues(alpha: 0.45),
                                          offset: const Offset(0, 2.0), // Arah shadow (x, y)
                                          blurRadius: 5.0,              // Blur shadow
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // =============================================
                            // === 6. SPACING: LOGO → TAGLINE ===
                            // Jarak vertikal antara logo dan tagline.
                            // Angka 0.12 = 12% dari tinggi layar.
                            // Naikkan → tagline turun lebih jauh dari logo.
                            // Turunkan → tagline naik lebih dekat ke logo.
                            // =============================================
                            SizedBox(height: maxHeight * 0.12),

                            // =============================================
                            // === 7. TAGLINE ===
                            // Teks: "Menjembatani komunikasi, mendekatkan hati"
                            //
                            // textAlign : TextAlign.center → rata tengah
                            // fontSize  : 15.5sp (ubah untuk resize)
                            // fontWeight: FontWeight.w400 (Regular)
                            //             w300=Light, w500=Medium, w700=Bold
                            // color     : Colors.white
                            //
                            // Tagline di-center secara horizontal oleh Column
                            // (crossAxisAlignment: CrossAxisAlignment.center)
                            // dan textAlign: TextAlign.center.
                            //
                            // Padding horizontal 8dp mencegah teks terlalu
                            // dekat dengan tepi layar pada device kecil.
                            // =============================================
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                'Menjembatani komunikasi, mendekatkan hati',
                                textAlign: TextAlign.center, // Rata tengah
                                style: TextStyle(
                                  color: Colors.white,       // Warna teks
                                  fontSize: 15.5,            // Ukuran font tagline
                                  fontWeight: FontWeight.w400, // Ketebalan: Regular
                                  height: 1.4,               // Line height (jarak antar baris jika wrap)
                                  letterSpacing: 0.3,        // Jarak antar huruf
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(alpha: 0.55),
                                      offset: const Offset(0, 1.5),
                                      blurRadius: 4.0,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // =============================================
                            // === 8. FLEXIBLE SPACE (antara tagline & buttons) ===
                            // Spacer() mengisi sisa ruang yang tersedia
                            // sehingga CTA group terdorong ke bawah.
                            // Jangan hapus Spacer ini, karena memisahkan
                            // area logo/tagline dari area button.
                            // =============================================
                            const Spacer(),

                            // =============================================
                            // === 9. SIGN UP BUTTON (Primary CTA) ===
                            // backgroundColor : AppColors.primary
                            // height          : 58dp (ubah untuk resize vertikal)
                            // width           : double.infinity (mengikuti padding)
                            // shape           : StadiumBorder (pill / kapsul)
                            // fontSize        : 16sp
                            // fontWeight      : w700 (Bold)
                            //
                            // Navigasi: → RouteNames.register
                            // =============================================
                            SizedBox(
                              width: double.infinity,
                              height: 58.0, // Tinggi button SIGN UP
                              child: ElevatedButton(
                                onPressed: () => context.pushNamed(RouteNames.register),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,  // Warna latar
                                  foregroundColor: Colors.white,           // Warna teks & icon
                                  elevation: 2.5,                          // Bayangan elevasi
                                  shadowColor: AppColors.primary.withValues(alpha: 0.45),
                                  shape: const StadiumBorder(),            // Bentuk pill/kapsul
                                ),
                                child: const Text(
                                  'SIGN UP',
                                  style: TextStyle(
                                    fontSize: 16.0,              // Ukuran font
                                    fontWeight: FontWeight.w700, // Ketebalan: Bold
                                    letterSpacing: 0.8,          // Jarak antar huruf
                                    color: Colors.white,         // Warna teks
                                  ),
                                ),
                              ),
                            ),

                            // =============================================
                            // === 10. SPACING: SIGN UP → LINK ===
                            // Jarak antara tombol SIGN UP dan teks link.
                            // Ubah 24.0 untuk mengatur jarak.
                            // =============================================
                            const SizedBox(height: 24.0),

                            // =============================================
                            // === 11. LINK "Sudah punya akun sebelumnya?" ===
                            // fontSize       : 14.5sp
                            // decoration     : underline
                            // decorationColor: white
                            //
                            // Navigasi: → RouteNames.login
                            // =============================================
                            GestureDetector(
                              onTap: () => context.pushNamed(RouteNames.login),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(
                                  'Sudah punya akun sebelumnya?',
                                  textAlign: TextAlign.center, // Rata tengah
                                  style: TextStyle(
                                    color: Colors.white,                    // Warna teks
                                    fontSize: 14.5,                         // Ukuran font
                                    fontWeight: FontWeight.w400,            // Ketebalan: Regular
                                    decoration: TextDecoration.underline,   // Garis bawah
                                    decorationColor: Colors.white,          // Warna garis bawah
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withValues(alpha: 0.50),
                                        offset: const Offset(0, 1.0),
                                        blurRadius: 3.0,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // =============================================
                            // === 12. SPACING: LINK → SIGN IN ===
                            // Jarak antara link dan tombol SIGN IN.
                            // Ubah 20.0 untuk mengatur jarak.
                            // =============================================
                            const SizedBox(height: 20.0),

                            // =============================================
                            // === 13. SIGN IN BUTTON (Secondary CTA) ===
                            // backgroundColor : AppColors.darkCharcoal (#1F1F1F)
                            // height          : 58dp (sama dengan SIGN UP)
                            // shape           : StadiumBorder (pill / kapsul)
                            //
                            // Navigasi: → RouteNames.login
                            // =============================================
                            SizedBox(
                              width: double.infinity,
                              height: 58.0, // Tinggi button SIGN IN (samakan dengan SIGN UP)
                              child: ElevatedButton(
                                onPressed: () => context.pushNamed(RouteNames.login),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.darkCharcoal, // Warna latar (#1F1F1F)
                                  foregroundColor: Colors.white,           // Warna teks & icon
                                  elevation: 2.0,                          // Bayangan elevasi
                                  shadowColor: Colors.black54,
                                  shape: const StadiumBorder(),            // Bentuk pill/kapsul
                                ),
                                child: const Text(
                                  'SIGN IN',
                                  style: TextStyle(
                                    fontSize: 16.0,              // Ukuran font
                                    fontWeight: FontWeight.w700, // Ketebalan: Bold
                                    letterSpacing: 0.8,          // Jarak antar huruf
                                    color: Colors.white,         // Warna teks
                                  ),
                                ),
                              ),
                            ),

                            // =============================================
                            // === 14. BOTTOM SPACING ===
                            // Jarak dari SIGN IN ke bawah layar.
                            // Angka 0.10 = 10% tinggi layar.
                            // Semakin besar → CTA group naik.
                            // Semakin kecil → CTA group turun ke bawah.
                            // math.max(64, ...) memastikan minimum 64dp.
                            // =============================================
                            SizedBox(height: math.max(64.0, maxHeight * 0.10)),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

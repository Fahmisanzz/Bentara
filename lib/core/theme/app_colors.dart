import 'package:flutter/material.dart';

class AppColors {
  // Brand Base Palette
  static const Color primary = Color(0xFF1E88E5);
  static const Color primaryDark = Color(0xFF1565C0);
  
  static const Color textPrimary = Color(0xFF0C0C0C);
  static const Color textSecondary = Color(0xFF757575);
  
  // Feature Identity Colors
  static const Color lightBlue = Color(0xFF77D0FA);
  static const Color successGreen = Color(0xFF4BA95F);
  static const Color warningOrange = Color(0xFFFEA339);
  static const Color accentPurple = Color(0xFF9985FB);
  static const Color accentPink = Color(0xFFFF8080);
  static const Color error = Color(0xFFD32F2F);

  // Surface Colors
  static const Color background = Color(0xFF77D0FA); 
  static const Color surface = Colors.white; 
  static const Color border = Color(0xFFEBEBEB);

  // Legacy mappings
  static const Color primaryLight = Color(0xFF77D0FA);
  static const Color darkCharcoal = Color(0xFF0C0C0C); 
  static const Color secondary = Color(0xFF4BA95F); 
  static const Color infoCyan = Color(0xFF77D0FA);
}

class AppGradients {
  static const LinearGradient primary = LinearGradient(
    colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lightBlue = LinearGradient(
    colors: [Color(0xFF77D0FA), Color(0xFFB3E5FC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient green = LinearGradient(
    colors: [Color(0xFF4BA95F), Color(0xFF81C784)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purple = LinearGradient(
    colors: [Color(0xFF9985FB), Color(0xFFB39DDB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pink = LinearGradient(
    colors: [Color(0xFFFF8080), Color(0xFFEF9A9A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emergency = LinearGradient(
    colors: [Color(0xFFE53935), Color(0xFFEF5350)], // Solid bright red
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

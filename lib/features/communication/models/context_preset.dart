import 'package:flutter/material.dart';

enum ContextPreset { umum, rumahSakit, layananPublik, darurat }

extension ContextPresetExtension on ContextPreset {
  String get label {
    switch (this) {
      case ContextPreset.umum: return 'Umum';
      case ContextPreset.rumahSakit: return 'Rumah Sakit';
      case ContextPreset.layananPublik: return 'Layanan Publik';
      case ContextPreset.darurat: return 'Darurat';
    }
  }

  IconData get icon {
    switch (this) {
      case ContextPreset.umum: return Icons.chat_bubble_outline;
      case ContextPreset.rumahSakit: return Icons.local_hospital_outlined;
      case ContextPreset.layananPublik: return Icons.account_balance_outlined;
      case ContextPreset.darurat: return Icons.warning_amber_outlined;
    }
  }
}

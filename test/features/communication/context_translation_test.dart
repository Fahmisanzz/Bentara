import 'package:flutter_test/flutter_test.dart';
import 'package:bentara/features/communication/models/context_preset.dart';
import 'package:bentara/features/communication/services/context_translation_service.dart';
import 'package:bentara/features/quick_communication/data/quick_phrases_repository.dart';

void main() {
  group('Rule-Based Contextual Engine Tests', () {
    final service = SupabaseContextTranslationService();

    test('Specific Presentation Guarantees (Slide 8 & Demo)', () async {
      final res1 = await service.translateContext(
        rawText: 'Perut saya sakit udah dua hari nih',
        preset: ContextPreset.rumahSakit,
      );
      expect(res1, equals('Saya mengalami sakit perut selama dua hari.'));

      final res2 = await service.translateContext(
        rawText: 'mau daftar yang BPJS bisa nggak ya dok',
        preset: ContextPreset.rumahSakit,
      );
      expect(res2, equals('Saya ingin mendaftar layanan menggunakan BPJS.'));

      final res3 = await service.translateContext(
        rawText: 'tolong cepat ini darurat banget',
        preset: ContextPreset.darurat,
      );
      expect(res3, equals('Saya membutuhkan bantuan darurat sekarang.'));

      final res4 = await service.translateContext(
        rawText: 'obat pusing mana',
        preset: ContextPreset.rumahSakit,
      );
      expect(res4, equals('Maaf, di mana saya bisa mendapatkan obat untuk sakit kepala saya?'));
    });

    test('Preset Rumah Sakit vocabulary matching', () async {
      expect(
        await service.translateContext(rawText: 'kepala pusing', preset: ContextPreset.rumahSakit),
        contains('kepala saya terasa sangat pusing'),
      );
      expect(
        await service.translateContext(rawText: 'mual muntah', preset: ContextPreset.rumahSakit),
        contains('mual dan sudah muntah'),
      );
      expect(
        await service.translateContext(rawText: 'cek tensi darah', preset: ContextPreset.rumahSakit),
        contains('tekanan darah'),
      );
      expect(
        await service.translateContext(rawText: 'antrean nomor', preset: ContextPreset.rumahSakit),
        contains('nomor antrean'),
      );
    });

    test('Preset Layanan Publik vocabulary matching', () async {
      expect(
        await service.translateContext(rawText: 'mau bikin ktp baru', preset: ContextPreset.layananPublik),
        contains('KTP elektronik'),
      );
      expect(
        await service.translateContext(rawText: 'buka rekening tabungan', preset: ContextPreset.layananPublik),
        contains('membuka rekening tabungan baru'),
      );
      expect(
        await service.translateContext(rawText: 'kehilangan dompet', preset: ContextPreset.layananPublik),
        contains('laporan resmi kehilangan'),
      );
      expect(
        await service.translateContext(rawText: 'perpanjang sim', preset: ContextPreset.layananPublik),
        contains('perpanjangan SIM'),
      );
    });

    test('Preset Darurat vocabulary matching', () async {
      expect(
        await service.translateContext(rawText: 'panggil ambulans', preset: ContextPreset.darurat),
        contains('DARURAT MEDIS'),
      );
      expect(
        await service.translateContext(rawText: 'ada kebakaran besar', preset: ContextPreset.darurat),
        contains('DARURAT KEBAKARAN'),
      );
      expect(
        await service.translateContext(rawText: 'ada begal senjata', preset: ContextPreset.darurat),
        contains('DARURAT KEJAHATAN'),
      );
    });

    test('Preset Umum vocabulary matching', () async {
      expect(
        await service.translateContext(rawText: 'tuli tidak dengar', preset: ContextPreset.umum),
        contains('penyandang Tuli'),
      );
      expect(
        await service.translateContext(rawText: 'tulis di kertas', preset: ContextPreset.umum),
        contains('tuliskan di kertas'),
      );
      expect(
        await service.translateContext(rawText: 'toilet mana', preset: ContextPreset.umum),
        contains('toilet atau kamar kecil'),
      );
      expect(
        await service.translateContext(rawText: 'bayar pakai qris', preset: ContextPreset.umum),
        contains('QRIS'),
      );
    });

    test('Empty or whitespace input returns empty string immediately', () async {
      expect(await service.translateContext(rawText: '', preset: ContextPreset.umum), equals(''));
      expect(await service.translateContext(rawText: '   ', preset: ContextPreset.rumahSakit), equals(''));
    });

    test('Universal sentence formatting cleans filler words and capitalizes', () async {
      final res = await service.translateContext(
        rawText: 'anu saya mau beli buku gitu deh',
        preset: ContextPreset.umum,
      );
      expect(res.startsWith('Saya'), isTrue);
      expect(res.endsWith('.'), isTrue);
    });
  });

  group('Quick Phrases Repository Tests', () {
    test('Default phrases contain all 6 PPT categories', () {
      final categories = QuickPhrasesRepository.defaultPhrases.map((e) => e.category).toSet();
      expect(categories, containsAll([
        'Umum',
        'Rumah Sakit',
        'Bank',
        'Kepolisian',
        'Transportasi',
        'Administrasi',
      ]));
    });

    test('Default phrases have minimum 8 phrases per category', () {
      final counts = <String, int>{};
      for (final p in QuickPhrasesRepository.defaultPhrases) {
        counts[p.category] = (counts[p.category] ?? 0) + 1;
      }

      for (final cat in ['Umum', 'Rumah Sakit', 'Bank', 'Kepolisian', 'Transportasi', 'Administrasi']) {
        expect(counts[cat]! >= 8, isTrue, reason: 'Category $cat should have at least 8 phrases');
      }
    });

    test('Default phrases IDs are unique', () {
      final ids = QuickPhrasesRepository.defaultPhrases.map((e) => e.id).toList();
      expect(ids.length, equals(ids.toSet().length));
    });
  });
}


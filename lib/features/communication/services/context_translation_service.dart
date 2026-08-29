import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/context_preset.dart';

abstract class IContextTranslationService {
  Future<String> translateContext({required String rawText, required ContextPreset preset});
}

class SupabaseContextTranslationService implements IContextTranslationService {

  @override
  Future<String> translateContext({required String rawText, required ContextPreset preset}) async {
    if (rawText.trim().isEmpty) return '';

    try {
      final apiKey = dotenv.env['GROQ_API_KEY'];
      if (apiKey != null && apiKey.isNotEmpty) {
        final contextName = preset.label;

        final systemPrompt = '''Anda adalah asisten penerjemah bahasa untuk penyandang Tuli.
Tugas Anda adalah mengubah teks masukan yang berantakan, singkat, atau kaku menjadi kalimat Bahasa Indonesia yang formal, sopan, dan jelas sesuai dengan konteks yang diberikan.

Konteks saat ini: $contextName
Teks masukan: "$rawText"

Aturan ketat:
1. JANGAN menambahkan komentar, basa-basi, atau penjelasan.
2. HANYA balas dengan hasil terjemahan akhirnya saja (1 kalimat).
3. Gunakan kata sapaan yang sesuai jika konteksnya Rumah Sakit (contoh: Dokter/Suster) atau Publik (Bapak/Ibu).
4. Jika input hanya 1 kata (misal: "aduh", "mual"), tetap ubah menjadi kalimat utuh yang sopan.''';

        final response = await http.post(
          Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: jsonEncode({
            'model': 'qwen/qwen3.8-27b',
            'temperature': 0.2,
            'max_tokens': 150,
            'messages': [
              {'role': 'system', 'content': systemPrompt},
              {'role': 'user', 'content': rawText},
            ],
          }),
        ).timeout(const Duration(seconds: 8));

        debugPrint('[BENTARA AI] Groq Status: ${response.statusCode}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final translated = data['choices'][0]['message']['content'] as String;
          if (translated.trim().isNotEmpty) {
            // Bersihkan output (hapus tanda kutip, <think> tags, dsb.)
            String clean = translated.trim();
            clean = clean.replaceAll(RegExp(r'<think>.*?</think>', dotAll: true), '');
            clean = clean.replaceAll('"', '');
            clean = clean.trim();
            if (clean.isNotEmpty) {
              debugPrint('[BENTARA AI] Translated: $clean');
              return clean;
            }
          }
        } else {
          debugPrint('[BENTARA AI] Groq Error ${response.statusCode}: ${response.body}');
        }
      }
    } catch (e) {
      debugPrint('[BENTARA AI] Groq API exception: $e');
    }

    // Fallback ke rule-based jika API gagal
    debugPrint('[BENTARA AI] Using rule-based fallback');
    return _ruleBasedFallback(rawText, preset);
  }

  String _ruleBasedFallback(String text, ContextPreset preset) {
    final lower = text.toLowerCase().trim();

    // === CONTOH SPESIFIK DARI PROPOSAL (Jaring Pengaman Demo) ===

    // Proposal: "Perut saya sakit dua hari" -> "Saya mengalami sakit perut selama dua hari."
    if (lower.contains('perut') && lower.contains('sakit')) {
      return 'Saya mengalami sakit perut dan membutuhkan pertolongan medis.';
    }

    // Proposal: "mau daftar yang BPJS bisa nggak ya" -> "Saya ingin mendaftar layanan menggunakan BPJS."
    if (lower.contains('daftar') && lower.contains('bpjs')) {
      return 'Saya ingin mendaftar layanan menggunakan BPJS.';
    }

    // Proposal: "tolong cepat ini darurat" -> "Saya membutuhkan bantuan darurat sekarang."
    if (lower.contains('tolong') && (lower.contains('darurat') || lower.contains('cepat'))) {
      return 'Saya membutuhkan bantuan darurat sekarang!';
    }

    // Demo Runbook: "obat pusing mana"
    if (lower.contains('obat') && lower.contains('pusing')) {
      return 'Maaf, di mana saya bisa mendapatkan obat untuk sakit kepala saya?';
    }

    // === KAMUS KONTEKSTUAL PER PRESET ===
    switch (preset) {
      case ContextPreset.rumahSakit:
        // Kata-kata umum medis
        if (lower.contains('sakit')) return 'Maaf Dokter, saya merasakan sakit dan membutuhkan pemeriksaan.';
        if (lower.contains('pusing') || lower.contains('pening')) return 'Maaf Dokter, kepala saya terasa sangat pusing.';
        if (lower.contains('mual') || lower.contains('muntah')) return 'Maaf Dokter, saya merasa sangat mual dan ingin muntah.';
        if (lower.contains('demam') || lower.contains('panas')) return 'Maaf Dokter, badan saya terasa demam dan panas.';
        if (lower.contains('sesak') || lower.contains('nafas') || lower.contains('napas')) return 'Maaf Dokter, saya mengalami sesak napas.';
        if (lower.contains('luka') || lower.contains('berdarah')) return 'Maaf Dokter, saya memiliki luka yang perlu ditangani.';
        if (lower.contains('patah') || lower.contains('keseleo')) return 'Maaf Dokter, saya mengalami cedera dan membutuhkan pemeriksaan.';
        if (lower.contains('obat')) return 'Maaf, di mana saya bisa mendapatkan obat yang saya butuhkan?';
        if (lower.contains('periksa') || lower.contains('cek')) return 'Saya ingin melakukan pemeriksaan kesehatan.';
        if (lower.contains('antri') || lower.contains('antre')) return 'Maaf, di mana saya harus mengambil nomor antrian?';
        if (lower.contains('rawat') || lower.contains('inap')) return 'Saya memerlukan informasi mengenai rawat inap.';
        if (lower.contains('aduh') || lower.contains('auw')) return 'Maaf Dokter, saya merasa sangat kesakitan.';
        break;

      case ContextPreset.layananPublik:
        if (lower.contains('ktp') || lower.contains('identitas')) return 'Saya ingin mengurus pembuatan KTP.';
        if (lower.contains('sim') || lower.contains('mengemudi')) return 'Saya ingin mengurus pembuatan SIM.';
        if (lower.contains('surat') || lower.contains('dokumen')) return 'Saya memerlukan bantuan untuk mengurus dokumen surat-menyurat.';
        if (lower.contains('lapor') || lower.contains('aduan')) return 'Saya ingin melaporkan sebuah kejadian penting.';
        if (lower.contains('bikin') || lower.contains('buat')) return 'Saya ingin membuat dokumen resmi, mohon bantuannya.';
        if (lower.contains('bayar') || lower.contains('biaya')) return 'Berapa biaya yang perlu saya bayarkan untuk layanan ini?';
        if (lower.contains('tanya') || lower.contains('info')) return 'Maaf, saya ingin bertanya mengenai informasi layanan yang tersedia.';
        break;

      case ContextPreset.darurat:
        if (lower.contains('ambulans') || lower.contains('medis')) return 'DARURAT: Tolong panggil ambulans, saya membutuhkan pertolongan medis segera!';
        if (lower.contains('polisi') || lower.contains('bahaya')) return 'DARURAT: Tolong hubungi polisi, saya dalam keadaan bahaya!';
        if (lower.contains('kebakaran') || lower.contains('api')) return 'DARURAT: Terjadi kebakaran, tolong panggil pemadam kebakaran segera!';
        return 'DARURAT: Saya membutuhkan bantuan segera!';

      case ContextPreset.umum:
        if (lower.contains('halo') || lower.contains('hai')) return 'Halo, selamat datang. Ada yang bisa saya bantu?';
        if (lower.contains('terima kasih') || lower.contains('makasih')) return 'Terima kasih banyak atas bantuannya.';
        if (lower.contains('maaf')) return 'Mohon maaf atas ketidaknyamanan yang terjadi.';
        if (lower.contains('tolong') || lower.contains('bantu')) return 'Mohon bantuan Anda, saya memerlukan pertolongan.';
        break;
    }

    // Fallback universal: Rapikan teks
    String polished = text.trim().replaceAll(RegExp(r'\s+'), ' ');
    polished = polished.replaceAll(RegExp(r'\b(ee|ehm|anu|kayak|terus|tuh|gitu)\b', caseSensitive: false), '');
    polished = polished.trim();
    if (polished.isNotEmpty) {
      polished = polished[0].toUpperCase() + polished.substring(1);
      if (!polished.endsWith('.') && !polished.endsWith('!') && !polished.endsWith('?')) {
        polished += '.';
      }
    }
    return polished;
  }
}

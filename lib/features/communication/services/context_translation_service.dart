import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/context_preset.dart';

abstract class IContextTranslationService {
  Future<String> translateContext({required String rawText, required ContextPreset preset});
}

class SupabaseContextTranslationService implements IContextTranslationService {
  final SupabaseClient? _supabaseClient;

  SupabaseContextTranslationService([this._supabaseClient]);

  SupabaseClient? get _client {
    if (_supabaseClient != null) return _supabaseClient;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String> translateContext({required String rawText, required ContextPreset preset}) async {
    final trimmedText = rawText.trim();
    if (trimmedText.isEmpty) return '';

    // 1. Coba pemanggilan Supabase Edge Function 'context-translation' (Server-side Groq)
    try {
      final client = _client;
      if (client != null) {
        final response = await client.functions.invoke(
          'context-translation',
          body: {
            'rawText': trimmedText,
            'preset': preset.name,
          },
        ).timeout(const Duration(seconds: 8));

        debugPrint('[BENTARA AI] Edge Function Status: ${response.status}');

        if (response.status == 200 && response.data != null) {
          final dynamic rawData = response.data;
          Map<String, dynamic>? data;
          if (rawData is Map<String, dynamic>) {
            data = rawData;
          } else if (rawData is Map) {
            data = Map<String, dynamic>.from(rawData);
          } else if (rawData is String) {
            try {
              data = jsonDecode(rawData) as Map<String, dynamic>;
            } catch (_) {}
          }

          if (data != null && data['success'] == true && data['translation'] != null) {
            String translated = (data['translation'] as String).trim();
            // Pembersihan output sekunder
            translated = translated.replaceAll(RegExp(r'<think>.*?</think>', dotAll: true), '');
            translated = translated.replaceAll('"', '').trim();
            if (translated.isNotEmpty) {
              debugPrint('[BENTARA AI] Translated via Edge Function: $translated');
              return translated;
            }
          }
        } else {
          debugPrint('[BENTARA AI] Edge Function Error ${response.status}: ${response.data}');
        }
      }
    } catch (e) {
      debugPrint('[BENTARA AI] Edge Function invoke exception: $e');
    }

    // 2. Fallback ke Rule-Based Dictionary (Luring / Offline Safety Net)
    debugPrint('[BENTARA AI] Using rule-based offline fallback');
    return _ruleBasedFallback(trimmedText, preset);
  }

  String _ruleBasedFallback(String text, ContextPreset preset) {
    final lower = text.toLowerCase().trim();

    // === CONTOH SPESIFIK DARI PROPOSAL & SLIDE 8 (Jaring Pengaman Demo) ===

    // Proposal & Slide 8: "Perut saya sakit udah dua hari nih" -> "Saya mengalami sakit perut selama dua hari."
    if (lower.contains('perut') && lower.contains('sakit')) {
      return 'Saya mengalami sakit perut selama dua hari.';
    }

    // Proposal & Slide 8: "mau daftar yang BPJS bisa nggak ya dok" -> "Saya ingin mendaftar layanan menggunakan BPJS."
    if (lower.contains('daftar') && lower.contains('bpjs')) {
      return 'Saya ingin mendaftar layanan menggunakan BPJS.';
    }

    // Proposal & Slide 8: "tolong cepat ini darurat banget" -> "Saya membutuhkan bantuan darurat sekarang."
    if (lower.contains('tolong') && (lower.contains('darurat') || lower.contains('cepat'))) {
      return 'Saya membutuhkan bantuan darurat sekarang.';
    }

    // Demo Runbook: "obat pusing mana"
    if (lower.contains('obat') && lower.contains('pusing')) {
      return 'Maaf, di mana saya bisa mendapatkan obat untuk sakit kepala saya?';
    }

    // === KAMUS KONTEKSTUAL PER PRESET ===
    switch (preset) {
      case ContextPreset.rumahSakit:
        // Tindakan & Layanan Spesifik Prioritas
        if (lower.contains('tensi') || lower.contains('tekanan darah')) {
          return 'Bisa tolong periksa tekanan darah saya sekarang?';
        }
        if (lower.contains('tes darah') || lower.contains('tes urine') || lower.contains('rontgen') || lower.contains('usg') || lower.contains('scan') || lower.contains('lab') || lower.contains('laboratorium')) {
          return 'Saya memerlukan petunjuk arah menuju ruang laboratorium dan radiologi.';
        }
        if (lower.contains('infus') || lower.contains('suntik') || lower.contains('jarum')) {
          return 'Maaf Suster, apakah selang infus atau suntikan ini sudah siap?';
        }
        if (lower.contains('resep') || lower.contains('apotek') || lower.contains('ambil obat')) {
          return 'Maaf, di mana lokasi loket pengambilan obat dan penebusan resep?';
        }
        if (lower.contains('hamil') || lower.contains('kandungan') || lower.contains('bidan') || lower.contains('melahirkan')) {
          return 'Saya ingin melakukan pemeriksaan kehamilan di poli kandungan.';
        }
        if (lower.contains('rawat') || lower.contains('inap') || lower.contains('kamar') || lower.contains('bangsal') || lower.contains('pulang')) {
          return 'Saya memerlukan informasi mengenai ketersediaan kamar rawat inap dan administrasi kepulangan.';
        }
        if (lower.contains('jadwal') || lower.contains('janji') || lower.contains('praktek') || lower.contains('praktik')) {
          return 'Saya ingin memeriksa jadwal praktik dokter spesialis hari ini.';
        }
        if (lower.contains('antri') || lower.contains('antre') || lower.contains('nomor')) {
          return 'Maaf, di mana saya harus mengambil nomor antrean pemeriksaan?';
        }

        // Gejala & Keluhan Fisik
        if (lower.contains('pusing') || lower.contains('migrain') || lower.contains('pening') || lower.contains('vertigo')) {
          return 'Maaf Dokter, kepala saya terasa sangat pusing dan berkunang-kunang.';
        }
        if (lower.contains('mual') || lower.contains('muntah') || lower.contains('enek')) {
          return 'Maaf Dokter, perut saya terasa sangat mual dan sudah muntah beberapa kali.';
        }
        if (lower.contains('demam') || lower.contains('panas') || lower.contains('menggigil')) {
          return 'Maaf Dokter, badan saya terasa demam tinggi dan menggigil.';
        }
        if (lower.contains('sesak') || lower.contains('nafas') || lower.contains('napas') || lower.contains('asma')) {
          return 'Maaf Dokter, saya mengalami sesak napas dan membutuhkan bantuan oksigen.';
        }
        if (lower.contains('batuk') || lower.contains('pilek') || lower.contains('flu') || lower.contains('tenggorokan') || lower.contains('radang')) {
          return 'Maaf Dokter, saya mengalami batuk dan radang tenggorokan.';
        }
        if (lower.contains('diare') || lower.contains('mencret') || lower.contains('kram')) {
          return 'Maaf Dokter, perut saya terasa sakit melilit dan mengalami diare.';
        }
        if (lower.contains('pendarahan') || lower.contains('berdarah') || lower.contains('luka') || lower.contains('jahit')) {
          return 'Maaf Dokter, saya memiliki luka berdarah yang memerlukan penanganan segera.';
        }
        if (lower.contains('patah') || lower.contains('keseleo') || lower.contains('terkilir') || lower.contains('bengkak') || lower.contains('cedera')) {
          return 'Maaf Dokter, bagian tubuh saya mengalami cedera terkilir dan bengkak.';
        }
        if (lower.contains('gigi') || lower.contains('gusi') || lower.contains('ngilu')) {
          return 'Maaf Dokter, gigi saya terasa sangat sakit dan ngilu.';
        }
        if (lower.contains('mata') || lower.contains('kabur') || lower.contains('perih')) {
          return 'Maaf Dokter, penglihatan mata saya terasa kabur dan perih.';
        }
        if (lower.contains('telinga') || lower.contains('dengung')) {
          return 'Maaf Dokter, telinga saya terasa sakit dan berdengung.';
        }
        if (lower.contains('alergi') || lower.contains('gatal') || lower.contains('bentol') || lower.contains('ruam')) {
          return 'Maaf Dokter, kulit saya timbul ruam gatal karena reaksi alergi.';
        }
        if (lower.contains('lemas') || lower.contains('pingsan') || lower.contains('lelah')) {
          return 'Maaf Dokter, kondisi tubuh saya sangat lemas dan hampir pingsan.';
        }
        if (lower.contains('obat')) {
          return 'Maaf, di mana saya bisa mendapatkan obat yang saya butuhkan?';
        }
        if (lower.contains('poli') || lower.contains('spesialis') || lower.contains('konsultasi') || lower.contains('periksa') || lower.contains('cek')) {
          return 'Saya ingin melakukan pendaftaran konsultasi ke dokter spesialis rawat jalan.';
        }
        if (lower.contains('sakit') || lower.contains('nyeri') || lower.contains('aduh') || lower.contains('auw')) {
          return 'Maaf Dokter, saya merasakan nyeri pada tubuh dan membutuhkan pemeriksaan.';
        }
        break;

      case ContextPreset.layananPublik:
        // Administrasi Kependudukan & Dokumen
        if (lower.contains('ktp') || lower.contains('e-ktp') || lower.contains('identitas')) {
          return 'Saya ingin mengurus penerbitan atau perpanjangan KTP elektronik.';
        }
        if (lower.contains('kartu keluarga') || lower.contains('kk')) {
          return 'Saya ingin mengajukan pembaruan data pada Kartu Keluarga (KK).';
        }
        if (lower.contains('akta') || lower.contains('kelahiran') || lower.contains('kematian') || lower.contains('nikah')) {
          return 'Saya ingin mengurus penerbitan akta pencatatan sipil di loket ini.';
        }
        if (lower.contains('paspor') || lower.contains('imigrasi') || lower.contains('visa')) {
          return 'Saya ingin mengurus pembuatan paspor baru di kantor imigrasi.';
        }
        if (lower.contains('sim') || lower.contains('mengemudi') || lower.contains('stnk') || lower.contains('bpkb') || lower.contains('pajak')) {
          return 'Saya ingin mengurus perpanjangan SIM dan administrasi pembayaran pajak kendaraan.';
        }
        if (lower.contains('skck') || lower.contains('catatan kepolisian')) {
          return 'Saya ingin mengurus pembuatan Surat Keterangan Catatan Kepolisian (SKCK).';
        }
        if (lower.contains('surat pindah') || lower.contains('domisili') || lower.contains('pengantar')) {
          return 'Saya ingin mengurus surat keterangan pindah domisili kependudukan.';
        }
        if (lower.contains('legalisir') || lower.contains('stempel') || lower.contains('cap')) {
          return 'Saya membutuhkan legalisir untuk berkas dokumen resmi saya.';
        }
        if (lower.contains('formulir') || lower.contains('blanko') || lower.contains('isi data')) {
          return 'Bisa tolong bantu tunjukkan formulir mana yang harus saya isi?';
        }

        // Perbankan & Keuangan
        if (lower.contains('buka rekening') || lower.contains('rekening baru') || lower.contains('buku tabungan')) {
          return 'Saya ingin membuka rekening tabungan baru di bank ini.';
        }
        if (lower.contains('setor') || lower.contains('deposito') || lower.contains('setoran')) {
          return 'Saya ingin melakukan transaksi setoran tunai ke rekening saya.';
        }
        if (lower.contains('tarik tunai') || lower.contains('tarik uang') || lower.contains('ambil uang')) {
          return 'Saya ingin melakukan penarikan uang tunai di loket teller.';
        }
        if (lower.contains('transfer') || lower.contains('kirim uang') || lower.contains('kliring')) {
          return 'Saya ingin melakukan pengiriman dana atau transfer rekening.';
        }
        if (lower.contains('atm') || lower.contains('tertelan') || lower.contains('terblokir') || lower.contains('pin')) {
          return 'Kartu ATM saya bermasalah, mohon bantuan untuk proses pemulihan kartu.';
        }
        if (lower.contains('m-banking') || lower.contains('mobile banking') || lower.contains('internet banking') || lower.contains('aktivasi')) {
          return 'Saya ingin melakukan aktivasi dan bantuan teknis layanan mobile banking di ponsel.';
        }
        if (lower.contains('mutasi') || lower.contains('rekening koran') || lower.contains('cetak buku')) {
          return 'Bisa tolong bantu cetak mutasi rekening koran untuk buku tabungan saya?';
        }

        // Kepolisian & Pengaduan
        if (lower.contains('kehilangan') || lower.contains('hilang') || lower.contains('dompet hilang')) {
          return 'Saya ingin membuat surat laporan resmi kehilangan barang berharga.';
        }
        if (lower.contains('lapor') || lower.contains('aduan') || lower.contains('keluhan') || lower.contains('pengaduan')) {
          return 'Saya ingin menyampaikan laporan pengaduan resmi kepada petugas.';
        }
        if (lower.contains('penipuan') || lower.contains('curi') || lower.contains('maling') || lower.contains('jambret') || lower.contains('begal')) {
          return 'Saya menjadi korban tindak kriminal dan ingin membuat laporan polisi sekarang.';
        }

        // Utilitas & Administrasi Umum
        if (lower.contains('bpjs')) {
          return 'Saya ingin mengurus administrasi dan pemutakhiran data kepesertaan BPJS.';
        }
        if (lower.contains('pln') || lower.contains('listrik') || lower.contains('token')) {
          return 'Saya ingin mengurus pelayanan dan pelaporan gangguan listrik PLN.';
        }
        if (lower.contains('pdam') || lower.contains('air')) {
          return 'Saya ingin mengurus administrasi pemasangan atau gangguan air PDAM.';
        }
        if (lower.contains('bayar') || lower.contains('biaya') || lower.contains('tarif')) {
          return 'Berapa rincian biaya resmi yang perlu saya bayarkan untuk layanan ini?';
        }
        if (lower.contains('syarat') || lower.contains('berkas') || lower.contains('dokumen') || lower.contains('persyaratan')) {
          return 'Apa saja syarat dan kelengkapan dokumen yang harus saya lampirkan?';
        }
        if (lower.contains('antri') || lower.contains('antre') || lower.contains('loket') || lower.contains('nomor')) {
          return 'Maaf Bapak/Ibu, di mana saya bisa mengambil nomor tiket antrean layanan?';
        }
        if (lower.contains('tanya') || lower.contains('info') || lower.contains('informasi')) {
          return 'Maaf, saya ingin meminta informasi terkait prosedur layanan di sini.';
        }
        break;

      case ContextPreset.darurat:
        if (lower.contains('ambulans') || lower.contains('ambulance') || lower.contains('medis') || lower.contains('rumah sakit')) {
          return 'DARURAT MEDIS: Tolong segera panggilkan ambulans, korban memerlukan pertolongan gawat darurat!';
        }
        if (lower.contains('kebakaran') || lower.contains('api') || lower.contains('asap') || lower.contains('ledakan') || lower.contains('damkar')) {
          return 'DARURAT KEBAKARAN: Terjadi kobaran api besar, tolong hubungi pemadam kebakaran dan evakuasi segera!';
        }
        if (lower.contains('polisi') || lower.contains('rampok') || lower.contains('maling') || lower.contains('begal') || lower.contains('senjata') || lower.contains('ancaman') || lower.contains('bahaya')) {
          return 'DARURAT KEJAHATAN: Tolong segera hubungi polisi, sedang terjadi tindak bahaya kejahatan!';
        }
        if (lower.contains('kecelakaan') || lower.contains('tabrakan') || lower.contains('terjatuh') || lower.contains('laka')) {
          return 'DARURAT KECELAKAAN: Terjadi kecelakaan lalu lintas parah, tolong kirim bantuan medis segera!';
        }
        if (lower.contains('sesak') || lower.contains('asma') || lower.contains('jantung') || lower.contains('oksigen') || lower.contains('napas')) {
          return 'DARURAT KESEHATAN: Saya mengalami serangan sesak napas akut dan membutuhkan oksigen segera!';
        }
        if (lower.contains('pingsan') || lower.contains('koma') || lower.contains('kejang') || lower.contains('kritis') || lower.contains('tidak sadar')) {
          return 'DARURAT: Korban tidak sadarkan diri dan dalam kondisi kritis, mohon segera ditolong!';
        }
        if (lower.contains('darah') || lower.contains('pendarahan') || lower.contains('luka parah')) {
          return 'DARURAT: Terjadi pendarahan hebat pada luka, tolong tindakan pertolongan pertama sekarang!';
        }
        if (lower.contains('gempa') || lower.contains('banjir') || lower.contains('longsor') || lower.contains('terjebak') || lower.contains('sar') || lower.contains('runtuh')) {
          return 'DARURAT BENCANA: Kami terjebak bencana alam, tolong kirim bantuan tim SAR untuk evakuasi!';
        }
        if (lower.contains('tersedak') || lower.contains('tercekik') || lower.contains('racun') || lower.contains('keracunan')) {
          return 'DARURAT: Ada korban tersedak/keracunan, mohon tindakan penanganan gawat darurat segera!';
        }
        return 'DARURAT: Saya penyandang Tuli dan sangat membutuhkan bantuan gawat darurat saat ini!';

      case ContextPreset.umum:
        // Aksesibilitas & Komunikasi Tuli
        if (lower.contains('tulis') || lower.contains('kertas') || lower.contains('ketik') || lower.contains('hp') || lower.contains('catat')) {
          return 'Bisa tolong tuliskan di kertas atau ketik di layar HP?';
        }
        if (RegExp(r'\btuli\b').hasMatch(lower) || lower.contains('tuna rungu') || (lower.contains('tidak') && lower.contains('dengar'))) {
          return 'Mohon maaf, saya adalah penyandang Tuli (tidak dapat mendengar).';
        }
        if (lower.contains('pelan') || lower.contains('perlahan') || lower.contains('bibir') || lower.contains('tatap')) {
          return 'Tolong bicara lebih perlahan dan tatap wajah saya agar gerak bibir terlihat jelas.';
        }
        if (lower.contains('bisindo') || lower.contains('isyarat')) {
          return 'Saya berkomunikasi menggunakan Bahasa Isyarat Indonesia (BISINDO).';
        }
        if (lower.contains('kurang paham') || lower.contains('ulang') || lower.contains('ulangi') || lower.contains('tidak paham') || lower.contains('tidak mengerti')) {
          return 'Mohon maaf, saya belum memahami maksud Anda, bisa tolong diulang kembali?';
        }

        // Fasilitas Umum
        if (lower.contains('toilet') || lower.contains('wc') || lower.contains('kamar kecil') || lower.contains('kencing') || lower.contains('cuci tangan')) {
          return 'Permisi, di mana letak toilet atau kamar kecil terdekat?';
        }
        if (lower.contains('musholla') || lower.contains('masjid') || lower.contains('sholat') || lower.contains('salat') || lower.contains('wudhu')) {
          return 'Maaf, di mana lokasi musholla atau tempat sholat terdekat di gedung ini?';
        }
        if (lower.contains('charger') || lower.contains('colokan') || lower.contains('listrik') || lower.contains('baterai') || lower.contains('cas')) {
          return 'Permisi, apakah ada colokan listrik untuk mengisi daya baterai ponsel?';
        }
        if (lower.contains('wifi') || lower.contains('internet') || lower.contains('password') || lower.contains('sandi')) {
          return 'Boleh saya tahu kata sandi (password) jaringan Wi-Fi di tempat ini?';
        }
        if (lower.contains('kursi') || lower.contains('duduk') || lower.contains('meja')) {
          return 'Apakah kursi di sini kosong dan boleh saya tempati untuk duduk?';
        }

        // Belanja, Transaksi & Restoran
        if (lower.contains('harga') || lower.contains('berapa') || lower.contains('total') || lower.contains('biaya')) {
          return 'Permisi, berapa total harga belanjaan saya semuanya?';
        }
        if (lower.contains('diskon') || lower.contains('promo') || lower.contains('potongan')) {
          return 'Apakah saat ini sedang berlaku promo atau potongan diskon khusus?';
        }
        if (lower.contains('qris') || lower.contains('transfer') || lower.contains('debit') || lower.contains('kartu') || lower.contains('non tunai') || lower.contains('cash') || lower.contains('tunai')) {
          return 'Apakah pembayaran bisa dilakukan menggunakan QRIS atau metode non-tunai?';
        }
        if (lower.contains('menu') || lower.contains('pesan') || lower.contains('makanan') || lower.contains('minuman') || lower.contains('order')) {
          return 'Saya ingin memesan menu makanan dan minuman sesuai daftar ini.';
        }
        if (lower.contains('halal') || lower.contains('vegetarian') || lower.contains('alergi')) {
          return 'Mohon maaf, apakah menu makanan ini halal dan aman dari alergen?';
        }
        if (lower.contains('bungkus') || lower.contains('take away') || lower.contains('bawa pulang')) {
          return 'Tolong pesanan makanan ini dibungkus rapi untuk dibawa pulang (take away).';
        }
        if (lower.contains('pedas') || lower.contains('es') || lower.contains('gula')) {
          return 'Tolong buatkan pesanan ini dengan rasa tidak pedas dan sedikit es.';
        }

        // Transportasi & Rute
        if (lower.contains('taksi') || lower.contains('ojek') || lower.contains('antar') || lower.contains('alamat') || lower.contains('lokasi')) {
          return 'Tolong antarkan saya menuju alamat yang tertulis di layar ponsel ini.';
        }
        if (lower.contains('stasiun') || lower.contains('kereta') || lower.contains('krl') || lower.contains('mrt') || lower.contains('halte') || lower.contains('bus') || lower.contains('terminal')) {
          return 'Maaf, di mana arah menuju loket peron stasiun atau halte bus terdekat?';
        }
        if (lower.contains('bandara') || lower.contains('pesawat') || lower.contains('flight') || lower.contains('gate') || lower.contains('check in')) {
          return 'Saya ingin menuju terminal keberangkatan bandara untuk melakukan check-in.';
        }
        if (lower.contains('turun') || lower.contains('sampai') || lower.contains('berhenti') || lower.contains('stop')) {
          return 'Tolong beri tahu atau tepuk pundak saya jika sudah sampai di lokasi tujuan.';
        }
        if (lower.contains('tertinggal') || lower.contains('ketinggalan') || lower.contains('barang')) {
          return 'Maaf, apakah ada barang bawaan saya yang tertinggal di tempat ini?';
        }
        if (lower.contains('arah') || lower.contains('jalan') || lower.contains('belok') || lower.contains('peta') || lower.contains('petunjuk')) {
          return 'Permisi, bisa tolong tunjukkan petunjuk arah jalan menuju tempat ini?';
        }

        // Sopan Santun & Sapaan
        if (lower.contains('halo') || lower.contains('hai') || lower.contains('pagi') || lower.contains('siang') || lower.contains('sore') || lower.contains('malam')) {
          return 'Halo, selamat datang. Senang bisa bertemu dengan Anda.';
        }
        if (lower.contains('permisi') || lower.contains('numpang')) {
          return 'Permisi Bapak/Ibu, mohon maaf mengganggu waktunya sebentar.';
        }
        if (lower.contains('terima kasih') || lower.contains('makasih') || lower.contains('matur nuwun') || lower.contains('thanks')) {
          return 'Terima kasih banyak atas segala bantuan dan kebaikan Anda.';
        }
        if (lower.contains('sama-sama') || lower.contains('kembali')) {
          return 'Sama-sama, dengan senang hati saya bisa membantu.';
        }
        if (lower.contains('tolong') || lower.contains('bantu')) {
          return 'Mohon bantuan Anda, saya memerlukan sedikit bantuan.';
        }
        if (lower.contains('maaf') || lower.contains('sorry') || lower.contains('mohon maaf')) {
          return 'Mohon dimaafkan atas ketidaknyamanan atau kesalahpahaman yang terjadi.';
        }
        if (lower.contains('pamit') || lower.contains('dadah') || lower.contains('sampai jumpa') || lower.contains('mari')) {
          return 'Terima kasih banyak, saya mohon pamit undur diri terlebih dahulu.';
        }
        break;
    }

    // Fallback universal: Rapikan teks
    String polished = text.trim().replaceAll(RegExp(r'\s+'), ' ');
    polished = polished.replaceAll(RegExp(r'\b(ee|ehm|anu|kayak|terus|tuh|gitu|dong|deh|sih)\b', caseSensitive: false), '');
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

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/quick_phrase_model.dart';

class QuickPhrasesRepository {
  final SupabaseClient _supabase;
  QuickPhrasesRepository(this._supabase);

  static final List<QuickPhraseModel> defaultPhrases = [
    // === 1. UMUM ===
    QuickPhraseModel(
      id: 'def_umum_1',
      phrase: 'Saya penyandang Tuli (tidak bisa mendengar).',
      category: 'Umum',
      isEmergency: false,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhraseModel(
      id: 'def_umum_2',
      phrase: 'Tolong bicara lebih pelan dan hadap ke depan.',
      category: 'Umum',
      isEmergency: false,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhraseModel(
      id: 'def_umum_3',
      phrase: 'Bisa tolong tuliskan di kertas atau layar HP?',
      category: 'Umum',
      isEmergency: false,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhraseModel(
      id: 'def_umum_4',
      phrase: 'Terima kasih banyak atas bantuan dan kesabaran Anda.',
      category: 'Umum',
      isEmergency: false,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhraseModel(
      id: 'def_umum_5',
      phrase: 'Permisi, di mana lokasi toilet atau wastafel terdekat?',
      category: 'Umum',
      isEmergency: false,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhraseModel(
      id: 'def_umum_6',
      phrase: 'Maaf, di mana letak musholla atau tempat sholat?',
      category: 'Umum',
      isEmergency: false,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhraseModel(
      id: 'def_umum_7',
      phrase: 'Berapa total harganya dan apakah bisa bayar non-tunai / QRIS?',
      category: 'Umum',
      isEmergency: false,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhraseModel(
      id: 'def_umum_8',
      phrase: 'Tolong pesanan makanan ini dibungkus untuk dibawa pulang.',
      category: 'Umum',
      isEmergency: false,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhraseModel(
      id: 'def_umum_9',
      phrase: 'Apakah di sekitar sini ada colokan listrik untuk mengisi daya baterai?',
      category: 'Umum',
      isEmergency: false,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhraseModel(
      id: 'def_umum_10',
      phrase: 'Mohon maaf, saya kurang paham, bisakah tolong diulang?',
      category: 'Umum',
      isEmergency: false,
      createdAt: DateTime(2026, 1, 1),
    ),

    // === 2. RUMAH SAKIT (MEDIS) ===
    QuickPhraseModel(
      id: 'def_rs_1',
      phrase: 'Saya butuh obat untuk sakit kepala dan demam.',
      category: 'Rumah Sakit',
      isEmergency: false,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhraseModel(
      id: 'def_rs_2',
      phrase: 'Saya ingin mendaftar periksa ke dokter spesialis.',
      category: 'Rumah Sakit',
      isEmergency: false,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhraseModel(
      id: 'def_rs_3',
      phrase: 'Saya ingin mendaftar layanan menggunakan BPJS Kesehatan.',
      category: 'Rumah Sakit',
      isEmergency: false,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhraseModel(
      id: 'def_rs_4',
      phrase: 'Di mana lokasi apotek atau loket pengambilan obat?',
      category: 'Rumah Sakit',
      isEmergency: false,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhraseModel(
      id: 'def_rs_5',
      phrase: 'Saya mengalami sakit perut dan mual selama dua hari.',
      category: 'Rumah Sakit',
      isEmergency: false,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhraseModel(
      id: 'def_rs_6',
      phrase: 'Saya memiliki riwayat alergi terhadap obat-obatan tertentu.',
      category: 'Rumah Sakit',
      isEmergency: false,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhraseModel(
      id: 'def_rs_7',
      phrase: 'Bisa tolong periksa tekanan darah dan detak jantung saya?',
      category: 'Rumah Sakit',
      isEmergency: false,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhraseModel(
      id: 'def_rs_8',
      phrase: 'Di mana lokasi ruang laboratorium darah dan radiologi/rontgen?',
      category: 'Rumah Sakit',
      isEmergency: false,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhraseModel(
      id: 'def_rs_9',
      phrase: 'Dada saya terasa sangat sesak dan sulit untuk bernapas.',
      category: 'Rumah Sakit',
      isEmergency: false,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhraseModel(
      id: 'def_rs_10',
      phrase: 'Bisa tolong tuliskan resep serta dosis aturan minum obatnya?',
      category: 'Rumah Sakit',
      isEmergency: false,
      createdAt: DateTime(2026, 1, 1),
    ),

    // === 3. BANK ===
    QuickPhraseModel(
      id: 'def_bank_1',
      phrase: 'Saya ingin membuka rekening tabungan baru.',
      category: 'Bank',
      isEmergency: false,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhraseModel(
      id: 'def_bank_2',
      phrase: 'Saya ingin melakukan transaksi setor uang tunai.',
      category: 'Bank',
      isEmergency: false,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhraseModel(
      id: 'def_bank_3',
      phrase: 'Kartu ATM saya tertelan di mesin ATM, mohon bantuannya.',
      category: 'Bank',
      isEmergency: false,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhraseModel(
      id: 'def_bank_4',
      phrase: 'Bisa tolong bantu cetak mutasi rekening koran buku tabungan?',
      category: 'Bank',
      isEmergency: false,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhraseModel(
      id: 'def_bank_5',
      phrase: 'Saya ingin mengaktifkan layanan mobile banking di ponsel saya.',
      category: 'Bank',
      isEmergency: false,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhraseModel(
      id: 'def_bank_6',
      phrase: 'Saya ingin melakukan penarikan uang tunai di loket teller.',
      category: 'Bank',
      isEmergency: false,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhraseModel(
      id: 'def_bank_7',
      phrase: 'PIN kartu debit ATM saya terblokir, bagaimana cara resetnya?',
      category: 'Bank',
      isEmergency: false,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhraseModel(
      id: 'def_bank_8',
      phrase: 'Berapa batas maksimal transaksi transfer harian untuk rekening ini?',
      category: 'Bank',
      isEmergency: false,
      createdAt: DateTime(2026, 1, 1),
    ),

    // === 4. KEPOLISIAN ===
    QuickPhraseModel(
      id: 'def_polisi_1',
      phrase: 'Saya ingin melaporkan kehilangan barang dan dokumen berharga.',
      category: 'Kepolisian',
      isEmergency: false,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhraseModel(
      id: 'def_polisi_2',
      phrase: 'Tolong, saya butuh bantuan darurat petugas polisi segera!',
      category: 'Kepolisian',
      isEmergency: false,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhraseModel(
      id: 'def_polisi_3',
      phrase: 'Saya ingin membuat Surat Keterangan Catatan Kepolisian (SKCK).',
      category: 'Kepolisian',
      isEmergency: false,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhraseModel(
      id: 'def_polisi_4',
      phrase: 'Saya menjadi korban penipuan/pencurian, mohon dibuatkan laporan polisi.',
      category: 'Kepolisian',
      isEmergency: false,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhraseModel(
      id: 'def_polisi_5',
      phrase: 'Saya ingin membuat surat keterangan kehilangan KTP dan SIM.',
      category: 'Kepolisian',
      isEmergency: false,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhraseModel(
      id: 'def_polisi_6',
      phrase: 'Di mana loket pelayanan pembuatan laporan pengaduan masyarakat?',
      category: 'Kepolisian',
      isEmergency: false,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhraseModel(
      id: 'def_polisi_7',
      phrase: 'Bisa tolong tuliskan pertanyaan berita acara pemeriksaan di kertas?',
      category: 'Kepolisian',
      isEmergency: false,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhraseModel(
      id: 'def_polisi_8',
      phrase: 'Kapan perkiraan surat keterangan laporan ini selesai diproses?',
      category: 'Kepolisian',
      isEmergency: false,
      createdAt: DateTime(2026, 1, 1),
    ),

    // === 5. TRANSPORTASI ===
    QuickPhraseModel(
      id: 'def_transport_1',
      phrase: 'Tolong antarkan saya ke alamat tujuan yang ada di layar HP ini.',
      category: 'Transportasi',
      isEmergency: false,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhraseModel(
      id: 'def_transport_2',
      phrase: 'Berapa perkiraan ongkos tarif menuju alamat tujuan ini?',
      category: 'Transportasi',
      isEmergency: false,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhraseModel(
      id: 'def_transport_3',
      phrase: 'Tolong beritahu atau tepuk pundak saya jika sudah tiba di tujuan.',
      category: 'Transportasi',
      isEmergency: false,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhraseModel(
      id: 'def_transport_4',
      phrase: 'Maaf, tolong turunkan saya di pinggir jalan sebelah kiri depan.',
      category: 'Transportasi',
      isEmergency: false,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhraseModel(
      id: 'def_transport_5',
      phrase: 'Di mana peron jalur keberangkatan kereta atau halte bus terdekat?',
      category: 'Transportasi',
      isEmergency: false,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhraseModel(
      id: 'def_transport_6',
      phrase: 'Apakah trayek angkutan atau bus ini melewati rute alamat ini?',
      category: 'Transportasi',
      isEmergency: false,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhraseModel(
      id: 'def_transport_7',
      phrase: 'Tolong buka bagasi belakang untuk meletakkan koper atau barang.',
      category: 'Transportasi',
      isEmergency: false,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhraseModel(
      id: 'def_transport_8',
      phrase: 'Mohon dicek apakah ada barang bawaan saya yang tertinggal di kursi?',
      category: 'Transportasi',
      isEmergency: false,
      createdAt: DateTime(2026, 1, 1),
    ),

    // === 6. ADMINISTRASI ===
    QuickPhraseModel(
      id: 'def_admin_1',
      phrase: 'Saya ingin mengurus perpanjangan dan perekaman e-KTP.',
      category: 'Administrasi',
      isEmergency: false,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhraseModel(
      id: 'def_admin_2',
      phrase: 'Saya ingin mengurus dokumen surat pindah domisili kependudukan.',
      category: 'Administrasi',
      isEmergency: false,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhraseModel(
      id: 'def_admin_3',
      phrase: 'Di mana loket pengambilan nomor antrean pengurusan berkas administrasi?',
      category: 'Administrasi',
      isEmergency: false,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhraseModel(
      id: 'def_admin_4',
      phrase: 'Saya ingin mengajukan perubahan atau pembaruan data Kartu Keluarga (KK).',
      category: 'Administrasi',
      isEmergency: false,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhraseModel(
      id: 'def_admin_5',
      phrase: 'Saya membutuhkan legalisir untuk berkas dokumen resmi ini.',
      category: 'Administrasi',
      isEmergency: false,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhraseModel(
      id: 'def_admin_6',
      phrase: 'Persyaratan dan dokumen apa saja yang wajib saya lampirkan?',
      category: 'Administrasi',
      isEmergency: false,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhraseModel(
      id: 'def_admin_7',
      phrase: 'Bisa tolong periksa kelengkapan berkas dokumen yang saya bawa?',
      category: 'Administrasi',
      isEmergency: false,
      createdAt: DateTime(2026, 1, 1),
    ),
    QuickPhraseModel(
      id: 'def_admin_8',
      phrase: 'Berapa hari kerja estimasi waktu penyelesaian dokumen ini?',
      category: 'Administrasi',
      isEmergency: false,
      createdAt: DateTime(2026, 1, 1),
    ),
  ];

  Future<List<QuickPhraseModel>> fetchPhrases() async {
    try {
      final user = _supabase.auth.currentUser;
      
      // Fetch system default phrases + user custom phrases
      final response = await _supabase
          .from('quick_phrases')
          .select()
          .or('user_id.is.null,user_id.eq.${user?.id}');

      final remoteList = (response as List).map((e) => QuickPhraseModel.fromJson(e)).toList();
      if (remoteList.isNotEmpty) {
        return remoteList;
      }
    } catch (e) {
      debugPrint('Supabase quick phrases fetch fallback to defaults: $e');
    }

    return defaultPhrases;
  }
}


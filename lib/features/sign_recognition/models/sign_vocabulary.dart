class SignVocabulary {
  // Kamus pemetaan label model Teachable Machine ke teks kalimat chat & suara TTS.
  static const Map<String, String> dictionary = {
    // Model Baru (Sesuai labels.txt terbaru):
    '0_halo_apa_kabar': 'Halo, apa kabar?',
    '1_nama': 'Perkenalkan, nama saya Haikal',
    '2_tolong': 'Tolong',
    '3_pusing': 'Pusing',
    '4_terimakasih': 'Terima kasih',
    '5_nama_kamu_siapa': 'Nama kamu siapa?',
    '6_salam_kenal': 'Salam kenal',

    // Pemetaan nama gesture bersih:
    'halo_apa_kabar': 'Halo, apa kabar?',
    'halo': 'Halo, apa kabar?',
    'Halo': 'Halo, apa kabar?',
    'nama': 'Perkenalkan, nama saya Haikal',
    'Nama': 'Perkenalkan, nama saya Haikal',
    'tolong': 'Tolong',
    'Tolong': 'Tolong',
    'pusing': 'Pusing',
    'Pusing': 'Pusing',
    'sakit': 'Pusing',
    'Sakit': 'Pusing',
    'terimakasih': 'Terima kasih',
    'Terimakasih': 'Terima kasih',
    'terima kasih': 'Terima kasih',
    'Terima kasih': 'Terima kasih',
    'nama_kamu_siapa': 'Nama kamu siapa?',
    'nama kamu siapa': 'Nama kamu siapa?',
    'bertanya_nama': 'Nama kamu siapa?',
    'bertanya nama': 'Nama kamu siapa?',
    'salam kenal': 'Salam kenal',
    'Salam kenal': 'Salam kenal',
    'Salam Kenal': 'Salam kenal',

    // Variasi indeks alternatif:
    '0_halo': 'Halo, apa kabar?',
    '0_Halo': 'Halo, apa kabar?',
    '1_Nama': 'Perkenalkan, nama saya Haikal',
    '2_Tolong': 'Tolong',
    '3_Pusing': 'Pusing',
    '4_Terimakasih': 'Terima kasih',
    '5_bertanya_nama': 'Nama kamu siapa?',
    '5_bertanya nama': 'Nama kamu siapa?',
    '6_Salam kenal': 'Salam kenal',

    // Cadangan kosakata sebelumnya:
    'asal': 'Saya berasal dari...',
    'tanya_asal': 'Kamu dari mana?',
    'tanya asal': 'Kamu dari mana?',
  };

  /// Mencari pemetaan teks dari label mentah model (misal "0 0_halo", "0_halo", atau "Halo").
  static String? lookup(String rawLabel) {
    // 0. Abaikan secara mutlak jika label adalah 'idle' atau pose diam
    final lowerRaw = rawLabel.toLowerCase().trim();
    if (lowerRaw.contains('idle') || lowerRaw.contains('background')) {
      return null;
    }

    // 1. Cek langsung
    if (dictionary.containsKey(rawLabel)) {
      return dictionary[rawLabel];
    }

    final trimmed = rawLabel.trim();
    if (dictionary.containsKey(trimmed)) {
      return dictionary[trimmed];
    }

    // 2. Bersihkan awalan angka & underscore/spasi (contoh: "0 0_halo" -> "halo", "1_nama" -> "nama")
    var cleaned = trimmed;
    if (cleaned.contains(' ')) {
      cleaned = cleaned.split(' ').sublist(1).join(' ').trim();
    }
    cleaned = cleaned.replaceAll(RegExp(r'^[0-9]+[_\s]*'), '').trim();

    if (dictionary.containsKey(cleaned)) {
      return dictionary[cleaned];
    }

    final lower = cleaned.toLowerCase();
    if (dictionary.containsKey(lower)) {
      return dictionary[lower];
    }

    final underscored = lower.replaceAll(' ', '_');
    if (dictionary.containsKey(underscored)) {
      return dictionary[underscored];
    }

    final spaced = lower.replaceAll('_', ' ');
    if (dictionary.containsKey(spaced)) {
      return dictionary[spaced];
    }

    return null;
  }

  /// Menghasilkan nama gerakan yang rapi untuk tampilan badge UI (misal "0_halo" -> "Halo", "6_tanya_asal" -> "Tanya Asal")
  static String getDisplayName(String rawLabel) {
    var cleaned = rawLabel.trim();
    if (cleaned.contains(' ')) {
      cleaned = cleaned.split(' ').sublist(1).join(' ').trim();
    }
    cleaned = cleaned.replaceAll(RegExp(r'^[0-9]+[_\s]*'), '').trim();
    cleaned = cleaned.replaceAll('_', ' ').trim();

    if (cleaned.isEmpty) return rawLabel;
    return cleaned.split(' ').where((w) => w.isNotEmpty).map((w) => w[0].toUpperCase() + (w.length > 1 ? w.substring(1).toLowerCase() : '')).join(' ');
  }

  static List<String> get rawGestures => dictionary.keys.toList();
}
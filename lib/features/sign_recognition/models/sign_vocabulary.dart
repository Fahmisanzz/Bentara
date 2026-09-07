class SignVocabulary {
  // Kamus pemetaan label model BISINDO (15 kata aktif) ke teks kalimat & suara TTS.
  static const Map<String, String> dictionary = {
    // 5 Kata Awal:
    'halo': 'Halo',
    'Halo': 'Halo',
    'nama': 'Nama',
    'Nama': 'Nama',
    'kamu': 'Kamu',
    'Kamu': 'Kamu',
    'siapa': 'Siapa',
    'Siapa': 'Siapa',
    'terimakasih': 'Terima kasih',
    'Terimakasih': 'Terima kasih',
    'terima kasih': 'Terima kasih',
    'Terima kasih': 'Terima kasih',
    'terimaKasih': 'Terima kasih',

    // 10 Kata Baru:
    'makan': 'Makan',
    'Makan': 'Makan',
    'tidur': 'Tidur',
    'Tidur': 'Tidur',
    'buku': 'Buku',
    'Buku': 'Buku',
    'telepon': 'Telepon',
    'Telepon': 'Telepon',
    'menulis': 'Menulis',
    'Menulis': 'Menulis',
    'jam': 'Jam',
    'Jam': 'Jam',
    'pusing': 'Pusing',
    'Pusing': 'Pusing',
    'pintar': 'Pintar',
    'Pintar': 'Pintar',
    'jalan': 'Jalan',
    'Jalan': 'Jalan',
    'saya': 'Saya',
    'Saya': 'Saya',
  };

  /// Mencari pemetaan teks dari label mentah model (misal "1 0_halo_apa_kabar", "2 1_perkenalkan_nama", atau "Halo").
  static String? lookup(String rawLabel, {String? userName}) {
    // 0. Abaikan secara mutlak jika label adalah 'idle' atau pose diam
    final lowerRaw = rawLabel.toLowerCase().trim();
    if (lowerRaw.contains('idle') || lowerRaw.contains('background')) {
      return null;
    }

    String? found;

    // 1. Cek langsung
    if (dictionary.containsKey(rawLabel)) {
      found = dictionary[rawLabel];
    } else {
      final trimmed = rawLabel.trim();
      if (dictionary.containsKey(trimmed)) {
        found = dictionary[trimmed];
      } else {
        // Cek jika format label Teachable Machine memiliki spasi (contoh: "2 1_perkenalkan_nama" -> "1_perkenalkan_nama")
        if (trimmed.contains(' ')) {
          final strippedFirstWord = trimmed.split(' ').sublist(1).join(' ').trim();
          if (dictionary.containsKey(strippedFirstWord)) {
            found = dictionary[strippedFirstWord];
          }
        }

        if (found == null) {
          // Bersihkan semua awalan angka & underscore/spasi (contoh: "1_perkenalkan_nama" -> "perkenalkan_nama")
          var cleaned = trimmed;
          if (cleaned.contains(' ')) {
            cleaned = cleaned.split(' ').sublist(1).join(' ').trim();
          }
          cleaned = cleaned.replaceAll(RegExp(r'^[0-9]+[_\s]*'), '').trim();

          if (dictionary.containsKey(cleaned)) {
            found = dictionary[cleaned];
          } else {
            final lower = cleaned.toLowerCase();
            if (dictionary.containsKey(lower)) {
              found = dictionary[lower];
            } else {
              final underscored = lower.replaceAll(' ', '_');
              if (dictionary.containsKey(underscored)) {
                found = dictionary[underscored];
              } else {
                final spaced = lower.replaceAll('_', ' ');
                if (dictionary.containsKey(spaced)) {
                  found = dictionary[spaced];
                }
              }
            }
          }
        }
      }
    }

    if (found == null) return null;

    // Personalisasi nama pengguna dinonaktifkan sementara sesuai permintaan pengguna
    // if (userName != null && userName.trim().isNotEmpty && userName.trim().toLowerCase() != 'user') {
    //   if (found.contains('Perkenalkan, nama saya')) {
    //     return 'Perkenalkan, nama saya ${userName.trim()}';
    //   }
    // }

    return found;
  }

  /// Menghasilkan nama gerakan yang rapi untuk tampilan badge UI (misal "1 0_halo_apa_kabar" -> "Halo Apa Kabar", "5 4_terimakasih" -> "Terima Kasih")
  static String getDisplayName(String rawLabel) {
    var cleaned = rawLabel.trim();
    if (cleaned.contains(' ')) {
      cleaned = cleaned.split(' ').sublist(1).join(' ').trim();
    }
    cleaned = cleaned.replaceAll(RegExp(r'^[0-9]+[_\s]*'), '').trim();
    cleaned = cleaned.replaceAll('_', ' ').trim();

    if (cleaned.isEmpty) return rawLabel;

    final lower = cleaned.toLowerCase();
    if (lower == 'terimakasih' || lower == 'terima kasih') {
      return 'Terima Kasih';
    }

    return cleaned.split(' ').where((w) => w.isNotEmpty).map((w) => w[0].toUpperCase() + (w.length > 1 ? w.substring(1).toLowerCase() : '')).join(' ');
  }

  static List<String> get rawGestures => dictionary.keys.toList();
}
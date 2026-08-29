class SignVocabulary {
  // Kamus pemetaan label asli dari Teachable Machine ke teks di chat.
  // Pastikan Anda menamai kelas di Teachable Machine SAMA PERSIS dengan kunci di bawah (tidak usah pakai nomor di TM).
  // Jangan masukkan kelas "Background" / "Kosong" ke dalam kamus ini agar diabaikan sistem.
  static const Map<String, String> dictionary = {
    'Halo': 'Halo',
    'Nama': 'Nama saya Fahmi',
    'Tolong': 'Tolong',
    'Sakit': 'Sakit',
    'Terimakasih': 'Terima kasih',
    
    // Pemetaan cadangan huruf kecil (berjaga-jaga jika di TM ditulis huruf kecil):
    'halo': 'Halo',
    'nama': 'Nama saya Fahmi',
    'tolong': 'Tolong',
    'sakit': 'Sakit',
    'terimakasih': 'Terima kasih',
    'terima kasih': 'Terima kasih',
    'Terima kasih': 'Terima kasih',
  };

  static List<String> get rawGestures => dictionary.keys.toList();
}
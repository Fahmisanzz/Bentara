# BENTARA (KMIPN 2026) - LIVE DEMO RUNBOOK

## 1. Persiapan Perangkat (Device Setup)
- **Koneksi**: Pastikan Wi-Fi terhubung (untuk akses Supabase). Jika internet mati/lambat, aplikasi akan menggunakan mode offline (Mock Repository fallback).
- **Volume**: Maksimalkan volume HP Android agar fitur Text-to-Speech (TTS) terdengar jelas oleh dewan juri.
- **Microphone**: Pastikan izin *Microphone* sudah diberikan saat aplikasi pertama kali dibuka.
- **Login**: Anda bisa menggunakan tombol "Login Cepat (Demo)" di halaman masuk.

## 2. Skenario Live Demo di Panggung

### Skenario A: Mode Teman Tuli & Teman Dengar (Two-Way STT/TTS)
1. **Aksi**: Buka menu **"Komunikasi Langsung"**.
2. **Aksi (Teman Dengar)**: Tekan tombol **Mic Besar** di pojok kanan bawah. Bicaralah: *"Halo, nama saya Budi. Saya dokter spesialis THT."*
3. **Penjelasan Juri**: "Sistem STT langsung menangkap suara dan mencetaknya di layar secara real-time."
4. **Aksi (Teman Tuli)**: Balas dengan mengetik di kolom teks: *"Halo dokter, saya merasa sakit di telinga kanan."* lalu klik tombol **Ucapkan (Ikon Toa)**.
5. **Penjelasan Juri**: "Aplikasi langsung mengucapkan teks tersebut menggunakan TTS agar dokter (Teman Dengar) bisa memahami tanpa harus membaca layar."

### Skenario B: AI Context Translation (Penerjemahan Konteks)
1. **Aksi**: Di menu Komunikasi Langsung, aktifkan ikon **"Magic Wand / Bintang"** di kanan atas (Enable AI Context).
2. **Aksi**: Pilih konteks **"Rumah Sakit"**.
3. **Aksi (Teman Tuli)**: Ketik pesan singkat: *"obat pusing mana"* lalu tekan kirim.
4. **Penjelasan Juri**: "Secara otomatis, AI Context akan mengubah teks kaku tersebut menjadi bahasa medis/formal: *'Maaf, di mana saya bisa mendapatkan obat untuk sakit kepala saya?'* agar pesan lebih sopan dan jelas."

### Skenario C: Tombol Darurat (SOS Emergency)
1. **Aksi**: Kembali ke halaman utama (Home).
2. **Aksi**: Tekan tombol merah raksasa **"TOMBOL DARURAT (SOS)"**.
3. **Aksi**: Pilih "Saya Butuh Ambulans".
4. **Penjelasan Juri**: "Dalam 1 kali ketukan, layar akan berkedip merah terang untuk menarik perhatian, dan TTS akan berteriak minta tolong secara *looping* (berulang-ulang) sampai dimatikan. Data lokasi dan laporan dikirim ke server Supabase secara real-time."

## 3. Fitur Offline & Aksesibilitas
- Jika ditanya oleh juri, silakan buka menu **Pengaturan** (ikon gerigi).
- Tunjukkan slider *Kecepatan Suara* dan *Ukuran Teks*. Jelaskan bahwa semua data preferensi ini disimpan secara **Lokal via Hive**, dan TTS/STT memiliki kapabilitas beroperasi *Offline* secara *on-device*.

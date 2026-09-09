# 🇮🇩 BENTARA — Jembatan Komunikasi Inklusif Teman Tuli & Teman Dengar

<div align="center">

![BENTARA Logo](assets/logos/logo_bentara_biru.webp)

**Aplikasi Komunikasi Dua Arah & Penerjemah Bahasa Isyarat (BISINDO) Berbasis Kecerdasan Buatan (AI)**  
*Dikembangkan untuk Kompetisi Mahasiswa Bidang Informatika Politeknik Nasional (KMIPN 2026)*

[![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.3.0-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-%3E%3D3.3.0-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Riverpod](https://img.shields.io/badge/State_Management-Riverpod_2.5-4053D6?style=for-the-badge)](https://riverpod.dev)
[![Supabase](https://img.shields.io/badge/Backend-Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com)
[![Groq AI](https://img.shields.io/badge/AI_Engine-Groq_Cloud-F55036?style=for-the-badge)](https://groq.com)
[![TensorFlow Lite](https://img.shields.io/badge/On--Device_ML-TFLite-FF6F00?style=for-the-badge&logo=tensorflow&logoColor=white)](https://www.tensorflow.org/lite)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey?style=for-the-badge)]()

</div>

---

## 📑 Daftar Isi

- [📌 Tentang BENTARA](#-tentang-bentara)
- [✨ Fitur-Fitur Utama](#-fitur-fitur-utama)
- [🏗️ Arsitektur Sistem & Alur Data](#️-arsitektur-sistem--alur-data)
- [🤖 Pipeline Machine Learning & Computer Vision](#-pipeline-machine-learning--computer-vision)
- [🛠️ Tech Stack & Dependensi](#️-tech-stack--dependensi)
- [📂 Struktur Direktori Proyek](#-struktur-direktori-proyek)
- [🚀 Panduan Instalasi & Menjalankan Aplikasi](#-panduan-instalasi--menjalankan-aplikasi)
- [⚙️ Konfigurasi Environment (`.env`)](#️-konfigurasi-environment-env)
- [🧪 Pengujian & Validasi](#-pengujian--validasi)
- [📱 Panduan Skenario Demo (Demo Runbook)](#-panduan-skenario-demo-demo-runbook)
- [🎨 Prinsip Desain & Aksesibilitas](#-prinsip-desain--aksesibilitas)
- [🗺️ Roadmap Pengembangan](#️-roadmap-pengembangan)
- [👥 Kontributor & Lisensi](#-kontributor--lisensi)

---

## 📌 Tentang BENTARA

**BENTARA** adalah aplikasi mobile inklusif yang dirancang untuk meruntuhkan batas komunikasi antara **Teman Tuli** (disabilitas rungu-wicara) dan **Teman Dengar** (masyarakat umum, tenaga medis, petugas pelayanan publik).

Seringkali, komunikasi sehari-hari mengalami hambatan karena:
1. Keterbatasan pemahaman bahasa isyarat di kalangan masyarakat umum.
2. Kalimat singkat atau kaku saat Teman Tuli mengetik pesan yang sering disalahartikan.
3. Ketiadaan akses darurat yang ramah bagi penyandang disabilitas saat membutuhkan pertolongan medis/polisi dengan cepat.

**BENTARA** hadir sebagai solusi komprehensif melalui integrasi:
- **Speech-to-Text (STT) & Text-to-Speech (TTS)** dua arah secara *real-time*.
- **AI Context Translation** (Groq LLM) yang mengubah teks kaku menjadi kalimat santun dan kontekstual (Rumah Sakit, Pelayanan Publik, Umum).
- **Penerjemah Bahasa Isyarat BISINDO** berbasis *On-Device Computer Vision* (MediaPipe Hand Landmark + LSTM TFLite).
- **Tombol Darurat (SOS Emergency)** dengan siaran audio otomatis dan alarm visual.

---

## ✨ Fitur-Fitur Utama

### 1. 💬 Komunikasi Langsung Dua Arah (Two-Way Live Communication)
- **Mode Teman Dengar**: Menangkap ucapan suara melalui mikrofon dan menampilkannya sebagai teks secara instan (*Real-time Speech-to-Text*).
- **Mode Teman Tuli**: Mengetik balasan teks yang kemudian dapat disuarakan ke Teman Dengar menggunakan *Text-to-Speech* alami.
- **Dukungan Audio On-Device**: Dapat beroperasi tanpa jeda (*low latency*).

### 2. 🧠 AI Context Translation (Penerjemahan Konteks Otomatis)
- **Transformasi Bahasa Kaku ke Formal**: Mengubah pesan singkat/kaku seperti *"obat pusing mana"* menjadi kalimat sopan sesuai konteks: *"Maaf Dokter, di mana saya bisa mendapatkan obat untuk sakit kepala saya?"*.
- **Pilihan Preset Konteks**:
  - 🏥 **Rumah Sakit (Medis)**: Menyesuaikan tata bahasa medis dan kata sapaan tenaga kesehatan (Dokter/Suster).
  - 🏛️ **Layanan Publik**: Disesuaikan untuk keperluan administrasi kantor pemerintah (KTP, SIM, pengaduan).
  - 🚨 **Darurat**: Kalimat darurat berprioritas tinggi.
  - 🌐 **Umum**: Percakapan sehari-hari yang santun.
- **Groq LLM Engine (`qwen/qwen3.8-27b`)**: Inferensi cloud secepat kilat (~300-500ms) dengan sistem filter pembersihan output.
- **Fail-Safe Offline Engine**: Memiliki kamus kontekstual *rule-based* otomatis jika perangkat tidak memiliki koneksi internet.

### 3. 🖐️ Penerjemah Isyarat BISINDO Real-Time (Computer Vision)
- **Deteksi Dua Tangan (Dual-Hand Detection)**: Memanfaatkan kamera depan/belakang untuk mendeteksi gestur tangan secara simultan.
- **Model LSTM 2-Tangan**: Mengekstrak 21 titik koordinat landmark per tangan (total 126 fitur per frame) dengan *sliding buffer* 30 frame.
- **Kamus Kosakata BISINDO**:
  - `halo`, `nama`, `kamu`, `siapa`, `terimakasih`, `makan`, `tidur`, `buku`, `telepon`, `menulis`, `jam`, `pusing`, `pintar`, `jalan`, `saya`.
- **Fitur Penyusun Kalimat (Composed Sentence Builder)**: Menyusun kata demi kata yang terdeteksi menjadi kalimat utuh, yang dapat langsung **diucapkan (TTS)** atau **dikirim ke ruang obrolan**.

### 4. ⚡ Komunikasi Cepat (Quick Phrases)
- Kumpulan frasa siap pakai untuk situasi penting dan mendesak.
- Fitur pencarian instan (*live search*), filter kategori (Umum, Medis, Publik), penanda favorit (*star bookmark*), tombol salin cepat, dan tombol suara instan.

### 5. 🚨 Mode Darurat (Emergency SOS)
- **Aktivasi 1-Ketuk**: Menampilkan alarm visual berkedip dan menyiarkan audio darurat berulang (*looping voice broadcast*).
- **Kategori Darurat Cepat**:
  - *"SAYA BUTUH AMBULANS SEKARANG!"*
  - *"TOLONG HUBUNGI POLISI!"*
  - *"BAWA KE RUMAH SAKIT!"*
  - *"SAYA TERLUKA!"*
  - *"SAYA BUTUH BANTUAN!"*
- Penghentian aman dengan dialog konfirmasi agar tidak sengaja tertekan.

### 6. 📜 Riwayat Percakapan (Conversation History)
- Menyimpan seluruh transkrip sesi percakapan lengkap dengan tanggal dan kategori konteks.
- Mendukung fitur *resume* percakapan serta gestur *swipe-to-delete*.

### 7. 👤 Profil Pengguna & Preferensi Peran
- Mengelola identitas pengguna, foto profil (kamera/galeri/URL), dan pemilihan peran (**Teman Tuli** atau **Teman Dengar**).
- Menampilkan metrik statistik penggunaan (Total Sesi, Pesan Dikirim, Bahasa).

### 8. ⚙️ Pengaturan Aksesibilitas Komprehensif
- **Mode Kontras Tinggi**: Meningkatkan ketegasan kontras teks dan latar belakang.
- **Pengatur Ukuran Teks (Text Scaling)**: Memperbesar/memperkecil font sesuai kenyamanan mata.
- **Pengatur Kecepatan (Speed) & Nada (Pitch) TTS**: Menyesuaikan artikulasi suara.
- **Haptic Feedback (Getaran)** & Fitur Bersihkan Cache Lokal.

---

## 🏗️ Arsitektur Sistem & Alur Data

BENTARA dibangun dengan arsitektur modular yang memisahkan tanggung jawab (Clean Architecture + Riverpod State Management):

```mermaid
graph TD
    subgraph UI_Layer["🎨 Presentation Layer (UI & Widgets)"]
        UI_Home[HomeScreen]
        UI_Comm[CommunicationScreen]
        UI_Sign[SignRecognitionScreen]
        UI_Quick[QuickCommunicationScreen]
        UI_Emerg[EmergencyScreen]
        UI_Hist[HistoryScreen]
        UI_Prof[ProfileScreen / SettingsScreen]
    end

    subgraph State_Layer["⚡ State Management (Flutter Riverpod)"]
        Prov_Auth[AuthNotifier]
        Prov_Comm[CommunicationNotifier]
        Prov_Sign[SignRecognitionNotifier]
        Prov_Quick[QuickCommNotifier]
        Prov_Emerg[EmergencyNotifier]
        Prov_Hist[HistoryNotifier]
        Prov_Set[SettingsNotifier]
    end

    subgraph Service_Layer["⚙️ Domain & Services Layer"]
        Svc_STT[STT Service (Speech-to-Text)]
        Svc_TTS[TTS Service (Text-to-Speech)]
        Svc_AI[Context Translation Service]
        Svc_CV[Hand Landmark & Gesture Classifier]
        Svc_Local[Hive Local Storage Service]
        Svc_Supabase[Supabase Service]
    end

    subgraph Core_Backend["🌐 Backend, ML & Cloud Engines"]
        Groq_API["Groq Cloud API (Qwen 3.8-27B)"]
        TFLite_Model["TensorFlow Lite (LSTM BISINDO Model)"]
        MediaPipe["MediaPipe Hand Landmarker"]
        Supabase_Cloud["Supabase BaaS (Auth, DB, Realtime)"]
        Hive_DB["Local Hive Storage (.hive)"]
    end

    UI_Comm --> Prov_Comm
    UI_Sign --> Prov_Sign
    UI_Quick --> Prov_Quick
    UI_Emerg --> Prov_Emerg
    UI_Hist --> Prov_Hist
    UI_Home --> Prov_Auth
    UI_Prof --> Prov_Set

    Prov_Comm --> Svc_STT
    Prov_Comm --> Svc_TTS
    Prov_Comm --> Svc_AI
    Prov_Sign --> Svc_CV
    Prov_Sign --> Svc_TTS
    Prov_Quick --> Svc_TTS
    Prov_Emerg --> Svc_TTS
    Prov_Hist --> Svc_Supabase
    Prov_Set --> Svc_Local

    Svc_AI --> Groq_API
    Svc_CV --> MediaPipe
    Svc_CV --> TFLite_Model
    Svc_Supabase --> Supabase_Cloud
    Svc_Local --> Hive_DB
```

---

## 🤖 Pipeline Machine Learning & Computer Vision

Pipeline pengenalan Bahasa Isyarat BISINDO di BENTARA dirancang dengan performa tinggi untuk berjalan lancar pada perangkat *mobile* (*On-Device Inference*):

```
┌─────────────────┐     ┌────────────────────────┐     ┌─────────────────────────────┐
│  Camera Stream  │ ──► │ MediaPipe Hand Detector│ ──► │  Hand Landmark Extractor    │
│ (Live 30+ FPS)  │     │  (Left & Right Hands)  │     │ (21 Points x 3 Coords x 2)  │
└─────────────────┘     └────────────────────────┘     └──────────────┬──────────────┘
                                                                      │ (126 raw features)
                                                                      ▼
┌─────────────────┐     ┌────────────────────────┐     ┌─────────────────────────────┐
│ Output Kalimat  │ ◄── │  Classification &      │ ◄── │   Normalization Engine      │
│  TTS / Chat     │     │  Confidence Smoothing  │     │ (Wrist-relative & Scaling)  │
└─────────────────┘     │    (Threshold ≥ 70%)   │     └──────────────┬──────────────┘
                        └───────────▲────────────┘                    │ (126 normalized)
                                    │                                 ▼
                        ┌───────────┴────────────┐     ┌─────────────────────────────┐
                        │   TFLite LSTM Model    │ ◄── │   Sliding Window Buffer     │
                        │ (bisindo_model.tflite) │     │    (30 Consecutive Frames)  │
                        └────────────────────────┘     └─────────────────────────────┘
```

1. **Camera Stream**: Mengambil frame video secara *real-time* menggunakan paket `camera`.
2. **MediaPipe Landmark Detection**: Mengekstrak 21 titik pergelangan dan ruas jari (x, y, z) untuk tangan kiri dan kanan.
3. **Normalisasi**: Titik koordinat dinormalisasi relatif terhadap pergelangan tangan (*wrist-relative*) dan diskalakan dengan jarak maksimum ruas jari untuk memastikan invarian terhadap jarak pengguna ke kamera.
4. **Sliding Window Buffer**: Mengumpulkan sequence 30 frame berturut-turut berbentuk matriks `[1, 30, 126]`.
5. **LSTM Inference**: Model TFLite memprediksi probabilitas gestur secara *real-time*.
6. **Confidence & Stability Smoothing**: Mengharuskan minimal 2 frame berturut-turut memiliki confidence $\ge 70\%$ sebelum kata diakui (*debouncing*), mencegah salah deteksi karena kedipan atau gerakan transisi.

---

## 🛠️ Tech Stack & Dependensi

| Kategori | Teknologi / Library | Versi | Deskripsi Kegunaan |
| :--- | :--- | :--- | :--- |
| **Framework** | [Flutter](https://flutter.dev) | `SDK >= 3.3.0` | Framework lintas platform UI |
| **Language** | [Dart](https://dart.dev) | `SDK >= 3.3.0` | Bahasa pemrograman utama |
| **State Management** | `flutter_riverpod` | `^2.5.1` | Manajemen state reaktif & Dependency Injection |
| **Navigation** | `go_router` | `^14.2.0` | Routing deklaratif dengan dukungan deep link & guards |
| **Backend as a Service** | `supabase_flutter` | `^2.5.6` | Cloud Authentication, PostgreSQL Database, Realtime |
| **Local Storage** | `hive_flutter` | `^1.1.0` | Penyimpanan lokal NoSQL super cepat untuk mode offline |
| **Cloud AI Engine** | Groq Cloud API | `v1` | LLM Context Translation (`qwen/qwen3.8-27b`) |
| **On-Device ML** | `tflite_flutter` | `^0.12.1` | Menjalankan model LSTM BISINDO langsung di perangkat |
| **Camera & Vision** | `camera` | `^0.10.5` | Mengakses stream kamera perangkat |
| **Image Processing** | `image` & `image_picker` | `^4.9.2` / `^1.1.2` | Manipulasi gambar, kompresi, dan pemilihan avatar |
| **Speech Processing** | `speech_to_text` | `^7.4.0` | Pengenalan suara (STT) real-time |
| **Voice Synthesis** | `flutter_tts` | `^4.0.2` | Sintesis suara (TTS) multi-pitch dan speed |
| **Permissions** | `permission_handler` | `^11.3.1` | Manajemen izin runtime (Kamera, Mic, Audio) |
| **Config & Security** | `flutter_dotenv` | `^5.1.0` | Memuat API Key dan secrets dari `.env` |
| **Graphics** | `flutter_svg` | `^2.0.10+1` | Rendering grafis vektor SVG |

---

## 📂 Struktur Direktori Proyek

```
bentara/
├── android/                   # Konfigurasi platform native Android
├── assets/                    # Aset statis aplikasi
│   ├── button/                # Grafis tombol interaktif
│   ├── images/                # Ilustrasi dan artwork
│   ├── logos/                 # Logo resmi BENTARA
│   └── models/                # Model Machine Learning & Vocabulary
│       ├── bisindo_model.tflite   # Model klasifikasi LSTM BISINDO
│       ├── hand_landmarker.task   # Model MediaPipe Hand Landmarks
│       └── label_map.json         # Pemetaan label gestur (15 kata)
├── ios/                       # Konfigurasi platform native iOS
├── lib/
│   ├── core/                  # Utilitas inti, konfigurasi & tema
│   │   ├── constants/         # Konstanta aplikasi & kunci env
│   │   ├── errors/            # Error handling & exception classes
│   │   ├── router/            # Definisi rute GoRouter (AppRouter)
│   │   ├── services/          # Layanan Supabase & Hive storage
│   │   ├── theme/             # Palet warna, tipografi, radius & spacing
│   │   └── utils/             # Helper format tanggal, string, sanitasi
│   ├── features/              # Modul fitur berbasis Clean Architecture
│   │   ├── auth/              # Login, Register, Forgot Password & Demo Mode
│   │   ├── communication/     # Komunikasi Langsung Dua Arah & AI Translation
│   │   ├── emergency/         # Mode Darurat SOS & Audio Loop Broadcast
│   │   ├── history/           # Riwayat percakapan & manajemen sesi
│   │   ├── home/              # Halaman Dashboard Utama
│   │   ├── onboarding/        # Panduan perkenalan pengguna baru
│   │   ├── profile/           # Profil pengguna, peran & statistik
│   │   ├── quick_communication/ # Kumpulan frasa siap pakai & filter
│   │   ├── settings/          # Pengaturan aksesibilitas, TTS & cache
│   │   ├── sign_recognition/  # Deteksi Bahasa Isyarat BISINDO via Kamera
│   │   └── splash/            # Layar pembuka & inisialisasi aplikasi
│   ├── shared/                # Komponen UI bersama (Buttons, Cards, Modals)
│   │   └── widgets/
│   └── main.dart              # Entry point utama aplikasi Flutter
├── test/                      # Unit testing & model inspection tests
├── .env                       # File konfigurasi environment (Private)
├── .env.example               # Template contoh variabel environment
├── pubspec.yaml               # Deklarasi paket dependensi Flutter
└── README.md                  # Dokumentasi lengkap proyek
```

---

## 🚀 Panduan Instalasi & Menjalankan Aplikasi

### 1. Prasyarat Sistem
- **Flutter SDK**: Versi `3.3.0` atau yang lebih baru ([Panduan Instalasi Flutter](https://docs.flutter.dev/get-started/install)).
- **Dart SDK**: Versi `3.3.0` ke atas (otomatis terpasang bersama Flutter).
- **Android Studio** atau **VS Code** dengan ekstensi Flutter & Dart.
- **Java Development Kit (JDK)**: OpenJDK 17+.
- **Perangkat Fisik (Disarankan)**: Smartphone Android dengan kamera dan mikrofon aktif untuk menguji fitur kamera BISINDO dan pengenalan suara (STT).

### 2. Kloning Repositori
```bash
git clone https://github.com/your-username/bentara.git
cd bentara
```

### 3. Pasang Dependensi
```bash
flutter pub get
```

### 4. Konfigurasi File Environment (`.env`)
Salin template `.env.example` menjadi `.env` pada direktori root proyek:
```bash
cp .env.example .env
```
Buka file `.env` dan lengkapi credential Anda:
```env
SUPABASE_URL=https://your-supabase-project.supabase.co
SUPABASE_ANON_KEY=your-supabase-anon-key
GROQ_API_KEY=your-groq-api-key
```

### 5. Menjalankan Aplikasi
Hubungkan perangkat Android Anda melalui USB Debugging atau jalankan emulator:
```bash
# Menjalankan pada perangkat yang terhubung
flutter run

# Menjalankan dalam mode rilis (performa optimal kamera & ML)
flutter run --release
```

---

## ⚙️ Konfigurasi Environment (`.env`)

| Variabel | Deskripsi | Diperlukan? | Cara Mendapatkan |
| :--- | :--- | :---: | :--- |
| `SUPABASE_URL` | URL Endpoint proyek Supabase Anda | Ya | Buat proyek gratis di [supabase.com](https://supabase.com) -> *Project Settings* -> *API*. |
| `SUPABASE_ANON_KEY` | Public Anon API Key Supabase | Ya | Tersedia di dashboard Supabase bagian *API Keys*. |
| `GROQ_API_KEY` | API Key Groq Cloud untuk inferensi LLM | Ya | Dapatkan API Key di [console.groq.com](https://console.groq.com). |

> 💡 **Catatan**: Jika API Key tidak diisi atau koneksi internet tidak tersedia, aplikasi secara otomatis mengaktifkan **Fallback Mode** sehingga fitur STT, TTS, dan Terjemahan Konteks tetap dapat digunakan secara *offline*.

---

## 🧪 Pengujian & Validasi

BENTARA dilengkapi dengan pengujian unit untuk memverifikasi fungsionalitas model, arsitektur data, dan logika bisnis:

```bash
# Menjalankan seluruh unit test
flutter test

# Menjalankan pengujian inspeksi model TFLite
flutter test test/inspect_model_test.dart
```

---

## 📱 Panduan Skenario Demo (Demo Runbook)

Untuk presentasi atau pengujian langsung di hadapan dewan juri / audiens:

### Skenario A: Komunikasi Langsung Dua Arah (STT ➔ TTS)
1. Buka menu **"Komunikasi Langsung"**.
2. **Teman Dengar**: Tekan tombol **Mikrofon**, lalu bicaralah:  
   *"Halo, nama saya Budi. Saya dokter spesialis THT."*
3. Teks suara akan otomatis muncul di layar Teman Tuli secara *real-time*.
4. **Teman Tuli**: Balas dengan mengetik:  
   *"Halo dokter, telinga kanan saya sakit sejak kemarin."* lalu klik tombol **Kirim / Ucapkan**.
5. Suara TTS akan otomatis membacakan teks tersebut agar dapat didengar oleh Teman Dengar.

### Skenario B: Penerjemahan Konteks AI (AI Context Translation)
1. Di halaman Komunikasi Langsung, aktifkan ikon **Bintang / Magic Wand** di kanan atas.
2. Pilih tab kategori **"Rumah Sakit"**.
3. Ketikkan teks pendek/kaku: *"obat pusing mana"* lalu tekan kirim.
4. AI Context Engine akan mengubah teks secara otomatis menjadi kalimat baku dan sopan:  
   *"Maaf Dokter, di mana saya bisa mendapatkan obat untuk sakit kepala saya?"*.

### Skenario C: Deteksi Bahasa Isyarat BISINDO
1. Dari Beranda atau menu chat, buka **"Penerjemah Isyarat"**.
2. Arahkan kamera ke tangan Anda dan peragakan isyarat (misal: *halo*, *nama*, *saya*).
3. AI memindai landmark tangan dan menampilkan kata serta confidence score ($\ge 70\%$).
4. Klik tombol **"Suara"** untuk membunyikan kalimat hasil deteksi, atau **"Kirim ke Chat"** untuk memindahkannya ke ruang obrolan.

### Skenario D: Tombol Darurat (SOS Emergency)
1. Tekan tombol besar **"MODE DARURAT"** di halaman utama.
2. Pilih jenis darurat: *"SAYA BUTUH AMBULANS SEKARANG!"*.
3. Layar akan berkedip merah terang dan suara sirine / audio darurat akan berulang kali disiarkan melalui pengeras suara HP hingga tombol **"Hentikan Siaran"** ditekan.

---

## 🎨 Prinsip Desain & Aksesibilitas

Aplikasi BENTARA dirancang dengan mematuhi pedoman **Web Content Accessibility Guidelines (WCAG 2.1 AA)**:
- 👁️ **Visual Clarity**: Hierarki warna biru-putih tegas (*Clean Solid Layering*), tanpa efek buram atau teks transparan yang sulit dibaca.
- 🎯 **Target Sentuh Ergonomis**: Seluruh tombol interaktif memiliki target sentuh minimal **$48 \times 48\text{ px}$** untuk kenyamanan akses motorik.
- 🔊 **Feedback Multimodal**: Kombinasi konfirmasi visual, getaran (*haptic*), dan suara (*audio feedback*) di setiap aksi penting.
- 🌗 **High Contrast & Font Scaling**: Dukungan pembesaran font hingga 150% dan mode kontras tinggi bawaan di menu Pengaturan.

---

## 🗺️ Roadmap Pengembangan

- [x] **Fase 1**: Arsitektur inti, STT, TTS, dan integrasi Supabase Auth.
- [x] **Fase 2**: Model klasifikasi gestur BISINDO on-device berbasis TFLite LSTM.
- [x] **Fase 3**: AI Context Translation menggunakan Groq LLM API dan Fallback Dictionary.
- [x] **Fase 4**: Fitur Tombol Darurat SOS, Komunikasi Cepat, dan Modul Aksesibilitas.
- [ ] **Fase 5 (Mendatang)**:
  - Ekspansi kosakata BISINDO ke 100+ kosakata dan pengenalan ekspresi wajah (*Facial Expression Tracking*).
  - Integrasi koordinat GPS otomatis saat Mode Darurat SOS diaktifkan.
  - Integrasi ke *Wearable Device* (Smartwatch) untuk notifikasi getar real-time.

---

## 👥 Kontributor & Lisensi

Dikembangkan dengan dedikasi penuh untuk inklusivitas disabilitas Indonesia oleh Tim BENTARA (KMIPN 2026).

Proyek ini dilisensikan di bawah **MIT License** — Anda bebas menggunakan, memodifikasi, dan mendistribusikan kode ini untuk kepentingan edukasi dan sosial.

<div align="center">
  <sub>Dibuat dengan ❤️ untuk Indonesia yang lebih inklusif dan ramah disabilitas.</sub>
</div>

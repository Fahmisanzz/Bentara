import 'package:flutter_test/flutter_test.dart';
import 'package:bentara/features/sign_recognition/models/sign_vocabulary.dart';

void main() {
  group('SignVocabulary Tests', () {
    test('Resolves exact labels from labels.txt properly', () {
      expect(SignVocabulary.lookup('0 idle'), isNull);
      expect(SignVocabulary.lookup('1 0_halo_apa_kabar'), 'Halo, apa kabar?');
      expect(SignVocabulary.lookup('2 1_nama'), 'Perkenalkan, nama saya Haikal');
      expect(SignVocabulary.lookup('3 2_tolong'), 'Tolong');
      expect(SignVocabulary.lookup('4 3_pusing'), 'Pusing');
      expect(SignVocabulary.lookup('5 4_terimakasih'), 'Terima kasih');
      expect(SignVocabulary.lookup('6 5_nama_kamu_siapa'), 'Nama kamu siapa?');
      expect(SignVocabulary.lookup('7 6_salam_kenal'), 'Salam kenal');
    });

    test('Resolves stripped labels with number prefix', () {
      expect(SignVocabulary.lookup('0_halo_apa_kabar'), 'Halo, apa kabar?');
      expect(SignVocabulary.lookup('1_nama'), 'Perkenalkan, nama saya Haikal');
      expect(SignVocabulary.lookup('2_tolong'), 'Tolong');
      expect(SignVocabulary.lookup('3_pusing'), 'Pusing');
      expect(SignVocabulary.lookup('4_terimakasih'), 'Terima kasih');
      expect(SignVocabulary.lookup('5_nama_kamu_siapa'), 'Nama kamu siapa?');
      expect(SignVocabulary.lookup('6_salam_kenal'), 'Salam kenal');
    });

    test('Resolves standard and lowercase keys', () {
      expect(SignVocabulary.lookup('Halo'), 'Halo, apa kabar?');
      expect(SignVocabulary.lookup('halo'), 'Halo, apa kabar?');
      expect(SignVocabulary.lookup('tolong'), 'Tolong');
      expect(SignVocabulary.lookup('pusing'), 'Pusing');
      expect(SignVocabulary.lookup('terima kasih'), 'Terima kasih');
      expect(SignVocabulary.lookup('nama kamu siapa'), 'Nama kamu siapa?');
      expect(SignVocabulary.lookup('salam kenal'), 'Salam kenal');
    });

    test('Returns display names properly', () {
      expect(SignVocabulary.getDisplayName('0_halo_apa_kabar'), 'Halo Apa Kabar');
      expect(SignVocabulary.getDisplayName('1_nama'), 'Nama');
      expect(SignVocabulary.getDisplayName('2 2_tolong'), 'Tolong');
      expect(SignVocabulary.getDisplayName('3_pusing'), 'Pusing');
      expect(SignVocabulary.getDisplayName('6 5_nama_kamu_siapa'), 'Nama Kamu Siapa');
      expect(SignVocabulary.getDisplayName('7 6_salam_kenal'), 'Salam Kenal');
    });

    test('Returns null for unknown gesture or background', () {
      expect(SignVocabulary.lookup('background'), isNull);
      expect(SignVocabulary.lookup('idle'), isNull);
      expect(SignVocabulary.lookup('0 idle'), isNull);
      expect(SignVocabulary.lookup('8_idle'), isNull);
      expect(SignVocabulary.lookup('unknown_gesture'), isNull);
    });
  });
}

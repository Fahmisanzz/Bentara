import 'package:flutter_test/flutter_test.dart';
import 'package:bentara/features/sign_recognition/models/sign_vocabulary.dart';

void main() {
  group('SignVocabulary 15-Word Tests', () {
    test('Resolves all 15 active words properly', () {
      // 5 Original words:
      expect(SignVocabulary.lookup('halo'), 'Halo');
      expect(SignVocabulary.lookup('nama'), 'Nama');
      expect(SignVocabulary.lookup('kamu'), 'Kamu');
      expect(SignVocabulary.lookup('siapa'), 'Siapa');
      expect(SignVocabulary.lookup('terimakasih'), 'Terima kasih');

      // 10 New words:
      expect(SignVocabulary.lookup('makan'), 'Makan');
      expect(SignVocabulary.lookup('tidur'), 'Tidur');
      expect(SignVocabulary.lookup('buku'), 'Buku');
      expect(SignVocabulary.lookup('telepon'), 'Telepon');
      expect(SignVocabulary.lookup('menulis'), 'Menulis');
      expect(SignVocabulary.lookup('jam'), 'Jam');
      expect(SignVocabulary.lookup('pusing'), 'Pusing');
      expect(SignVocabulary.lookup('pintar'), 'Pintar');
      expect(SignVocabulary.lookup('jalan'), 'Jalan');
      expect(SignVocabulary.lookup('saya'), 'Saya');
    });

    test('Resolves prefixed labels from index mapping', () {
      expect(SignVocabulary.lookup('0 halo'), 'Halo');
      expect(SignVocabulary.lookup('1 nama'), 'Nama');
      expect(SignVocabulary.lookup('2 kamu'), 'Kamu');
      expect(SignVocabulary.lookup('3 siapa'), 'Siapa');
      expect(SignVocabulary.lookup('4 terimakasih'), 'Terima kasih');
      expect(SignVocabulary.lookup('5 makan'), 'Makan');
      expect(SignVocabulary.lookup('6 tidur'), 'Tidur');
      expect(SignVocabulary.lookup('7 buku'), 'Buku');
      expect(SignVocabulary.lookup('8 telepon'), 'Telepon');
      expect(SignVocabulary.lookup('9 menulis'), 'Menulis');
      expect(SignVocabulary.lookup('10 jam'), 'Jam');
      expect(SignVocabulary.lookup('11 pusing'), 'Pusing');
      expect(SignVocabulary.lookup('12 pintar'), 'Pintar');
      expect(SignVocabulary.lookup('13 jalan'), 'Jalan');
      expect(SignVocabulary.lookup('14 saya'), 'Saya');
    });

    test('Resolves standard, uppercase, and variant gesture keys', () {
      expect(SignVocabulary.lookup('Halo'), 'Halo');
      expect(SignVocabulary.lookup('Nama'), 'Nama');
      expect(SignVocabulary.lookup('Kamu'), 'Kamu');
      expect(SignVocabulary.lookup('Siapa'), 'Siapa');
      expect(SignVocabulary.lookup('Terima kasih'), 'Terima kasih');
      expect(SignVocabulary.lookup('terima kasih'), 'Terima kasih');
      expect(SignVocabulary.lookup('Terimakasih'), 'Terima kasih');
      expect(SignVocabulary.lookup('Makan'), 'Makan');
      expect(SignVocabulary.lookup('Tidur'), 'Tidur');
      expect(SignVocabulary.lookup('Buku'), 'Buku');
      expect(SignVocabulary.lookup('Telepon'), 'Telepon');
      expect(SignVocabulary.lookup('Menulis'), 'Menulis');
      expect(SignVocabulary.lookup('Jam'), 'Jam');
      expect(SignVocabulary.lookup('Pusing'), 'Pusing');
      expect(SignVocabulary.lookup('Pintar'), 'Pintar');
      expect(SignVocabulary.lookup('Jalan'), 'Jalan');
      expect(SignVocabulary.lookup('Saya'), 'Saya');
    });

    test('Returns display names properly', () {
      expect(SignVocabulary.getDisplayName('halo'), 'Halo');
      expect(SignVocabulary.getDisplayName('nama'), 'Nama');
      expect(SignVocabulary.getDisplayName('kamu'), 'Kamu');
      expect(SignVocabulary.getDisplayName('siapa'), 'Siapa');
      expect(SignVocabulary.getDisplayName('terimakasih'), 'Terima Kasih');
      expect(SignVocabulary.getDisplayName('0 halo'), 'Halo');
      expect(SignVocabulary.getDisplayName('makan'), 'Makan');
      expect(SignVocabulary.getDisplayName('tidur'), 'Tidur');
      expect(SignVocabulary.getDisplayName('buku'), 'Buku');
      expect(SignVocabulary.getDisplayName('telepon'), 'Telepon');
      expect(SignVocabulary.getDisplayName('menulis'), 'Menulis');
      expect(SignVocabulary.getDisplayName('jam'), 'Jam');
      expect(SignVocabulary.getDisplayName('pusing'), 'Pusing');
      expect(SignVocabulary.getDisplayName('pintar'), 'Pintar');
      expect(SignVocabulary.getDisplayName('jalan'), 'Jalan');
      expect(SignVocabulary.getDisplayName('saya'), 'Saya');
    });

    test('Returns null for unknown gesture or removed words', () {
      expect(SignVocabulary.lookup('background'), isNull);
      expect(SignVocabulary.lookup('idle'), isNull);
      expect(SignVocabulary.lookup('0 idle'), isNull);
      expect(SignVocabulary.lookup('tolong'), isNull);
      expect(SignVocabulary.lookup('kabar'), isNull);
      expect(SignVocabulary.lookup('unknown_word'), isNull);
    });
  });
}

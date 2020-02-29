import 'package:liberum/crypto/password.dart';
import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/export.dart'
show FortunaRandom, KeyParameter, ParametersWithRandom, RSAKeyGenerator, RSAKeyGeneratorParameters;

class Key {
  Key.fromPublicKey(String publicKey) {
    this._init(publicKey);
  }

  Key.fromKeys(String publicKey, String privateKey) {
    this._init(publicKey, privateKey: privateKey);
  }

  Key.fromStorage(String databaseKey) {
    final publicKey = "should be read from SQLite"; // TODO
    this._init(publicKey);
  }

  Key.fromSecureStorage(String databaseKey, String password) {
    final publicKey = "should be read from SQLite"; // TODO
    final privateKey = "should be read from secure storage";
    final truePassword = "should be read from secure storage";
    if (password != truePassword) {
      throw BadPasswordException();
    }
    this._init(publicKey, privateKey: privateKey);
  }

  /// Securely generate a two-way key.
  /// Takes several seconds, call asynchronously!
  Key.generate() {
    final seedSource = Random.secure();
    final seeds = List<int>.generate(32, (_) => seedSource.nextInt(256));
    final secureRandom = FortunaRandom();
    secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));

    final keyGen = RSAKeyGenerator();
    keyGen.init(
      ParametersWithRandom(
        RSAKeyGeneratorParameters(BigInt.parse('65537'), 4096, 64),
        secureRandom
      )
    );
    final keyPair = keyGen.generateKeyPair();
    this._publicKey = keyPair.publicKey;
    this._privateKey = keyPair.privateKey;
  }

  String sign(String plainText) => Signer(
    RSASigner(
      RSASignDigest.SHA256,
      publicKey: this._publicKey,
      privateKey: this._privateKey
    )
  ).sign(plainText).base16;

  bool verify(String plainText, String signature) => Signer(
    RSASigner(
      RSASignDigest.SHA256,
      publicKey: this._publicKey
    )
  ).verify16(plainText, signature);

  /// Short identifier for a public key.
  /// Can be safely displayed publicly.
  String get publicFingerprint {
    return _publicKey.hashCode.toRadixString(16).substring(0, 16);
  }

  // private
  RSAPublicKey _publicKey;
  RSAPrivateKey _privateKey;

  void _init(String publicKey, {String privateKey}) {
    final parser = RSAKeyParser();
    this._publicKey = parser.parse(publicKey);
    if (privateKey != null) {
      this._privateKey = parser.parse(privateKey);
    }
  }
}
import 'dart:convert';

import 'package:liberum/crypto/key.dart';
import 'package:liberum/network/account.dart';

class Network {
  Account loggedInAccount;
  List<Account> accounts = <Account>[];

  static List<Account> get loggableAccounts {
    return [
      Account.fromPublicData('Cave Johnson', Key.generate().publicKey),
      Account.fromPublicData('Julius Caesar', Key.generate().publicKey)
    ]; // TODO: load from local storage
  }

  Network(this.loggedInAccount) {
    // TODO: initialize the stuffsies
  }

  Network.fromJson(Map<String, dynamic> json) {
    this.loggedInAccount = Account.fromJson(json['loggedInAccount']);
     // json['accounts'] is a string which can be further decoded as a list of maps, each of which can be further decoded as an account
    this.accounts = jsonDecode(json['accounts']).map((accountJson) => Account.fromJson(accountJson));
    // TODO: serialize links, identifying accounts by their fingerprint
  }

  Map<String, dynamic> toJson() => {
    'loggedInAccount': this.loggedInAccount.toJson(),
    'accounts': jsonEncode(this.accounts)
  }; // TODO: deserialize links, identifying accounts by their fingerprint

  // used during synchronization
  Network.merge(Network a, Network b) {
    // TODO: merge networks
  }
}
import 'package:firebase_database/firebase_database.dart';

class BancoReal {
  final DatabaseReference _database;
  
  BancoReal({DatabaseReference? database}) 
    : _database = database ?? FirebaseDatabase.instance.ref();

  DatabaseReference get reference => _database;

  Future<void> atualizado(String caminho, Map<String, dynamic> dados) async {
    try {
      await _database.child(caminho).update(dados);
    } catch (e) {
      print("Erro ao atualizar $caminho: $e");
      throw Exception("Falha na atualização: ${e.toString()}");
    }
  }

  /// Obtém o valor atual de um nó específico
  Future<dynamic> obterValor(String caminho) async {
    try {
      final snapshot = await _database.child(caminho).get();
      return snapshot.value;
    } catch (e) {
      print("Erro ao ler $caminho: $e");
      throw Exception("Falha na leitura: ${e.toString()}");
    }
  }

  Stream<DatabaseEvent> ouvirMudancas(String caminho) {
    return _database.child(caminho).onValue;
  }

  Future<void> definirValor(String caminho, dynamic valor) async {
    try {
      await _database.child(caminho).set(valor);
    } catch (e) {
      print("Erro ao definir valor em $caminho: $e");
      throw Exception("Falha ao definir valor: ${e.toString()}");
    }
  }
}
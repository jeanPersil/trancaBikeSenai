import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tranca/services/banco.dart';
import 'package:tranca/services/notificacoes.dart';

class MyHomePage extends StatefulWidget {
  final String title;
  final NotificationService notificationService;

  const MyHomePage({
    super.key,
    required this.title,
    required this.notificationService,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final banco = BancoReal();
  int estadoFechadura = 0;
  int estadoAlerta = 0;

  Future<void> _requestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  @override
  void initState() {
    super.initState();
    _requestNotificationPermission();
    _setupFirebaseListeners();
  }

  void _setupFirebaseListeners() {
    banco.reference.child("tranca/fechadura").onValue.listen((event) {
      final newState = event.snapshot.value as int? ?? 0;
      if (newState != estadoFechadura) {
        setState(() {
          estadoFechadura = newState;
        });
      }
    });

    banco.reference.child("tranca/alerta").onValue.listen((event) {
      final newAlerta = event.snapshot.value as int? ?? 0;
      if (newAlerta != estadoAlerta) {
        setState(() {
          estadoAlerta = newAlerta;
        });

        if (newAlerta == 1) {
          widget.notificationService.showAlertaNotification();
        }
      }
    });
  }
 
  void alternarTranca() {
    final newState = estadoFechadura == 0 ? 1 : 0;
    setState(() {
      estadoFechadura = newState;
    });
    banco.atualizado("tranca/", {"fechadura": newState});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: estadoAlerta == 1 ? Colors.red : Colors.black,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  estadoFechadura == 0
                      ? Icons.lock_open_rounded
                      : Icons.lock_outline,
                  size: 100,
                  color: Colors.white,
                ),
                onPressed: alternarTranca,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Fechadura ${estadoFechadura == 0 ? 'Destrancada' : 'Trancada'}',
              style: const TextStyle(fontSize: 24),
            ),
            if (estadoAlerta == 1)
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(
                  'ALERTA: Movimento detectado!',
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.red,
                      fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

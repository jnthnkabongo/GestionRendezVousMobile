import 'package:flutter/material.dart';
import 'package:frontend/auth/login.dart';
import 'services/onesignal_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize OneSignal
  await OneSignalService.instance.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rendez-vous App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const Login(),
    );
  }
}

// class HomePage extends StatelessWidget {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Rendez-vous'),
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.calendar_today, size: 80, color: Colors.blue),
//             const SizedBox(height: 20),
//             const Text(
//               'Application de Rendez-vous',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             const Text(
//               'OneSignal est configuré',
//               style: TextStyle(fontSize: 16, color: Colors.grey),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

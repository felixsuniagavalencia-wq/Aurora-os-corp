import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(AuroraApp());

class AuroraApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aurora OS Corporation',
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  final tabs = [
    'Asistente',
    'Productividad',
    'Mini-CRM',
    'Finanzas',
    'Socio Silencioso'
  ];
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Aurora OS Corporation'),
          bottom: TabBar(
            isScrollable: true,
            tabs: [for (final t in tabs) Tab(text: t)],
          ),
        ),
        body: TabBarView(
          children: [
            Center(child: Text('Asistente multi-IA - Próximamente')),
            Center(child: Text('Productividad predictiva - Próximamente')),
            Center(child: Text('Mini-CRM automático - Próximamente')),
            Center(child: Text('Analizador financiero - Próximamente')),
            SilentPartnerTab(), // <-- único que funciona
          ],
        ),
      ),
    );
  }
}

class SilentPartnerTab extends StatefulWidget {
  @override
  _SilentPartnerTabState createState() => _SilentPartnerTabState();
}

class _SilentPartnerTabState extends State<SilentPartnerTab> {
  final controller = TextEditingController();
  String result = '';
  bool loading = false;

  Future<void> detect() async {
    setState(() => loading = true);
    final uri = Uri.parse('https://tu-dominio-railway.app/silent/detect');
    final res = await http.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: '{"channel":"web","text":"${controller.text}"}');
    setState(() {
      result = res.body;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
              controller: controller,
              decoration: InputDecoration(
                  labelText: 'Mensaje del lead',
                  hintText: 'Ej: Necesito 200 unidades...')),
          SizedBox(height: 12),
          ElevatedButton(onPressed: detect, child: Text('Detectar')),
          if (loading) CircularProgressIndicator(),
          if (result.isNotEmpty) Expanded(child: SelectableText(result))
        ],
      ),
    );
  }
}

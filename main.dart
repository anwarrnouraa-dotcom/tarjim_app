import 'package:flutter/material.dart';

void main() => runApp(TarjimApp());

class TarjimApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tarjim',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;
  int offlineMinutes = 5; // كيبدا بـ 5 دقائق فابور

  final Map<String, Map<String, String>> dictionary = {
    'مرحبا': {'fr': 'Bonjour', 'en': 'Hello'},
    'سلام': {'fr': 'Salut', 'en': 'Hi'},
    'شكرا': {'fr': 'Merci', 'en': 'Thank you'},
    'ماء': {'fr': 'Eau', 'en': 'Water'},
    'بيت': {'fr': 'Maison', 'en': 'House'},
    'كتاب': {'fr': 'Livre', 'en': 'Book'},
    'مدرسة': {'fr': 'École', 'en': 'School'},
    'حب': {'fr': 'Amour', 'en': 'Love'},
    'صديق': {'fr': 'Ami', 'en': 'Friend'},
    'وقت': {'fr': 'Temps', 'en': 'Time'},
    'bonjour': {'ar': 'مرحبا', 'en': 'Hello'},
    'merci': {'ar': 'شكرا', 'en': 'Thank you'},
    'hello': {'ar': 'مرحبا', 'fr': 'Bonjour'},
  };

  void addTime() {
    setState(() => offlineMinutes += 10);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('مبروك! +10 دقائق، المجموع: $offlineMinutes دقيقة')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tarjim - ترجم'),
        backgroundColor: Colors.green,
        actions: [
          Padding(
              padding: EdgeInsets.all(12),
              child: Chip(label: Text('$offlineMinutes د')))
        ],
      ),
      body: IndexedStack(
        index: currentIndex,
        children: [
          DictionaryPage(
              dictionary: dictionary, offlineMinutes: offlineMinutes),
          LevelsPage(),
          OfflinePage(onWatchAd: addTime, minutes: offlineMinutes),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => setState(() => currentIndex = i),
        selectedItemColor: Colors.green,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.translate), label: 'القاموس'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'المستويات'),
          BottomNavigationBarItem(icon: Icon(Icons.wifi_off), label: 'بلا نت'),
        ],
      ),
    );
  }
}

class DictionaryPage extends StatefulWidget {
  final Map<String, Map<String, String>> dictionary;
  final int offlineMinutes;
  DictionaryPage({required this.dictionary, required this.offlineMinutes});
  @override
  _DictionaryPageState createState() => _DictionaryPageState();
}

class _DictionaryPageState extends State<DictionaryPage> {
  TextEditingController ctrl = TextEditingController();
  String fr = '', en = '';
  void translate() {
    String key = ctrl.text.trim();
    var entry = widget.dictionary[key] ?? widget.dictionary[key.toLowerCase()];
    setState(() {
      fr = entry?['fr'] ?? 'غير موجود';
      en = entry?['en'] ?? 'Not found';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(16),
        child: Column(children: [
          TextField(
              controller: ctrl,
              onSubmitted: (v) => translate(),
              decoration: InputDecoration(
                  labelText: 'كتب كلمة: مرحبا، ماء، hello...',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                      icon: Icon(Icons.search), onPressed: translate))),
          SizedBox(height: 20),
          Card(
              child: ListTile(
                  title: Text('Français: $fr'),
                  leading: Text('🇫🇷', style: TextStyle(fontSize: 24)))),
          Card(
              child: ListTile(
                  title: Text('English: $en'),
                  leading: Text('🇬🇧', style: TextStyle(fontSize: 24)))),
          if (widget.offlineMinutes <= 0)
            Card(
                color: Colors.red.shade100,
                child: ListTile(
                    title: Text('انتهى وقت الأوفلاين!'),
                    subtitle: Text('سير لصفحة بلا نت وشاهد إعلان'))),
        ]));
  }
}

class LevelsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      Card(
          margin: EdgeInsets.all(12),
          color: Colors.green.shade100,
          child: ListTile(
              leading: Icon(Icons.child_care, size: 40, color: Colors.green),
              title: Text('مبتدئ جدا',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('20 كلمة بالصور - خدام دابا'),
              trailing: ElevatedButton(onPressed: () {}, child: Text('ابدأ')))),
      Card(
          margin: EdgeInsets.all(12),
          color: Colors.blue.shade100,
          child: ListTile(
              leading: Icon(Icons.chat, size: 40, color: Colors.blue),
              title:
                  Text('مبتدئ', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('50 جملة يومية'),
              trailing: Icon(Icons.lock))),
      Card(
          margin: EdgeInsets.all(12),
          color: Colors.orange.shade100,
          child: ListTile(
              leading: Icon(Icons.menu_book, size: 40, color: Colors.orange),
              title: Text('ذو خبرة قليلة',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('100 حوار ونص'),
              trailing: Icon(Icons.lock))),
    ]);
  }
}

class OfflinePage extends StatelessWidget {
  final Function onWatchAd;
  final int minutes;
  OfflinePage({required this.onWatchAd, required this.minutes});
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
            padding: EdgeInsets.all(24),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.card_giftcard, size: 100, color: Colors.amber),
              SizedBox(height: 20),
              Text('عندك حاليا: $minutes دقيقة بلا إنترنت',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              SizedBox(height: 20),
              Text('شاهد إعلان = 10 دقائق إضافية', textAlign: TextAlign.center),
              SizedBox(height: 20),
              ElevatedButton.icon(
                  icon: Icon(Icons.play_circle_fill),
                  label: Text('شاهد إعلان واربح 10 دقائق'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
                  onPressed: () => onWatchAd()),
            ])));
  }
}

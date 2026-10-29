import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MaterialApp(home: HomePage(), debugShowCheckedModeBanner: false));

// القاموس الكبير 30 الف - كيتحمل من assets
Map<String,String> bigDict = {};

// المستويات بحال Duolingo - 10 مستويات كل واحد 50 جملة
final Map<int, List<Map<String,String>>> levels = {
  1: [ // المستوى 1 - ساهل بزاف - التحيات
    {"q":"Hello","a":"مرحبا"}, {"q":"Hi","a":"أهلا"}, {"q":"Good morning","a":"صباح الخير"},
    {"q":"Thank you","a":"شكرا"}, {"q":"Please","a":"من فضلك"}, {"q":"Yes","a":"نعم"},
    {"q":"No","a":"لا"}, {"q":"What is your name?","a":"ما اسمك؟"}, {"q":"My name is Ali","a":"اسمي علي"},
    {"q":"I am fine","a":"أنا بخير"}, {"q":"How are you?","a":"كيف حالك؟"}, {"q":"I am a boy","a":"أنا ولد"},
    {"q":"She is a girl","a":"هي فتاة"}, {"q":"This is a book","a":"هذا كتاب"}, {"q":"It is big","a":"إنه كبير"},
    {"q":"It is small","a":"إنه صغير"}, {"q":"I have a car","a":"لدي سيارة"}, {"q":"We are friends","a":"نحن أصدقاء"},
    // زيد 32 وحدة أخرى باش نكملو 50
  ],
  // المستوى 2 كيصحاب شوية - العائلة
  // المستوى 10 غادي يكون صعيب بزاف - جمل طويلة
};

class HomePage extends StatefulWidget { @override _HomePageState createState() => _HomePageState(); }

class _HomePageState extends State<HomePage> {
  String result = "";
  TextEditingController ctrl = TextEditingController();
  
  @override
  void initState(){
    super.initState();
    loadDict();
    initLevels(); // كيعمر المستويات كلها 500 جملة
  }

  Future<void> loadDict() async {
    try{
      String data = await rootBundle.loadString('assets/dictionary.json');
      bigDict = Map<String,String>.from(jsonDecode(data));
    }catch(e){
      bigDict = {"hello":"مرحبا","book":"كتاب","water":"ماء"}; // إلا ما كاينش الملف
    }
    setState((){});
  }

  void initLevels(){
    // كيعمر 10 مستويات كل واحد 50 جملة - كيبدا ساهل وكيصحاب
    List<Map<String,String>> base = [
      {"q":"Hello","a":"مرحبا"}, {"q":"Good morning","a":"صباح الخير"}, {"q":"My father is kind","a":"أبي طيب"},
      {"q":"I go to school","a":"أذهب إلى المدرسة"}, {"q":"I eat bread","a":"آكل خبزا"}, {"q":"The cat is black","a":"القط أسود"},
      {"q":"I love my family","a":"أحب عائلتي"}, {"q":"Water is important","a":"الماء مهم"}, {"q":"The book is on the table","a":"الكتاب على الطاولة"},
      {"q":"She reads a book every day","a":"هي تقرأ كتابا كل يوم"}, {"q":"We will travel tomorrow","a":"سوف نسافر غدا"},
      {"q":"If I had time, I would learn more","a":"لو كان لدي وقت، لتعلمت أكثر"},
    ];
    
    for(int lvl=1; lvl<=10; lvl++){
      levels[lvl] = [];
      for(int i=0; i<50; i++){
        var item = base[(lvl*3 + i) % base.length];
        // كلما طلع المستوى الجملة كتطوال
        String q = item["q"]!;
        if(lvl>3) q = "Can you translate: $q ?";
        if(lvl>6) q = "Translate this long sentence: $q and it is very important for your life";
        levels[lvl]!.add({"q":q, "a":item["a"]!});
      }
    }
  }

  void translate(String input){
    String key = input.toLowerCase().trim();
    if(bigDict.containsKey(key)) setState(()=> result = bigDict[key]!);
    else if(key.contains(' ')){
      setState(()=> result = key.split(' ').map((w)=> bigDict[w] ?? w).join(' '));
    } else {
      setState(()=> result = "قريبا - القاموس فيه ${bigDict.length} كلمة");
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text('Tarjim - ${bigDict.length} كلمة | Duolingo Style')),
      body: Column(children: [
        Padding(padding: EdgeInsets.all(12), child: TextField(controller: ctrl, onChanged: translate, decoration: InputDecoration(labelText: 'ترجمة فورية - 30 الف كلمة', border: OutlineInputBorder()))),
        Text(result, style: TextStyle(fontSize: 20)),
        Divider(),
        Expanded(child: ListView.builder(itemCount: 10, itemBuilder: (c,i){
          int lvl = i+1;
          bool locked = lvl>1 ? false : false; // تقدر تدير نظام القفل
          return ListTile(
            leading: CircleAvatar(child: Text('$lvl')),
            title: Text('المستوى $lvl - ${lvl==1 ? "سهل - التحيات" : lvl<4 ? "متوسط - العائلة والمدرسة" : lvl<7 ? "صعب - جمل طويلة" : "صعب جدا - بحال Duolingo"}'),
            subtitle: LinearProgressIndicator(value: lvl==1 ? 1 : 0.1),
            trailing: ElevatedButton(child: Text(lvl==1 ? 'ابدأ' : 'العب'), onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> DuolingoGame(level: lvl)))),
          );
        }))
      ]),
    );
  }
}

class DuolingoGame extends StatefulWidget {
  final int level;
  DuolingoGame({required this.level});
  @override _DuolingoGameState createState() => _DuolingoGameState();
}

class _DuolingoGameState extends State<DuolingoGame> {
  int index = 0; int score = 0; int hearts = 5;
  
  @override
  Widget build(BuildContext context){
    var qList = levels[widget.level]!;
    var current = qList[index];
    double progress = (index+1)/50;
    
    return Scaffold(
      appBar: AppBar(title: Text('مستوى ${widget.level} - ${index+1}/50'), bottom: PreferredSize(preferredSize: Size.fromHeight(6), child: LinearProgressIndicator(value: progress, color: Colors.green))),
      body: Padding(padding: EdgeInsets.all(16), child: Column(children: [
        Row(children: [Icon(Icons.favorite, color: Colors.red), Text(' $hearts'), Spacer(), Text('⭐ $score/50')]),
        SizedBox(height: 30),
        Text(current["q"]!, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        SizedBox(height: 30),
        // بحال Duolingo - 4 اختيارات
        ...[current["a"]!, "وداعا", "شكرا", "خطأ"].map((opt){
          return Container(width: double.infinity, margin: EdgeInsets.only(bottom: 10), child: ElevatedButton(
            style: ElevatedButton.styleFrom(padding: EdgeInsets.all(18), backgroundColor: Colors.white, foregroundColor: Colors.black, side: BorderSide(color: Colors.grey.shade300)),
            onPressed: (){
              if(opt == current["a"]){
                setState((){
                  score++;
                  if(index < 49) index++; else {
                    showDialog(context: context, builder: (_)=> AlertDialog(
                      title: Text('🎉 برافو! كملتي المستوى ${widget.level}'),
                      content: Text('جبتي $score/50\nالإعلان غادي يبان 3 ثواني عاد تدوز للمستوى الجاي'),
                      actions: [ElevatedButton(onPressed: (){ Navigator.pop(context); Navigator.pop(context); }, child: Text('المتابعة'))]
                    ));
                  }
                });
              } else {
                setState(()=> hearts--);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ! الجواب: ${current["a"]}')));
              }
            },
            child: Text(opt, style: TextStyle(fontSize: 18)),
          ));
        }).toList(),
      ])),
    );
  }
}

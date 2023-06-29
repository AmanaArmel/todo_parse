import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

void main() async{
  final keyApplicationId ="dDmph5pv79s7rhKUvKif5lK005DWzU99wyWqKYLn";
  final KeyClientKey="zoBbXhfs80uSGYLTXU45qJrQeNX6RBqOTrRv5swE";
  final KeyParseServerUrl='https://parseapi.back4app.com';

  await Parse().initialize(keyApplicationId, KeyParseServerUrl,
      clientKey:KeyClientKey,
      liveQueryUrl: 'https://armel.b4a.io',
      debug: true);

  runApp(const MyApp());
}

Future<List<ParseObject>> getTodo() async{
QueryBuilder<ParseObject> queryTodo=
  QueryBuilder<ParseObject>(ParseObject('Message'));
queryTodo.excludeKeys(['objectId']);
final ParseResponse apiResponse = await queryTodo.query();
if(apiResponse.success && apiResponse.result !=null){
print("Success");
return apiResponse.results as List<ParseObject>;
}else{
return [];
}}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  Future<List<ParseObject>> _listFuture=Future.value([]);

  @override
  void initState() {
    super.initState();
    _listFuture = getTodo();
    startLiveQuery();
  }
void startLiveQuery() async{
  QueryBuilder<ParseObject> queryTodo=
  QueryBuilder<ParseObject>(ParseObject('Message'));
  final liveQuery = LiveQuery();
  final subsciption = await liveQuery.client.subscribe(queryTodo);
  subsciption.on(LiveQueryEvent.create,(value)
  {
    debugPrint('create : $value');
    final message = value as ParseObject;
    setState(() {
      _listFuture = getTodo(); // Refresh the list by fetching it again
    });

});
}

  Future<void> initParse(String content,bool isUser) async{
    final keyApplicationId ="dDmph5pv79s7rhKUvKif5lK005DWzU99wyWqKYLn";
    final KeyClientKey="zoBbXhfs80uSGYLTXU45qJrQeNX6RBqOTrRv5swE";
    final KeyParseServerUrl='https://parseapi.back4app.com';

    await Parse().initialize(keyApplicationId, KeyParseServerUrl,clientKey:KeyClientKey,autoSendSessionId: true );

    var Messages = ParseObject("Message")
      ..set('content', content)
      ..set('isUser', isUser);
    await Messages.save();
  }
  final _content = TextEditingController();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: Center(

        child: Stack(
          children: [
            buildFutureBuilder(),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.only(topRight:Radius.elliptical(300, 70),topLeft:Radius.elliptical(300, 70))
                ),
                height: MediaQuery.of(context).size.height*0.2,
                child: Row(
                  children: [
                    Expanded(
                        child: Container(
                          margin:EdgeInsets.symmetric(horizontal: 30),
                          padding: EdgeInsets.only(left: 20),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30)
                          ),
                          child: TextField(
                            controller: _content,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'message'
                            ),

                          ),
                        )
                    ),
                    Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30)
                        ),
                        margin: EdgeInsets.only(right: 30),
                        child: IconButton(
                            onPressed: (){
                              initParse(_content.text, true);
                              _content.clear();
                            },
                            icon: Icon(Icons.send)
                        )
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  FutureBuilder<List<ParseObject>> buildFutureBuilder() {
    return FutureBuilder<List<ParseObject>>(
        future: _listFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            final List<ParseObject>? messages = snapshot.data;
            return ListView.builder(
              itemCount: messages?.length,
              itemBuilder: (context, index) {
                final message = messages?[index];
                final content = message?.get<String>('content');
                final isUser=message?.get<bool>('isUser');
                return ListTile(
                  title:Column(
                    crossAxisAlignment: _alignement(isUser!),
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius:_border(isUser!)
                        ),
                        child: Text(content!),
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return Text('No messages found.');
          }
        },
      );
  }
  _border(bool isUser){
    if(isUser){
      return BorderRadius.only(topLeft: Radius.circular(30),bottomRight: Radius.circular(30),bottomLeft: Radius.circular(30));
    }else{
      return BorderRadius.only(topRight: Radius.circular(30),bottomRight: Radius.circular(30),bottomLeft: Radius.circular(30));
    }
  }
  _alignement(bool isUser){
    if(isUser){
      return CrossAxisAlignment.end;
    }else{
      return CrossAxisAlignment.start;
    }}

}

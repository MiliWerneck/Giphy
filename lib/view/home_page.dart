import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:giphy/view/gif_page.dart';
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _criterioBusca;
  int _paginacao = 0;

  dynamic _buscarGifs() async{
    http.Response response;

  if (_criterioBusca == null || _criterioBusca == '')
    response = await http.get ('https://api.giphy.com/v1/gifs/trending?api_key=EdlgZBogDaUPPg5pz2R1sL8sqUGqqoFm&limit=25&rating=R');
  else
    response = await http.get('https://api.giphy.com/v1/gifs/search?api_key=EdlgZBogDaUPPg5pz2R1sL8sqUGqqoFm&q=$_criterioBusca&limit=$_paginacao&offset=0&rating=R&lang=pt');
  return json.decode(response.body);
  }
  int _getQuantidade(List dados){ //Pode usar search.isEmpty
    if (_criterioBusca == null || _criterioBusca == ' ')
      return dados.length;
    else
    return dados.length +1;
  }

  Widget _exibeListaGifs(BuildContext context, AsyncSnapshot snapshot){
    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
        itemCount: _getQuantidade(snapshot.data['data']),
        itemBuilder: (context, index){

    if ((_criterioBusca == null || _criterioBusca == ' ')||
      index < snapshot.data['data'].length)
      return GestureDetector( 
        child: FadeInImage.memoryNetwork( 
          key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
          placeholder: kTransparentImage,
          image: snapshot.data['data'][index]['images']['fixed_height']['url'],
          height: 300,
          fit: BoxFit.cover,
        ),
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context)=>
            new GifPage(snapshot.data['data'][index])));
      },
      onLongPress: (){ 
        Share.share(snapshot.data['data'][index]['images']['fixed_height']['url']);
      },
      );
      else
        return Container( 
          child: GestureDetector( 
            child: Column( 
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[ 
                Icon( 
                  Icons.add,
                  color: Colors.white,
                  size: 70,
                ),
                Text ( 
                  'Carregar mais ...',
                  style: TextStyle(color: Colors.white, fontSize: 22),
                  )
              ],
            ),
            onTap: () { 
              setState(() {
                _paginacao += 19;
              });
            },
          ),
        );
        },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( 
        backgroundColor: Colors.black,
        title: Image.network(
          'https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif'),
        centerTitle: true,
      ),

      backgroundColor: Colors.black,
      body: Column( 
        children: <Widget>[ 
          Padding( 
            padding: EdgeInsets.all(10),
            child: TextField( 
              decoration: InputDecoration( 
                labelText: 'Critério de busca...',
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder()),
              style: TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
              onSubmitted: (texto){ 
                setState((){ 
                  _criterioBusca = texto;
                  _paginacao = 0;
                });
              },
              ),
            ),
        Expanded( 
          child: FutureBuilder( 
            future: _buscarGifs(),
            builder: (context, snapshot){ 
              switch (snapshot.connectionState){ 
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return Container( 
                    width: 200,
                    height: 200,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator( 
                      valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 5),
                    );
                    default: 
                      if (snapshot.hasError)
                        return Container();
                      else
                        return _exibeListaGifs(context, snapshot);
                    }
              },
            ),
          )
        ],
      ),
    );
  }
}
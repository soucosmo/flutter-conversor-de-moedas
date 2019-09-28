import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
//import 'dart:async';
const api = 'https://api.hgbrasil.com/finance?format=json&key=ae37708a';


void main() async {
	print( await getData());

	runApp(
		MaterialApp(
			home: Home(),
			theme: ThemeData(
				hintColor: Colors.amber,
				primaryColor: Colors.white
			),
		)
	);

	
}

Future<Map> getData() async {
	http.Response response = await http.get(api);

	return json.decode(response.body)['results']['currencies'];
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
	double dolar;
	double euro;
	final realController = TextEditingController();
	final dolarController = TextEditingController();
	final euroController = TextEditingController();

	void _resetar() {
		realController.text = '';
		dolarController.text = '';
		euroController.text = '';
	}

	void _realChange(data) {
		
		double real = double.parse(data.toString().replaceAll(',', '.'));
		dolarController.text = (real/dolar).toStringAsFixed(2);
		euroController.text = (real/euro).toStringAsFixed(2);
	}

	void _dolarChange(data) {
		double dolar = double.parse(data.toString().replaceAll(',', '.'));
		realController.text = (dolar*this.dolar).toStringAsFixed(2);
		euroController.text = (dolar * this.dolar / this.euro).toStringAsFixed(2);
	}

	void _euroChange(data) {
		double euro = double.parse(data.toString().replaceAll(',', '.'));
		realController.text = (euro * this.euro).toStringAsFixed(2);
		dolarController.text = (euro * this.euro / this.dolar).toStringAsFixed(2);
	}

  @override
  Widget build(BuildContext context) {
	return Scaffold(
		backgroundColor: Colors.black,
		appBar: AppBar(
			title: Text('Conversor de Moedas'),
			centerTitle: true,
			backgroundColor: Colors.amber,
			actions: <Widget>[
				IconButton(
					icon: Icon(Icons.refresh),
					onPressed: _resetar,
				)
			],

		),
		body: FutureBuilder<Map>(
			future: getData(),
			builder: (context, snapshot) {
				switch(snapshot.connectionState) {
					case ConnectionState.waiting:
						return Center(
							child: Text('Carregando dados...', textAlign: TextAlign.center, style: TextStyle(color: Colors.amber, fontSize: 30)),
							
						);
					default:
						if (snapshot.hasError) {
							return Center(
								child: Text('Erro ao carregar dados :(', textAlign: TextAlign.center)
							);
						} else {
							dolar = snapshot.data['USD']['buy'];
							euro = snapshot.data['EUR']['buy'];
							return SingleChildScrollView(
								padding: EdgeInsets.all(10),
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.stretch,
									children: <Widget>[
											Divider(),
											Icon(Icons.monetization_on, size: 150, color: Colors.amber),
											Divider(),
											CampoTexto('Reais', 'R\$', realController, _realChange),
											Divider(),
											CampoTexto('Doláres', 'US\$', dolarController, _dolarChange),
											Divider(),
											CampoTexto('Euros', '€', euroController, _euroChange),
									],
								),
							);
						}
					
				}
			}
		)
	);
  }
}


Widget CampoTexto(label, prefix, controller, change) {
	return TextField(
		decoration: InputDecoration(
			labelText: label,
			labelStyle: TextStyle(color: Colors.amber),
			enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
			prefix: Text('$prefix '),
		),
		cursorColor: Colors.amber,
		style: TextStyle(color: Colors.amber, fontSize: 25),
		controller: controller,
		keyboardType: TextInputType.number,
		onChanged: change,
	);
}
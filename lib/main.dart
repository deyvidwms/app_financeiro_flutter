import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request =
    "https://api.hgbrasil.com/finance?format=json-cors&key=058b8395";

void main() async {
  runApp(MaterialApp(
    home: DefaultTabController(
      length: 2,
      child: Home(),
    ),
    theme: ThemeData(hintColor: Colors.amber, primaryColor: Colors.amber),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(Uri.parse(request));
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<String> currencyNames = [];

  final List<String> firstSelectOptions = [];
  final List<String> secondSelectOptions = [];

  String firstCurrencyType = "USD";
  final firstCurrencyTypeController = TextEditingController();

  String secondCurrencyType = "EUR";
  final secondCurrencyTypeController = TextEditingController();

  final firstCurrencyController = TextEditingController();
  final secondCurrencyController = TextEditingController();

  double firstCurrency = 0;
  double secondCurrency = 0;

  void _currencyTypeChange(
      String? text, Map<String, dynamic> currencies, bool isFirstCurrencyType) {
    if (text != null) {
      if (isFirstCurrencyType) {
        if (text == secondCurrencyType) {
          secondCurrencyTypeController.text = firstCurrencyType;
          secondCurrencyType = firstCurrencyType;
        }
        firstCurrencyTypeController.text = text;
        firstCurrencyType = text;
      } else {
        if (text == firstCurrencyType) {
          firstCurrencyTypeController.text = secondCurrencyType;
          firstCurrencyType = secondCurrencyType;
        }
        secondCurrencyTypeController.text = text;
        secondCurrencyType = text;
      }

      firstCurrency =
          firstCurrencyType == "BRL" ? 1 : currencies[firstCurrencyType]["buy"];

      secondCurrency = secondCurrencyType == "BRL"
          ? 1
          : currencies[secondCurrencyType]["buy"];

      _firstCurrencyChange(firstCurrencyController.text);
    }
  }

  void _firstCurrencyChange(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    double currency = double.parse(text);

    secondCurrencyController.text = firstCurrencyType == "BRL"
        ? (currency / secondCurrency).toStringAsFixed(2)
        : ((currency * firstCurrency) / secondCurrency).toStringAsFixed(2);
  }

  void _secondCurrencyChange(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    double currency = double.parse(text);

    firstCurrencyController.text = secondCurrencyType == "BRL"
        ? (currency / firstCurrency).toStringAsFixed(2)
        : ((currency * secondCurrency) / firstCurrency).toStringAsFixed(2);
  }

  void _clearAll() {
    firstCurrencyController.text = "";
    secondCurrencyController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: const TabBar(
            labelColor: Colors.amber,
            dividerColor: Colors.amber,
            indicatorColor: Colors.amber,
            tabs: [
              Tab(icon: Icon(Icons.swap_horiz)),
              Tab(icon: Icon(Icons.monetization_on)),
            ]),
        appBar: AppBar(
            title: const Text("\$ Conversor de Moedas \$"),
            centerTitle: true,
            backgroundColor: Colors.amber),
        body: TabBarView(children: [
          FutureBuilder<Map>(
              future: getData(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.active:
                  case ConnectionState.waiting:
                    return const Center(
                        child: Text(
                      "Carregando dados...",
                      style: TextStyle(color: Colors.amber, fontSize: 25.0),
                      textAlign: TextAlign.center,
                    ));
                  default:
                    if (snapshot.hasError) {
                      return const Center(
                          child: Text(
                        "Erro ao carregar dados...",
                        style: TextStyle(color: Colors.amber, fontSize: 25.0),
                        textAlign: TextAlign.center,
                      ));
                    } else {
                      var currencies = snapshot.data!["results"]["currencies"]
                          as Map<String, dynamic>;

                      currencyNames.clear();
                      currencies.keys.toList().forEach((currency) =>
                          currencyNames.add(currency != "source"
                              ? currency
                              : currencies["source"]));

                      firstSelectOptions.clear();
                      firstSelectOptions.addAll(currencyNames);

                      secondSelectOptions.clear();
                      secondSelectOptions.addAll(currencyNames);

                      firstCurrencyType = firstSelectOptions.first;
                      secondCurrencyType = secondSelectOptions[1];

                      firstCurrency = firstCurrencyType == "BRL"
                          ? 1
                          : snapshot.data!["results"]["currencies"]
                              [firstCurrencyType]["buy"];

                      secondCurrency = secondCurrencyType == "BRL"
                          ? 1
                          : snapshot.data!["results"]["currencies"]
                              [secondCurrencyType]["buy"];

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            const Icon(Icons.monetization_on,
                                size: 150.0, color: Colors.amber),
                            const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Expanded(
                                  child: Divider(),
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    buildSelectFormField(
                                        firstSelectOptions,
                                        _currencyTypeChange,
                                        firstCurrencyType,
                                        firstCurrencyTypeController,
                                        currencies,
                                        true)
                                  ],
                                ),
                                const Column(
                                  children: <Widget>[Icon(Icons.swap_horiz)],
                                ),
                                Column(
                                  children: <Widget>[
                                    buildSelectFormField(
                                        secondSelectOptions,
                                        _currencyTypeChange,
                                        secondCurrencyType,
                                        secondCurrencyTypeController,
                                        currencies,
                                        false)
                                  ],
                                )
                              ],
                            ),
                            const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Expanded(
                                  child: Divider(),
                                ),
                              ],
                            ),
                            buildTextFormField("Moeda 1", "\$",
                                firstCurrencyController, _firstCurrencyChange),
                            const Divider(),
                            buildTextFormField(
                                "Moeda 2",
                                "\$",
                                secondCurrencyController,
                                _secondCurrencyChange),
                            const Divider(),
                          ],
                        ),
                      );
                    }
                }
              }),
          FutureBuilder<Map>(
              future: getData(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.active:
                  case ConnectionState.waiting:
                    return const Center(
                        child: Text(
                      "Carregando dados...",
                      style: TextStyle(color: Colors.amber, fontSize: 25.0),
                      textAlign: TextAlign.center,
                    ));
                  default:
                    if (snapshot.hasError) {
                      return const Center(
                          child: Text(
                        "Erro ao carregar dados...",
                        style: TextStyle(color: Colors.amber, fontSize: 25.0),
                        textAlign: TextAlign.center,
                      ));
                    } else {
                      var bitcoin_infos = snapshot.data!["results"]["bitcoin"]
                          as Map<String, dynamic>;

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            DataTable(
                              columns: const <DataColumn>[
                                DataColumn(
                                  label: Expanded(
                                    child: Text(
                                      'Nome',
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Expanded(
                                    child: Text(
                                      'Compra',
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Expanded(
                                    child: Text(
                                      'Venda',
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                ),
                              ],
                              rows: bitcoin_infos.entries
                                  .map(
                                    (item) => DataRow(
                                      cells: <DataCell>[
                                        DataCell(Text(item.value["name"])),
                                        DataCell(Text(item.value["buy"] != null
                                            ? item.value["buy"].toString()
                                            : "Valor não encontrado")),
                                        DataCell(Text(item.value["sell"] != null
                                            ? item.value["sell"].toString()
                                            : "Valor não encontrado")),
                                      ],
                                    ),
                                  )
                                  .toList(),
                            )
                          ],
                        ),
                      );
                    }
                }
              }),
        ]));
  }

  Widget buildSelectFormField(
      List<String> options,
      changeFunction,
      String defaultValue,
      TextEditingController controller,
      Map<String, dynamic> currencies,
      bool isFirstCurrencyType) {
    return DropdownMenu<String>(
      initialSelection: defaultValue,
      onSelected: (String? value) =>
          changeFunction(value, currencies, isFirstCurrencyType),
      controller: controller,
      dropdownMenuEntries:
          options.map<DropdownMenuEntry<String>>((String value) {
        return DropdownMenuEntry<String>(value: value, label: value);
      }).toList(),
    );
  }

  Widget buildTextFormField(String label, String prefix,
      TextEditingController controller, Function f) {
    return TextField(
      onChanged: (value) => f(value),
      controller: controller,
      decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.amber),
          border: const OutlineInputBorder(),
          prefixText: "$prefix "),
      style: const TextStyle(color: Colors.amber, fontSize: 25.0),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
  }
}

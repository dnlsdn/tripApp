import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:travel_app/Controllers/UserMethods.dart';

class Contacts extends StatefulWidget {
  const Contacts({super.key});

  @override
  State<Contacts> createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  final TextEditingController controller = TextEditingController();
  List<String> suggestions = [];
  late UserMethods userMethods;

  @override
  void initState() {
    super.initState();
    userMethods = UserMethods();
    controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    controller.removeListener(_onSearchChanged);
    controller.dispose();
    super.dispose();
  }

  void _onSearchChanged() async {
    print(
        'Ricerca in corso: ${controller.text}'); // Aggiungi questa linea per debug
    final _suggestions = await userMethods.getSuggestions(controller.text);
    setState(() {
      suggestions = _suggestions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Contacts',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
              SizedBox(
                height: 18,
              ),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Cerca...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Stack(
                children: [
                  Column(
                    children: [
                      Text('ciao'),
                    ],
                  ),
                  if (controller.text.isNotEmpty)
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        height: MediaQuery.of(context).size.height / 2,
                        //color: Colors.black,
                        decoration: BoxDecoration(
                            color: Colors.black,
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(8)),
                        child: suggestions.isEmpty
                            ? Center(child: Text('Nessun suggerimento trovato'))
                            : ListView.builder(
                                itemCount: suggestions.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(suggestions[index]),
                                    onTap: () {
                                      controller.text = suggestions[index];
                                      // Aggiungi logica da eseguire alla selezione del suggerimento
                                    },
                                  );
                                },
                              ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

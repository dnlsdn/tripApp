import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddItinerary extends StatefulWidget {
  const AddItinerary({super.key});

  @override
  State<AddItinerary> createState() => _AddItineraryState();
}

class _AddItineraryState extends State<AddItinerary> {
  DateTime? startDate;
  DateTime? endDate;

  Future<void> selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate ??
          DateTime.now(), // Usa la data corrente se startDate è null
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.white, // Colore dell'intestazione
              onPrimary: Colors.black, // Colore del testo dell'intestazione
              onSurface: Colors.white, // Colore del testo dei giorni
            ),
            //dialogBackgroundColor: Colors.green, // Colore dello sfondo
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != startDate) {
      setState(() {
        startDate = picked;
      });
    }
  }

  Future<void> selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      barrierColor: Colors.white,
      context: context,
      initialDate: null,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != endDate) {
      setState(() {
        endDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      highlightColor: Colors.transparent,
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 22),
                    ),
                  ),
                  const SizedBox(width: 18),
                  const Text(
                    'Add Itinerary',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 27,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 18,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      'Start Date',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    InkWell(
                      onTap: () {
                        selectStartDate(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: startDate == null
                            ? Text('Select Date')
                            : Text(DateFormat('dd/MM/yyyy').format(startDate!)),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text('End Date'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:receipt_recognition/receipt_recognition.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
//receipt recognition 0.2.8 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ReceiptTestPage(),
    );
  }
}

class ReceiptTestPage extends StatefulWidget {
  const ReceiptTestPage({super.key});

  @override
  State<ReceiptTestPage> createState() => _ReceiptTestPageState();
}

class _ReceiptTestPageState extends State<ReceiptTestPage> {
  final ReceiptRecognizer receiptRecognizer = ReceiptRecognizer(
    options: ReceiptOptions.fromLayeredJson({
      "extend": {
        "storeNames": {"JOLLIBEE": "Jollibee", "SM MARKET": "SM", "PUREGOLD": "Puregold"},
        "totalLabels": {
          "TOTAL": "Total",
          "TOTAL DUE": "Total",
          "AMOUNT DUE": "Amount Due",
          "AMT DUE": "Amount Due",
          "GRAND TOTAL": "Total",
          "CASH": "Cash"
        }
      }
    }),
    onScanComplete: (receipt) {
      print("Scan complete: ${receipt.total?.formattedValue}");
    },
  );

  final ImagePicker _picker = ImagePicker();
  String resultText = "";

   Future<void> _scanFromSource(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile == null) return;

    final inputImage = InputImage.fromFilePath(pickedFile.path);
    final snapshot = await receiptRecognizer.processImage(inputImage);

    String output = "";
    output += "Valid: ${snapshot.isValid}\n";
    output += "Confirmed: ${snapshot.isConfirmed}\n\n";
    output += "Store: ${snapshot.store?.value ?? 'Not detected'}\n";
    output += "Total: ${snapshot.total?.formattedValue ?? 'Not detected'}\n";

    if (snapshot.positions.isNotEmpty) {
      output += "\nItems:\n";
      for (final pos in snapshot.positions) {
        output += "${pos.product.formattedValue} - ${pos.price.formattedValue}\n";
      }
    } else {
      output += "\nNo items detected.\n";
    }

    setState(() => resultText = output);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Receipt Recognition Test")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _scanFromSource(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text("Gallery"),
                ),
                ElevatedButton.icon(
                  onPressed: () => _scanFromSource(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Camera"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(resultText),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    receiptRecognizer.close();
    super.dispose();
  }
}
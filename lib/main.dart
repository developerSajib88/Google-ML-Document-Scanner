import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  int documentNumber = 0;
  String? scanText;
  DocumentScanningResult? result; 

  DocumentScannerOptions documentOptions = DocumentScannerOptions(
    documentFormat: DocumentFormat.jpeg, // set output document format
    mode: ScannerMode.filter, // to control what features are enabled
    pageLimit: 1, // setting a limit to the number of pages scanned
    isGalleryImport: true, // importing from the photo gallery
  );


  Future<void> scanDocument()async{
    final documentScanner = DocumentScanner(options: documentOptions);
    result = await documentScanner.scanDocument();
    setState(() {});
  }

  Future<void> recognizeDocumentText()async{
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText = await textRecognizer.processImage(InputImage.fromFile(File(result?.images.first ?? "")));

    //scanText = recognizedText.text;
    for (TextBlock block in recognizedText.blocks) {
      final Rect rect = block.boundingBox;
      final List<Point<int>> cornerPoints = block.cornerPoints;
      final String text = block.text;
      final List<String> languages = block.recognizedLanguages;
      bool gotGPA = false;

      for (TextLine line in block.lines) {
        // Same getters as TextBlock
        print(">>>>>>>>>>>>>>>>>Line: ${line.text}");
        for (TextElement element in line.elements) {
          print(">>>>>>>>>>>>>>>>>Element: ${element.text}");
          if(gotGPA) {
            scanText = element.text;
            break;
          }
          if(element.text == "GPA" || element.text == "G.P.A" || element.text == "G.PA" || element.text == "GP.A"){
            gotGPA = true;
          }
        }
      }
    }
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    
    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text(
          "Document Scanner",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(20),
        child: result?.images != null ?
        Column(
          children: [
            
            scanText != null ?
            Expanded(
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "I am GPA",
                      style: const TextStyle(
                        color: Colors.black, 
                        fontSize: 20
                        ),
                    ),

                    const SizedBox(width: 10,),

                    Text(
                      scanText ?? "No Result",
                      style: const TextStyle(
                        color: Colors.pink, 
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                        ),
                    ),

                  ],
                )
              )
            )
            : SizedBox(
              height: 500,
              child: PageView.builder(
                itemCount: result?.images.length,
                scrollDirection: Axis.horizontal,
                onPageChanged: (value){
                  documentNumber = value+1;
                  setState(() {});
                },
                itemBuilder: (context,index){
                  return Center(
                    child: Image.file(
                      File(result?.images[index]??""),
                      width: double.infinity,
                      height: 500,
                      fit: BoxFit.cover,
                      
                    ),
                  );
                }
              ),
            ),

            const SizedBox(height: 10,),

            Text(
              "$documentNumber/${result?.images.length ?? 0}",
            )
          
          ],
        ): 
        const Center(child: Text(
          "No Result",
        ),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: ()=> result?.images != null ? recognizeDocumentText() :scanDocument(),
        backgroundColor: Colors.blue,
        child: Icon(
          result?.images != null ? Icons.document_scanner : Icons.screenshot,
          color: Colors.white,
        ),
      ), 


    );
  }
}

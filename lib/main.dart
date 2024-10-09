import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';


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


  int documentNumber = 1;
  DocumentScanningResult? result; 

  DocumentScannerOptions documentOptions = DocumentScannerOptions(
    documentFormat: DocumentFormat.jpeg, // set output document format
    mode: ScannerMode.filter, // to control what features are enabled
    pageLimit: 3, // setting a limit to the number of pages scanned
    isGalleryImport: true, // importing from the photo gallery
  );


  Future<void> scanDocument()async{
    final documentScanner = DocumentScanner(options: documentOptions);
    result = await documentScanner.scanDocument();
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
            
            SizedBox(
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
        ): const Center(child: Text(
          "No Result",
          ),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: ()=> scanDocument(),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.document_scanner,color: Colors.white,),
      ), 


    );
  }
}

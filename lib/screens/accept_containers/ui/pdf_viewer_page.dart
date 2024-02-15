import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:url_launcher/url_launcher.dart';

class PdfViewerPage extends StatelessWidget {
  final String pdfData;
  final int driverId;
  final int orderId;
  final int pointId;

  const PdfViewerPage(
      {Key? key,
        required this.pdfData,
        required this.driverId,
        required this.orderId,
        required this.pointId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
      ),
      body: FutureBuilder(
        future: _getPdfBytesFromBase64(),
        builder: (context, AsyncSnapshot<Uint8List?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return PDFView(
              pdfData: snapshot.data!,
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     _launchURL();
      //   },
      //   child: Text('Подписать'),
      // ),
    );
  }

  Future<Uint8List?> _getPdfBytesFromBase64() async {
    try {
      final decodedData = base64.decode(pdfData);
      return Uint8List.fromList(decodedData);
    } catch (e) {
      print('Error decoding PDF data: $e');
      return null;
    }
  }

// _launchURL() async {
//   const url =
//       'https://mgovsign.page.link/?link=https://api.sattiway.kz/api/v2/egov/ttnSign/$driverId/$orderId/tsd/$pointId/apt1/mgovSign&apn=kz.mobile.mgov';
//   if (await canLaunch(url)) {
//     await launch(url);
//   } else {
//     throw 'Could not launch $url';
//   }
// }
}
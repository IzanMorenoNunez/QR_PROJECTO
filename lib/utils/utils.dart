import 'package:flutter/material.dart';
import 'package:qr_scan/models/scan_model.dart';
import 'package:url_launcher/url_launcher.dart';

void launchURL(BuildContext context, ScanModel scan) async {
  final url = scan.valor;
  if (scan.tipus == 'http') {
    if (!await launch(url)) throw 'Could not launc $url';
  } else {
    Navigator.pushNamed(context, 'mapa', arguments: scan);
  }
}

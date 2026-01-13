import 'package:flutter/foundation.dart';
import 'package:qr_scan/models/scan_model.dart';
import 'package:qr_scan/providers/db_provider.dart';

class ScanListProvider extends ChangeNotifier {
  List<ScanModel> scans = [];
  String tipusSeleccionat = 'http';

  Future<ScanModel> nouScan(String valor) async {
    final nouScan = ScanModel(valor: valor);
    final id = await DBProvider.db.insertScan(nouScan);
    nouScan.id = id;

    if (nouScan.tipus == tipusSeleccionat) {
      this.scans.add(nouScan);
      notifyListeners();
    }

    return nouScan;
  }

  carregaScans() async {
    final scans = await DBProvider.db.getAllScans();
    this.scans = [...scans];
    notifyListeners();
  }

  carregScansPerTipus(String tipus) async {
    final scans = await DBProvider.db.getScanByTipus(tipus);
    this.scans = [...scans];
    this.tipusSeleccionat = tipus;
    notifyListeners();
  }

  esborraTots() async {
    await DBProvider.db.deleteAllScans();
    scans = [];
    notifyListeners();
  }

  esborraPerID(int id) async {
    await DBProvider.db.deleteScan(id);
    scans.removeWhere((scan) => scan.id == id);
    notifyListeners();
  }
}

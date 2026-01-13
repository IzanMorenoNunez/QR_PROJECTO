import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:qr_scan/models/scan_model.dart';
import 'package:qr_scan/providers/scan_list_provider.dart';
import 'package:qr_scan/utils/utils.dart';

class ScanButton extends StatelessWidget {
  const ScanButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      elevation: 0,
      child: const Icon(Icons.filter_center_focus),
      onPressed: () async {
        print('Botó polsat!');

        String? barcodeScanRes;

        await showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            final cameraController = MobileScannerController(
              detectionSpeed: DetectionSpeed.noDuplicates,
              formats: [BarcodeFormat.qrCode],
              torchEnabled: true, // Enciende flash para más luz y menos glare
              returnImage: false,
              facing: CameraFacing.back,
              // Añade esto si tu versión lo soporta (prueba versiones 5.2+)
              // resolution: CameraResolution.high, // o CameraResolution.max si disponible
            );

            return AlertDialog(
              contentPadding: EdgeInsets.zero,
              content: SizedBox(
                width: double.maxFinite,
                height: 350,
                child: Stack(
                  children: [
                    MobileScanner(
                      controller: cameraController,
                      onDetect: (BarcodeCapture capture) {
                        final barcode = capture.barcodes.firstOrNull;
                        if (barcode != null && barcode.rawValue != null) {
                          barcodeScanRes = barcode.rawValue!;
                          print(barcodeScanRes);

                          final scanListProvider =
                              Provider.of<ScanListProvider>(
                            context,
                            listen: false,
                          );

                          final nouScan = ScanModel(valor: barcodeScanRes!);
                          scanListProvider.nouScan(barcodeScanRes!);
                          launchURL(context, nouScan);

                          // Cerramos automáticamente el diálogo al detectar
                          Navigator.pop(dialogContext);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('No s\'ha pogut llegir el QR.'),
                            ),
                          );
                        }
                      },
                    ),

                    // Botón de cerrar (como en el ejemplo que te funciona  )
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.close,
                            color: Colors.red, size: 32),
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );

        // Si el usuario cierra sin detectar QR, barcodeScanRes sigue siendo null
        if (barcodeScanRes == null || barcodeScanRes!.isEmpty) {
          print('Escaneig cancel·lat o sense resultat');
          return;
        }
      },
    );
  }
}

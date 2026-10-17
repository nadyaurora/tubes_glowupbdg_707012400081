import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/riwayat_laporan_cubit.dart';

class DetailLaporan extends StatefulWidget {
  final Map<String, String> data;

  const DetailLaporan({super.key, required this.data});

  @override
  State<DetailLaporan> createState() => _DetailLaporanState();
}

class _DetailLaporanState extends State<DetailLaporan> {
  // State lokal untuk indikator proses pada halaman detail.
  bool _sedangMemproses = false;

  Future<void> konfirmasiLaporan() async {
    if (_sedangMemproses) {
      return;
    }

    final riwayat = context.read<RiwayatLaporanCubit>();

    if (riwayat.sudahTersimpan(widget.data)) {
      return;
    }

    setState(() {
      _sedangMemproses = true;
    });

    await Future<void>.delayed(const Duration(seconds: 2));

    if (!mounted) {
      return;
    }

    if (ModalRoute.of(context)?.isCurrent != true) {
      setState(() {
        _sedangMemproses = false;
      });
      return;
    }

    // Memeriksa kembali setelah simulasi proses selesai.
    final sudahTersimpan = riwayat.sudahTersimpan(widget.data);

    if (!sudahTersimpan) {
      riwayat.tambahLaporan(widget.data);
    }

    setState(() {
      _sedangMemproses = false;
    });

    final judul = widget.data['judul'] ?? 'Laporan';

    Navigator.pop(
      context,
      sudahTersimpan
          ? 'Laporan "$judul" sudah tersimpan di riwayat.'
          : 'Laporan "$judul" berhasil disimpan ke riwayat.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RiwayatLaporanCubit, List<Map<String, String>>>(
      builder: (context, daftarRiwayat) {
        Map<String, String>? laporanTersimpan;

        for (final laporan in daftarRiwayat) {
          if (laporan['judul'] == widget.data['judul'] &&
              laporan['lokasi'] == widget.data['lokasi']) {
            laporanTersimpan = laporan;
            break;
          }
        }

        final sudahTersimpan = laporanTersimpan != null;

        // Mengutamakan data terbaru dari Cubit.
        final data = laporanTersimpan ?? widget.data;

        return Scaffold(
          appBar: AppBar(title: const Text('Detail Laporan')),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                data['judul'] ?? 'Laporan',
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.location_on_outlined),
                title: const Text('Lokasi'),
                subtitle: Text(data['lokasi'] ?? '-'),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Status'),
                subtitle: Text(data['status'] ?? '-'),
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('Keterangan'),
                subtitle: Text(data['deskripsi'] ?? '-'),
              ),
              const SizedBox(height: 24),
              if (sudahTersimpan) ...[
                Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Laporan sudah tersimpan'),
                    subtitle: const Text(
                      'Laporan ini sudah tercatat '
                      'pada Riwayat Laporan.',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              FilledButton.icon(
                onPressed: _sedangMemproses || sudahTersimpan
                    ? null
                    : konfirmasiLaporan,
                icon: _sedangMemproses
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        sudahTersimpan
                            ? Icons.check_circle
                            : Icons.check_circle_outline,
                      ),
                label: Text(
                  _sedangMemproses
                      ? 'Memproses...'
                      : sudahTersimpan
                      ? 'Sudah Dikonfirmasi'
                      : 'Konfirmasi Laporan',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

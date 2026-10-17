import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/riwayat_laporan_cubit.dart';
import '../navigation/app_routes.dart';

class Laporan extends StatelessWidget {
  const Laporan({super.key});

  static const Map<String, List<Map<String, String>>> data = {
    'Menunggu': [
      {
        'judul': 'Tumpukan sampah di Jalan Braga',
        'lokasi': 'Jalan Braga',
        'status': 'Menunggu',
        'deskripsi': 'Sampah menumpuk di sisi jalan.',
      },
      {
        'judul': 'Sampah rumah tangga',
        'lokasi': 'Kecamatan Coblong',
        'status': 'Menunggu',
        'deskripsi': 'Penjemputan sampah belum dilakukan.',
      },
      {
        'judul': 'TPS membutuhkan pengangkutan',
        'lokasi': 'Kecamatan Sukajadi',
        'status': 'Menunggu',
        'deskripsi': 'Kapasitas TPS hampir penuh.',
      },
    ],
    'Diproses': [
      {
        'judul': 'Pengaduan sampah pasar',
        'lokasi': 'Pasar Kosambi',
        'status': 'Diproses',
        'deskripsi': 'Laporan sedang ditangani petugas.',
      },
      {
        'judul': 'Penumpukan sampah lingkungan',
        'lokasi': 'Kecamatan Antapani',
        'status': 'Diproses',
        'deskripsi': 'Petugas sedang menuju lokasi.',
      },
      {
        'judul': 'Pengangkutan terlambat',
        'lokasi': 'Kecamatan Buahbatu',
        'status': 'Diproses',
        'deskripsi': 'Penjadwalan ulang pengangkutan.',
      },
    ],
    'Selesai': [
      {
        'judul': 'Pembersihan area publik',
        'lokasi': 'Alun-Alun Bandung',
        'status': 'Selesai',
        'deskripsi': 'Laporan telah diselesaikan.',
      },
      {
        'judul': 'Pengangkutan sampah warga',
        'lokasi': 'Kecamatan Lengkong',
        'status': 'Selesai',
        'deskripsi': 'Sampah telah diangkut petugas.',
      },
      {
        'judul': 'Penanganan TPS penuh',
        'lokasi': 'Kecamatan Cibeunying',
        'status': 'Selesai',
        'deskripsi': 'Kapasitas TPS telah ditangani.',
      },
    ],
  };

  Future<void> bukaDetail(
    BuildContext context,
    Map<String, String> item,
  ) async {
    final hasil = await Navigator.pushNamed(
      context,
      AppRoutes.detailLaporan,
      arguments: item,
    );

    if (!context.mounted || hasil == null) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(hasil.toString()),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Widget daftarLaporan(BuildContext context, List<Map<String, String>> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        return BlocSelector<
          RiwayatLaporanCubit,
          List<Map<String, String>>,
          bool
        >(
          selector: (daftarRiwayat) {
            return daftarRiwayat.any(
              (laporan) =>
                  laporan['judul'] == item['judul'] &&
                  laporan['lokasi'] == item['lokasi'],
            );
          },
          builder: (context, sudahTersimpan) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  child: Icon(
                    sudahTersimpan ? Icons.check : Icons.delete_outline,
                  ),
                ),
                title: Text(
                  item['judul']!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item['lokasi']}\n'
                        '${item['deskripsi']}',
                      ),
                      if (sudahTersimpan) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Tersimpan di riwayat',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (sudahTersimpan)
                      Icon(
                        Icons.bookmark,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                onTap: () {
                  bukaDetail(context, item);
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Material(
            color: Theme.of(context).colorScheme.surface,
            child: const TabBar(
              tabs: [
                Tab(text: 'Menunggu'),
                Tab(text: 'Diproses'),
                Tab(text: 'Selesai'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                daftarLaporan(context, data['Menunggu']!),
                daftarLaporan(context, data['Diproses']!),
                daftarLaporan(context, data['Selesai']!),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

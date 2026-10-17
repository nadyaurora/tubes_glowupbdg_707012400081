import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/riwayat_laporan_cubit.dart';
import '../navigation/app_routes.dart';

class Profil extends StatelessWidget {
  const Profil({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<RiwayatLaporanCubit, List<Map<String, String>>, int>(
      selector: (daftarLaporan) => daftarLaporan.length,
      builder: (context, totalLaporan) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 48,
                child: Icon(Icons.person, size: 48),
              ),
              const SizedBox(height: 16),
              Text(
                'Pengguna Glow Up Bandung',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Masyarakat Kota Bandung'),
              const SizedBox(height: 24),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Laporan Terkonfirmasi'),
                  subtitle: const Text(
                    'Jumlah laporan yang tersimpan '
                    'pada riwayat.',
                  ),
                  trailing: Badge(
                    isLabelVisible: totalLaporan > 0,
                    label: Text('$totalLaporan'),
                    child: const Icon(Icons.description_outlined),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.riwayatLaporan);
                  },
                  icon: const Icon(Icons.history),
                  label: Text(
                    totalLaporan == 0
                        ? 'Lihat Riwayat Laporan'
                        : 'Lihat Riwayat Laporan '
                              '($totalLaporan)',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

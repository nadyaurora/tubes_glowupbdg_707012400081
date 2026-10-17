import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/riwayat_laporan_cubit.dart';
import '../navigation/app_routes.dart';

class RiwayatLaporan extends StatelessWidget {
  const RiwayatLaporan({super.key});

  void _tampilkanPesan(BuildContext context, String pesan) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(pesan), behavior: SnackBarBehavior.floating),
      );
  }

  Future<void> _bukaForm(BuildContext context) async {
    final berhasil = await Navigator.pushNamed(context, AppRoutes.buatLaporan);

    if (!context.mounted || berhasil != true) {
      return;
    }

    _tampilkanPesan(context, 'Laporan berhasil dikirim.');
  }

  Future<void> _bukaDetail(
    BuildContext context,
    Map<String, String> laporan,
  ) async {
    final hasil = await Navigator.pushNamed(
      context,
      AppRoutes.detailLaporan,
      arguments: Map<String, String>.from(laporan),
    );

    if (!context.mounted || hasil == null) {
      return;
    }

    _tampilkanPesan(context, hasil.toString());
  }

  void _tandaiSelesai(BuildContext context, Map<String, String> laporan) {
    final berubah = context.read<RiwayatLaporanCubit>().tandaiSelesai(laporan);

    _tampilkanPesan(
      context,
      berubah
          ? 'Laporan berhasil ditandai selesai.'
          : 'Laporan sudah berstatus selesai.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Laporan')),
      body: BlocBuilder<RiwayatLaporanCubit, List<Map<String, String>>>(
        builder: (context, daftar) {
          final totalLaporan = daftar.length;

          final totalSelesai = daftar
              .where((laporan) => laporan['status'] == 'Selesai')
              .length;

          final totalBelumSelesai = totalLaporan - totalSelesai;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ketuk kartu untuk membuka rincian. '
                      'Tahan kartu untuk menandai laporan selesai.',
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(label: Text('Total: $totalLaporan')),
                        Chip(label: Text('Belum selesai: $totalBelumSelesai')),
                        Chip(label: Text('Selesai: $totalSelesai')),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: daftar.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'Belum ada riwayat laporan.\n'
                            'Tekan tombol + untuk membuat laporan baru.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                        itemCount: daftar.length,
                        separatorBuilder: (context, index) {
                          return const SizedBox(height: 12);
                        },
                        itemBuilder: (context, index) {
                          final laporan = daftar[index];
                          final selesai = laporan['status'] == 'Selesai';

                          return GestureDetector(
                            onTap: () {
                              _bukaDetail(context, laporan);
                            },
                            onLongPress: () {
                              _tandaiSelesai(context, laporan);
                            },
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            laporan['judul'] ?? 'Laporan',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          tooltip: 'Hapus dari riwayat',
                                          onPressed: () {
                                            context
                                                .read<RiwayatLaporanCubit>()
                                                .hapusLaporan(laporan);
                                          },
                                          icon: const Icon(
                                            Icons.delete_outline,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(laporan['lokasi'] ?? '-'),
                                    const SizedBox(height: 8),
                                    Text(laporan['deskripsi'] ?? '-'),
                                    const SizedBox(height: 12),
                                    Chip(
                                      avatar: Icon(
                                        selesai
                                            ? Icons.check_circle_outline
                                            : Icons.schedule,
                                        size: 18,
                                      ),
                                      label: Text(laporan['status'] ?? '-'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Buat Laporan',
        onPressed: () => _bukaForm(context),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              tooltip: 'Beranda',
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              icon: const Icon(Icons.home_outlined),
            ),
            IconButton(
              tooltip: 'Ringkasan laporan',
              onPressed: () {
                final jumlah = context
                    .read<RiwayatLaporanCubit>()
                    .totalBelumSelesai;

                _tampilkanPesan(
                  context,
                  'Anda memiliki $jumlah laporan '
                  'yang belum selesai.',
                );
              },
              icon: const Icon(Icons.notifications_none),
            ),
            const SizedBox(width: 48),
            IconButton(
              tooltip: 'Pengaturan',
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.pengaturan);
              },
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
        ),
      ),
    );
  }
}

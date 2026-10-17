import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/form_laporan_cubit.dart';
import '../cubit/riwayat_laporan_cubit.dart';

class PratinjauLaporan extends StatefulWidget {
  const PratinjauLaporan({super.key});

  @override
  State<PratinjauLaporan> createState() => _PratinjauLaporanState();
}

class _PratinjauLaporanState extends State<PratinjauLaporan> {
  bool _sedangMengirim = false;

  Future<void> _kirimLaporan() async {
    if (_sedangMengirim) {
      return;
    }

    final formCubit = context.read<FormLaporanCubit>();
    final riwayatCubit = context.read<RiwayatLaporanCubit>();
    final form = formCubit.state;

    if (!form.formLengkap) {
      return;
    }

    final laporan = form.dataLaporan;

    try {
      if (riwayatCubit.sudahTersimpan(laporan)) {
        throw StateError(
          'Laporan dengan judul dan lokasi yang sama '
          'sudah tersimpan.',
        );
      }

      setState(() {
        _sedangMengirim = true;
      });

      await Future<void>.delayed(const Duration(seconds: 2));

      if (!mounted) {
        return;
      }

      if (ModalRoute.of(context)?.isCurrent != true) {
        return;
      }

      if (riwayatCubit.sudahTersimpan(laporan)) {
        throw StateError(
          'Laporan dengan judul dan lokasi yang sama '
          'sudah tersimpan.',
        );
      }

      riwayatCubit.tambahLaporan(laporan);
      formCubit.kosongkanForm();

      setState(() {
        _sedangMengirim = false;
      });

      Navigator.pop(context, true);
    } on StateError catch (galat) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(galat.message)));
    } finally {
      if (mounted && _sedangMengirim) {
        setState(() {
          _sedangMengirim = false;
        });
      }
    }
  }

  Widget _rincian(String label, String nilai) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(nilai.trim().isEmpty ? 'Belum diisi' : nilai.trim()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FormLaporanCubit, FormLaporanState>(
      builder: (context, form) {
        return PopScope(
          canPop: !_sedangMengirim,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Pratinjau Laporan'),
              leading: IconButton(
                tooltip: 'Kembali',
                icon: const Icon(Icons.arrow_back),
                onPressed: _sedangMengirim
                    ? null
                    : () => Navigator.pop(context),
              ),
            ),
            body: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      const Text(
                        'Periksa kembali informasi berikut sebelum '
                        'mengirim laporan.',
                      ),
                      const SizedBox(height: 20),

                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _rincian('Judul laporan', form.judul),
                              _rincian('Lokasi kejadian', form.lokasi),
                              _rincian(
                                'Deskripsi permasalahan',
                                form.deskripsi,
                              ),
                              Row(
                                children: [
                                  Icon(
                                    form.setuju
                                        ? Icons.check_circle_outline
                                        : Icons.info_outline,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      form.setuju
                                          ? 'Persetujuan sudah diberikan.'
                                          : 'Persetujuan belum diberikan.',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      ElevatedButton(
                        onPressed: form.formLengkap && !_sedangMengirim
                            ? _kirimLaporan
                            : null,
                        child: _sedangMengirim
                            ? const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text('Sedang mengirim...'),
                                ],
                              )
                            : const Text('Kirim Laporan'),
                      ),

                      TextButton(
                        onPressed: _sedangMengirim
                            ? null
                            : () => Navigator.pop(context),
                        child: const Text('Kembali untuk Mengubah'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

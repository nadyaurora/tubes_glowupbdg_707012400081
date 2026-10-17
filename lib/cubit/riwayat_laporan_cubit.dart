import 'package:flutter_bloc/flutter_bloc.dart';

class RiwayatLaporanCubit extends Cubit<List<Map<String, String>>> {
  RiwayatLaporanCubit() : super(const <Map<String, String>>[]);

  List<Map<String, String>> get daftarLaporan => state;

  int get totalLaporan => state.length;

  int get totalSelesai {
    return state.where((laporan) => laporan['status'] == 'Selesai').length;
  }

  int get totalBelumSelesai => totalLaporan - totalSelesai;

  bool sudahTersimpan(Map<String, String> laporan) {
    return state.any(
      (item) =>
          item['judul'] == laporan['judul'] &&
          item['lokasi'] == laporan['lokasi'],
    );
  }

  void tambahLaporan(Map<String, String> laporan) {
    if (sudahTersimpan(laporan)) {
      return;
    }

    final dataBaru = Map<String, String>.unmodifiable({
      ...laporan,
      'status': laporan['status'] ?? 'Dikonfirmasi',
    });

    emit(List<Map<String, String>>.unmodifiable([...state, dataBaru]));
  }

  bool tandaiSelesai(Map<String, String> laporan) {
    final indeks = state.indexWhere(
      (item) =>
          item['judul'] == laporan['judul'] &&
          item['lokasi'] == laporan['lokasi'],
    );

    if (indeks == -1 || state[indeks]['status'] == 'Selesai') {
      return false;
    }

    final daftarBaru = [...state];

    daftarBaru[indeks] = Map<String, String>.unmodifiable({
      ...state[indeks],
      'status': 'Selesai',
    });

    emit(List<Map<String, String>>.unmodifiable(daftarBaru));

    return true;
  }

  void hapusLaporan(Map<String, String> laporan) {
    final daftarBaru = state
        .where(
          (item) =>
              item['judul'] != laporan['judul'] ||
              item['lokasi'] != laporan['lokasi'],
        )
        .toList();

    if (daftarBaru.length == state.length) {
      return;
    }

    emit(List<Map<String, String>>.unmodifiable(daftarBaru));
  }

  void kosongkan() {
    if (state.isEmpty) {
      return;
    }

    emit(const <Map<String, String>>[]);
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';

class FormLaporanState {
  const FormLaporanState({
    this.judul = '',
    this.lokasi = '',
    this.deskripsi = '',
    this.setuju = false,
  });

  final String judul;
  final String lokasi;
  final String deskripsi;
  final bool setuju;

  bool get formLengkap {
    return judul.trim().isNotEmpty &&
        lokasi.trim().isNotEmpty &&
        deskripsi.trim().isNotEmpty &&
        setuju;
  }

  Map<String, String> get dataLaporan {
    return Map<String, String>.unmodifiable({
      'judul': judul.trim(),
      'lokasi': lokasi.trim(),
      'deskripsi': deskripsi.trim(),
      'status': 'Menunggu',
    });
  }

  FormLaporanState copyWith({
    String? judul,
    String? lokasi,
    String? deskripsi,
    bool? setuju,
  }) {
    return FormLaporanState(
      judul: judul ?? this.judul,
      lokasi: lokasi ?? this.lokasi,
      deskripsi: deskripsi ?? this.deskripsi,
      setuju: setuju ?? this.setuju,
    );
  }
}

class FormLaporanCubit extends Cubit<FormLaporanState> {
  FormLaporanCubit() : super(const FormLaporanState());

  void ubahJudul(String nilai) {
    if (nilai == state.judul) {
      return;
    }

    emit(state.copyWith(judul: nilai));
  }

  void ubahLokasi(String nilai) {
    if (nilai == state.lokasi) {
      return;
    }

    emit(state.copyWith(lokasi: nilai));
  }

  void ubahDeskripsi(String nilai) {
    if (nilai == state.deskripsi) {
      return;
    }

    emit(state.copyWith(deskripsi: nilai));
  }

  void ubahPersetujuan(bool nilai) {
    if (nilai == state.setuju) {
      return;
    }

    emit(state.copyWith(setuju: nilai));
  }

  void kosongkanForm() {
    if (state.judul.isEmpty &&
        state.lokasi.isEmpty &&
        state.deskripsi.isEmpty &&
        !state.setuju) {
      return;
    }

    emit(const FormLaporanState());
  }
}

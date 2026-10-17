import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tubes_glowupbandung_707012400107/cubit/form_laporan_cubit.dart';
import 'package:tubes_glowupbandung_707012400107/cubit/riwayat_laporan_cubit.dart';
import 'package:tubes_glowupbandung_707012400107/main.dart';
import 'package:tubes_glowupbandung_707012400107/navigation/app_routes.dart';
import 'package:tubes_glowupbandung_707012400107/pages/laporan.dart';
import 'package:tubes_glowupbandung_707012400107/pages/profil.dart';

Future<NavigatorState> _bukaAplikasi(WidgetTester tester) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(1000, 1200);

  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);

  await tester.pumpWidget(const AplikasiGlowUpBandung());
  await tester.pumpAndSettle();

  expect(tester.takeException(), isNull);

  return tester.state<NavigatorState>(find.byType(Navigator).first);
}

ButtonStyleButton _bacaTombol(WidgetTester tester, String label) {
  return tester.widget<ButtonStyleButton>(
    find
        .ancestor(
          of: find.text(label),
          matching: find.byWidgetPredicate(
            (widget) => widget is ButtonStyleButton,
          ),
        )
        .first,
  );
}

Future<void> _isiForm(
  WidgetTester tester, {
  required String judul,
  required String lokasi,
  required String deskripsi,
}) async {
  await tester.enterText(find.byType(TextField).at(0), judul);
  await tester.enterText(find.byType(TextField).at(1), lokasi);
  await tester.enterText(find.byType(TextField).at(2), deskripsi);
  await tester.pump();
}

void main() {
  testWidgets('Konfirmasi, status selesai, dan penghapusan '
      'memperbarui halaman yang berbagi Cubit', (tester) async {
    final navigator = await _bukaAplikasi(tester);
    final riwayat = navigator.context.read<RiwayatLaporanCubit>();

    const judul = 'Tumpukan sampah di Jalan Braga';

    // Memakai halaman asli melalui navigator aplikasi.
    unawaited(
      navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => const Scaffold(body: Laporan()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(riwayat.totalLaporan, 0);
    expect(find.text('Tersimpan di riwayat'), findsNothing);

    await tester.tap(find.text(judul));
    await tester.pumpAndSettle();

    expect(find.text('Detail Laporan'), findsOneWidget);

    await tester.tap(find.text('Konfirmasi Laporan'));
    await tester.pump();

    expect(find.text('Memproses...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(_bacaTombol(tester, 'Memproses...').onPressed, isNull);
    expect(riwayat.totalLaporan, 0);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(riwayat.totalLaporan, 1);
    expect(find.text('Tersimpan di riwayat'), findsOneWidget);

    // Laporan yang sudah tersimpan tidak dapat dikonfirmasi ulang.
    await tester.tap(find.text(judul));
    await tester.pumpAndSettle();

    expect(find.text('Laporan sudah tersimpan'), findsOneWidget);
    expect(_bacaTombol(tester, 'Sudah Dikonfirmasi').onPressed, isNull);

    navigator.pop();
    await tester.pumpAndSettle();

    unawaited(navigator.pushNamed(AppRoutes.riwayatLaporan));
    await tester.pumpAndSettle();

    expect(find.text('Total: 1'), findsOneWidget);
    expect(find.text('Belum selesai: 1'), findsOneWidget);
    expect(find.text('Selesai: 0'), findsOneWidget);

    await tester.longPress(find.text(judul));
    await tester.pumpAndSettle();

    expect(find.text('Belum selesai: 0'), findsOneWidget);
    expect(find.text('Selesai: 1'), findsOneWidget);

    // Detail harus menampilkan status terbaru dari Cubit.
    await tester.tap(find.text(judul));
    await tester.pumpAndSettle();

    expect(find.text('Status'), findsOneWidget);
    expect(find.text('Selesai'), findsOneWidget);

    navigator.pop();
    await tester.pumpAndSettle();

    navigator.pop();
    await tester.pumpAndSettle();

    unawaited(
      navigator.push(
        MaterialPageRoute<void>(builder: (_) => const Scaffold(body: Profil())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Lihat Riwayat Laporan (1)'), findsOneWidget);
    expect(
      tester
          .widget<Badge>(
            find.descendant(
              of: find.byType(Profil),
              matching: find.byType(Badge),
            ),
          )
          .isLabelVisible,
      isTrue,
    );

    await tester.tap(find.text('Lihat Riwayat Laporan (1)'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Hapus dari riwayat'));
    await tester.pumpAndSettle();

    expect(riwayat.totalLaporan, 0);
    expect(find.text('Total: 0'), findsOneWidget);
    expect(
      find.text(
        'Belum ada riwayat laporan.\n'
        'Tekan tombol + untuk membuat laporan baru.',
      ),
      findsOneWidget,
    );

    navigator.pop();
    await tester.pumpAndSettle();

    expect(find.text('Lihat Riwayat Laporan'), findsOneWidget);
    expect(
      tester
          .widget<Badge>(
            find.descendant(
              of: find.byType(Profil),
              matching: find.byType(Badge),
            ),
          )
          .isLabelVisible,
      isFalse,
    );

    navigator.pop();
    await tester.pumpAndSettle();

    expect(find.text('Tersimpan di riwayat'), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('Form dan pratinjau berbagi draft, menampilkan proses lokal, '
      'serta menolak laporan duplikat', (tester) async {
    final navigator = await _bukaAplikasi(tester);
    final form = navigator.context.read<FormLaporanCubit>();
    final riwayat = navigator.context.read<RiwayatLaporanCubit>();

    const judul = 'Sampah di Jalan Merdeka';
    const lokasi = 'Jalan Merdeka, Bandung';
    const deskripsi = 'Sampah menumpuk dan mengganggu pejalan kaki.';
    const deskripsiBaru = 'Sampah menumpuk sejak pagi dan menghalangi trotoar.';

    unawaited(navigator.pushNamed(AppRoutes.riwayatLaporan));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Buat Laporan'));
    await tester.pumpAndSettle();

    expect(find.text('Laporan tersimpan: 0'), findsOneWidget);
    expect(_bacaTombol(tester, 'Pratinjau Laporan').onPressed, isNull);

    await _isiForm(tester, judul: judul, lokasi: lokasi, deskripsi: deskripsi);

    // Persetujuan tetap menjadi syarat kelengkapan formulir.
    expect(_bacaTombol(tester, 'Pratinjau Laporan').onPressed, isNull);

    await tester.tap(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();

    expect(form.state.formLengkap, isTrue);
    expect(_bacaTombol(tester, 'Pratinjau Laporan').onPressed, isNotNull);

    await tester.tap(find.text('Pratinjau Laporan'));
    await tester.pumpAndSettle();

    expect(find.text(judul), findsOneWidget);
    expect(find.text(lokasi), findsOneWidget);
    expect(find.text(deskripsi), findsOneWidget);

    await tester.tap(find.text('Kembali untuk Mengubah'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<TextField>(find.byType(TextField).at(0)).controller!.text,
      judul,
    );

    await tester.enterText(find.byType(TextField).at(2), deskripsiBaru);
    await tester.pump();

    await tester.tap(find.text('Pratinjau Laporan'));
    await tester.pumpAndSettle();

    expect(find.text(deskripsiBaru), findsOneWidget);

    await tester.tap(find.text('Kirim Laporan'));
    await tester.pump();

    expect(find.text('Sedang mengirim...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(_bacaTombol(tester, 'Sedang mengirim...').onPressed, isNull);
    expect(_bacaTombol(tester, 'Kembali untuk Mengubah').onPressed, isNull);
    expect(riwayat.totalLaporan, 0);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Riwayat Laporan'), findsOneWidget);
    expect(find.text('Total: 1'), findsOneWidget);
    expect(find.text(judul), findsOneWidget);
    expect(find.text('Menunggu'), findsOneWidget);
    expect(riwayat.totalLaporan, 1);
    expect(form.state.judul, isEmpty);
    expect(form.state.setuju, isFalse);

    // Judul dan lokasi yang sama harus menghasilkan penolakan.
    await tester.tap(find.byTooltip('Buat Laporan'));
    await tester.pumpAndSettle();

    expect(find.text('Laporan tersimpan: 1'), findsOneWidget);

    await _isiForm(
      tester,
      judul: judul,
      lokasi: lokasi,
      deskripsi: 'Laporan yang sama dikirim kembali.',
    );
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pratinjau Laporan'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Kirim Laporan'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Laporan dengan judul dan lokasi yang sama '
        'sudah tersimpan.',
      ),
      findsOneWidget,
    );
    expect(riwayat.totalLaporan, 1);
    expect(form.state.judul, judul);
    expect(find.text('Sedang mengirim...'), findsNothing);
    expect(_bacaTombol(tester, 'Kirim Laporan').onPressed, isNotNull);

    // Mengosongkan Cubit harus ikut membersihkan isian.
    await tester.tap(find.text('Kembali untuk Mengubah'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Kosongkan Formulir'));
    await tester.pumpAndSettle();

    for (final field in tester.widgetList<TextField>(find.byType(TextField))) {
      expect(field.controller!.text, isEmpty);
    }

    expect(form.state.formLengkap, isFalse);
    expect(_bacaTombol(tester, 'Pratinjau Laporan').onPressed, isNull);
    expect(riwayat.totalLaporan, 1);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}

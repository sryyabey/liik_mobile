// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get loginTitle => 'Masuk';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Kata sandi';

  @override
  String get facebookLogin => 'Lanjutkan dengan Facebook';

  @override
  String get googleLogin => 'Lanjutkan dengan Google';

  @override
  String get onboardTitle1 => 'Dunia Anda.\nSatu tautan.';

  @override
  String get onboardDesc1 =>
      'Satukan tautan, layanan, dan semua hal tentang Anda di halaman Liik Anda.';

  @override
  String get onboardTitle2 => 'Janji temu berikutnya.\nCukup satu ketukan.';

  @override
  String get onboardDesc2 =>
      'Bagikan waktu tersedia Anda. Biarkan pengunjung memilih waktu yang cocok, sementara Anda fokus menjalani hari.';

  @override
  String get onboardTitle3 => 'Tampilkan diri Anda.\nBangun koneksi.';

  @override
  String get onboardDesc3 =>
      'Buat halaman yang mencerminkan diri Anda, bagikan tautan bio, dan terhubung dengan orang baru.';

  @override
  String get menuTitle => 'Menu';

  @override
  String get myLinks => 'Tautan saya';

  @override
  String get customersTitle => 'Kontak saya';

  @override
  String get customersSessionMissing =>
      'Sesi tidak ditemukan. Silakan masuk lagi.';

  @override
  String customersLoadFailedStatus(Object status) {
    return 'Kontak tidak dapat dimuat (HTTP $status).';
  }

  @override
  String customersLoadFailed(Object error) {
    return 'Kontak tidak dapat dimuat: $error';
  }

  @override
  String get customersSearchHint => 'Cari kontak (nama, telepon, email)';

  @override
  String get customersRetry => 'Coba lagi';

  @override
  String get customersEmpty => 'Belum ada kontak.';

  @override
  String get customersLoadMore => 'Muat lebih banyak';

  @override
  String get customersRefresh => 'Muat ulang';

  @override
  String get customersAdd => 'Tambah kontak';

  @override
  String get customersEdit => 'Edit kontak';

  @override
  String get customersAddSubtitle => 'Tambah kontak baru';

  @override
  String get customersEditSubtitle => 'Edit detail kontak';

  @override
  String get customersDelete => 'Hapus';

  @override
  String get customersDeleteConfirmTitle => 'Hapus kontak?';

  @override
  String get customersDeleteConfirmBody => 'Yakin ingin menghapus kontak ini?';

  @override
  String get customersCancel => 'Batal';

  @override
  String get customersSave => 'Simpan';

  @override
  String get customersSaving => 'Menyimpan...';

  @override
  String get customersName => 'Nama lengkap';

  @override
  String get customersPhone => 'Telepon';

  @override
  String get customersEmail => 'Email';

  @override
  String get customersAddress => 'Alamat';

  @override
  String get customersNotes => 'Catatan';

  @override
  String get customersValidation => 'Nama lengkap dan telepon wajib diisi.';

  @override
  String get customersCreateSuccess => 'Kontak berhasil dibuat.';

  @override
  String get customersUpdateSuccess => 'Kontak berhasil diperbarui.';

  @override
  String customersSaveFailedStatus(Object status) {
    return 'Tidak dapat disimpan (HTTP $status).';
  }

  @override
  String customersSaveFailed(Object error) {
    return 'Tidak dapat disimpan: $error';
  }

  @override
  String get customersDeleteSuccess => 'Kontak berhasil dihapus.';

  @override
  String customersDeleteFailedStatus(Object status) {
    return 'Kontak tidak dapat dihapus (HTTP $status).';
  }

  @override
  String customersDeleteFailed(Object error) {
    return 'Kontak tidak dapat dihapus: $error';
  }

  @override
  String get customersAppointments => 'Janji temu';

  @override
  String get customersNoAppointments =>
      'Tidak ada janji temu untuk kontak ini.';

  @override
  String customersAppointmentsLoadFailedStatus(Object status) {
    return 'Janji temu tidak dapat dimuat (HTTP $status).';
  }

  @override
  String customersAppointmentsLoadFailed(Object error) {
    return 'Janji temu tidak dapat dimuat: $error';
  }

  @override
  String get customersCreateAppointment => 'Tambah janji temu';

  @override
  String get customersAppointmentDate => 'Tanggal';

  @override
  String get customersAppointmentTime => 'Waktu';

  @override
  String get customersAppointmentNote => 'Catatan';

  @override
  String get customersAppointmentNoteHint => 'Tambahkan catatan janji temu...';

  @override
  String customersEmptyForLetter(Object letter) {
    return 'Tidak ditemukan kontak yang diawali dengan \"$letter\".';
  }

  @override
  String get customersFirstAppointment => 'Janji temu pertama?';

  @override
  String get customersNoSms => 'Jangan kirim SMS';

  @override
  String get customersNoReminder => 'Jangan kirim pengingat';

  @override
  String get customersCreateAppointmentSuccess => 'Janji temu berhasil dibuat.';

  @override
  String get customersCreateAppointmentFailed =>
      'Janji temu tidak dapat dibuat.';

  @override
  String get themes => 'Tema';

  @override
  String get profile => 'Profil';

  @override
  String get support => 'Bantuan';

  @override
  String get exit => 'Keluar';

  @override
  String get loginButton => 'Masuk';

  @override
  String get dashboardTitle => 'Panel admin';

  @override
  String get dashboardHeroSubtitle =>
      'Kelola tautan dan janji temu Anda di satu tempat.';

  @override
  String get dashboardQuickActions => 'Tindakan cepat';

  @override
  String get dashboardMenuMain => 'MENU UTAMA';

  @override
  String get dashboardMenuManagement => 'PENGELOLAAN';

  @override
  String get dashboardDrawerSubtitle =>
      'Kelola janji temu dan kontak Anda di sini';

  @override
  String get dashboardTopClicks => 'Total klik';

  @override
  String get dashboardRemainingSms => 'Sisa SMS';

  @override
  String get dashboardBioPage => 'Halaman bio Anda';

  @override
  String get dashboardLinkCopied => 'Tautan disalin.';

  @override
  String get dashboardShare => 'Bagikan';

  @override
  String get dashboardDownload => 'Unduh';

  @override
  String get dashboardQr => 'QR';

  @override
  String get dashboardPackageInfo => 'Info paket';

  @override
  String get dashboardPackageName => 'Nama paket';

  @override
  String get dashboardStart => 'Mulai';

  @override
  String get dashboardEnd => 'Selesai';

  @override
  String get dashboardDailyClicks => 'Klik harian';

  @override
  String get dashboardTopLinks => 'Tautan paling banyak diklik';

  @override
  String get dashboardNoClicks => 'Belum ada data klik.';

  @override
  String get dashboardNoLinkClicks => 'Belum ada klik tautan.';

  @override
  String get dashboardTodayAppointments => 'Janji temu hari ini';

  @override
  String dashboardTodayCount(Object count) {
    return '$count hari ini';
  }

  @override
  String get dashboardNoAppointmentsData =>
      'Tidak ada data janji temu hari ini.';

  @override
  String get dashboardNoAppointments => 'Tidak ada janji temu hari ini.';

  @override
  String dashboardCustomerFallback(Object id) {
    return 'Pelanggan #$id';
  }

  @override
  String get dashboardCalendar => 'Kalender';

  @override
  String get dashboardAppointments => 'Janji temu';

  @override
  String get dashboardHome => 'Beranda';

  @override
  String get dashboardWeeklyCalendar => 'Kalender mingguan';

  @override
  String get dashboardSmsPacks => 'Paket SMS';

  @override
  String get dashboardOrders => 'Pesanan';

  @override
  String get dashboardWorkingHours => 'Jam kerja';

  @override
  String get dashboardSmsTemplates => 'Templat SMS';

  @override
  String get dashboardRetry => 'Coba lagi';

  @override
  String get dashboardNoInternet => 'Periksa koneksi internet Anda.';

  @override
  String get dashboardSessionMissing =>
      'Sesi tidak ditemukan. Silakan masuk lagi.';

  @override
  String dashboardLoadFailedWithStatus(Object status) {
    return 'Dasbor tidak dapat dimuat (HTTP $status).';
  }

  @override
  String dashboardLoadFailed(Object error) {
    return 'Dasbor tidak dapat dimuat: $error';
  }

  @override
  String get dashboardQrTitle => 'QR tautan bio';

  @override
  String dashboardShareFailed(Object error) {
    return 'Gagal membagikan: $error';
  }

  @override
  String dashboardQrDownloadFailed(Object error) {
    return 'QR tidak dapat diunduh: $error';
  }

  @override
  String get dashboardLinkOpenFailed => 'Tautan tidak dapat dibuka.';

  @override
  String get dashboardWhatsAppFailed => 'WhatsApp tidak dapat dibuka.';

  @override
  String dashboardWhatsAppFailedWithError(Object error) {
    return 'WhatsApp tidak dapat dibuka: $error';
  }

  @override
  String get dashboardShareBio => 'Tautan bio Liik';

  @override
  String get dashboardWhatsappSupport => 'Bantuan WhatsApp';

  @override
  String get appointmentManagement => 'Pengelolaan janji temu';

  @override
  String get appointmentSubtitle =>
      'Pantau janji temu harian dan buat yang baru dengan cepat.';

  @override
  String get refresh => 'Muat ulang';

  @override
  String get today => 'Hari ini';

  @override
  String get total => 'Total';

  @override
  String get quickAppointment => 'Tambah janji temu';

  @override
  String get showFilter => 'Filter';

  @override
  String get hideFilter => 'Sembunyikan filter';

  @override
  String get refreshList => 'Muat ulang daftar';

  @override
  String get statusPending => 'Menunggu';

  @override
  String get statusConfirmed => 'Dikonfirmasi';

  @override
  String get statusRescheduled => 'Dijadwalkan ulang';

  @override
  String get statusCompleted => 'Selesai';

  @override
  String get statusCancelled => 'Dibatalkan';

  @override
  String get statusNoShow => 'Tidak hadir';

  @override
  String get customerPreview => 'Pratinjau pelanggan';

  @override
  String get recentAppointments => 'Janji temu terbaru';

  @override
  String get reschedule => 'Jadwalkan ulang';

  @override
  String get date => 'Tanggal';

  @override
  String get timeSelect => 'Waktu (pilih)';

  @override
  String get note => 'Catatan';

  @override
  String get disableSms => 'Nonaktifkan SMS';

  @override
  String get smsOffForAppointment => 'SMS dinonaktifkan untuk janji temu ini.';

  @override
  String get disableReminder => 'Nonaktifkan pengingat';

  @override
  String get reminderOffForAppointment =>
      'Notifikasi pengingat dinonaktifkan untuk janji temu ini.';

  @override
  String get rescheduleAppointment => 'Jadwalkan ulang janji temu';

  @override
  String get editAppointment => 'Edit janji temu';

  @override
  String get status => 'Status';

  @override
  String get save => 'Simpan';

  @override
  String get quickAppointmentTitle => 'Tambah janji temu';

  @override
  String get quickAppointmentSubtitle =>
      'Isi info pelanggan dan janji temu di satu layar lalu simpan dengan cepat.';

  @override
  String get customerInfo => 'Info pelanggan';

  @override
  String get appointmentInfo => 'Info janji temu';

  @override
  String get getAvailableTimes => 'Lihat waktu tersedia';

  @override
  String get setWorkingHours => 'Atur jam kerja';

  @override
  String get sendSms => 'Kirim SMS';

  @override
  String get doNotSendSms => 'Jangan kirim SMS';

  @override
  String get sendReminder => 'Kirim pengingat';

  @override
  String get doNotSendReminder => 'Jangan kirim pengingat';

  @override
  String get googleLoginButton => 'Masuk dengan Google';

  @override
  String get googleConnecting => 'Menghubungkan...';

  @override
  String get createAccountEmail => 'Buat akun dengan email';

  @override
  String get appointmentsTitle => 'Janji temu';

  @override
  String get appointmentsEmpty => 'Belum ada janji temu.';

  @override
  String appointmentsCountLabel(Object count) {
    return '$count catatan';
  }

  @override
  String get appointmentsFilterSubtitle =>
      'Filter berdasarkan pelanggan, tanggal, dan rentang waktu';

  @override
  String get appointmentsPackageRequired =>
      'Paket atau langganan aktif diperlukan untuk mengelola janji temu. Saldo SMS hanya digunakan saat SMS atau pengingat benar-benar dikirim.';

  @override
  String get appointmentsSessionMissingLogin =>
      'Sesi tidak ditemukan. Silakan masuk lagi.';

  @override
  String appointmentsCountriesFetchFailedStatus(Object status) {
    return 'Negara tidak dapat dimuat (HTTP $status).';
  }

  @override
  String appointmentsCountriesFetchFailed(Object error) {
    return 'Negara tidak dapat dimuat: $error';
  }

  @override
  String appointmentsStatusesFetchFailedStatus(Object status) {
    return 'Status tidak dapat dimuat (HTTP $status).';
  }

  @override
  String appointmentsStatusesFetchFailed(Object error) {
    return 'Status tidak dapat dimuat: $error';
  }

  @override
  String get appointmentsInvalidStartTime =>
      'Waktu mulai tidak valid. Format HH:MM';

  @override
  String get appointmentsInvalidEndTime =>
      'Waktu selesai tidak valid. Format HH:MM';

  @override
  String get appointmentsRequiredFields =>
      'Nama depan, nama belakang, negara, telepon, tanggal, dan waktu wajib diisi.';

  @override
  String get appointmentsSelectAvailableTime => 'Pilih waktu yang tersedia.';

  @override
  String get appointmentsCreateSuccess => 'Janji temu berhasil dibuat.';

  @override
  String appointmentsCreateFailedStatus(Object status) {
    return 'Janji temu tidak dapat dibuat (HTTP $status).';
  }

  @override
  String appointmentsCreateFailed(Object error) {
    return 'Janji temu tidak dapat dibuat: $error';
  }

  @override
  String get appointmentsEnterDateFirst => 'Masukkan tanggal terlebih dahulu.';

  @override
  String appointmentsSlotsFetchFailedStatus(Object status) {
    return 'Slot waktu tidak dapat dimuat (HTTP $status).';
  }

  @override
  String appointmentsSlotsFetchFailed(Object error) {
    return 'Slot waktu tidak dapat dimuat: $error';
  }

  @override
  String get appointmentsDateTimeRequired => 'Tanggal dan waktu wajib diisi.';

  @override
  String get appointmentsUpdateSuccess => 'Janji temu berhasil diperbarui.';

  @override
  String appointmentsUpdateFailedStatus(Object status) {
    return 'Janji temu tidak dapat diperbarui (HTTP $status).';
  }

  @override
  String appointmentsUpdateFailed(Object error) {
    return 'Janji temu tidak dapat diperbarui: $error';
  }

  @override
  String get appointmentsStatusMissing => 'Status janji temu tidak ditemukan.';

  @override
  String get appointmentsRebookSuccess => 'Janji temu baru berhasil dibuat.';

  @override
  String get appointmentsInfoMissing => 'Info janji temu tidak ditemukan.';

  @override
  String appointmentsInfoFetchFailedStatus(Object status) {
    return 'Informasi tidak dapat dimuat (HTTP $status).';
  }

  @override
  String appointmentsInfoFetchFailed(Object error) {
    return 'Informasi tidak dapat dimuat: $error';
  }

  @override
  String get appointmentsNoRecords => 'Tidak ada catatan ditemukan.';

  @override
  String get appointmentsClose => 'Tutup';

  @override
  String get appointmentsClear => 'Bersihkan';

  @override
  String get appointmentsCountry => 'Negara';

  @override
  String get appointmentsSelectCountry => 'Pilih negara';

  @override
  String get appointmentsFieldName => 'Nama';

  @override
  String get appointmentsFieldNameHint => 'mis. Alex';

  @override
  String get appointmentsFieldLastName => 'Nama belakang';

  @override
  String get appointmentsFieldLastNameHint => 'mis. Wijaya';

  @override
  String get appointmentsFieldNameFilterHint => 'Nama pelanggan';

  @override
  String get appointmentsFieldLastNameFilterHint => 'Nama belakang pelanggan';

  @override
  String get appointmentsFieldPhone => 'Telepon';

  @override
  String get appointmentsFieldPhoneHint => 'mis. 81234567890';

  @override
  String get appointmentsFieldEmailHint => 'Opsional';

  @override
  String get appointmentsStatusSelectHint => 'Pilih status';

  @override
  String get appointmentsStartDate => 'Tanggal mulai';

  @override
  String get appointmentsEndDate => 'Tanggal selesai';

  @override
  String get appointmentsStartTime => 'Waktu mulai';

  @override
  String get appointmentsEndTime => 'Waktu selesai';

  @override
  String get appointmentsBuyPackage => 'Beli paket';

  @override
  String get appointmentsFirstAppointment => 'Apakah ini janji temu pertama?';

  @override
  String get appointmentsReminderDisableTitle => 'Jangan kirim pengingat';

  @override
  String get appointmentsSubmitting => 'Mengirim...';

  @override
  String get appointmentsCustomerPreviewTooltip => 'Pratinjau pelanggan';

  @override
  String get appointmentsRebookTooltip => 'Buat janji temu lagi';

  @override
  String get appointmentsEditTooltip => 'Edit';

  @override
  String get appointmentsHomeTooltip => 'Beranda';

  @override
  String get iosSmsPurchaseRestrictionMessage =>
      'Pembelian paket SMS tidak tersedia di aplikasi iOS karena kebijakan Apple App Store.\nPembelian dapat dilakukan di situs web.';

  @override
  String appointmentsFetchFailedStatus(Object status) {
    return 'Janji temu tidak dapat dimuat (HTTP $status).';
  }

  @override
  String appointmentsFetchFailed(Object error) {
    return 'Janji temu tidak dapat dimuat: $error';
  }

  @override
  String get calendarSessionMissing => 'Sesi tidak ditemukan.';

  @override
  String calendarFetchFailedStatus(Object status) {
    return 'Kalender mingguan tidak dapat dimuat (HTTP $status).';
  }

  @override
  String calendarFetchFailed(Object error) {
    return 'Kalender mingguan tidak dapat dimuat: $error';
  }

  @override
  String get calendarUnexpected => 'Format respons tidak sesuai.';

  @override
  String get calendarClosed => 'Tutup';

  @override
  String get calendarCustomer => 'Pelanggan';

  @override
  String get calendarWorkingHoursPrompt => 'Atur jam kerja Anda.';

  @override
  String get calendarWorkingHoursButton => 'Atur jam kerja';

  @override
  String get calendarSessionExpired => 'Sesi berakhir. Silakan masuk lagi.';

  @override
  String get calendarTitle => 'Kalender mingguan';

  @override
  String get calendarPrev => 'Sebelumnya';

  @override
  String get calendarToday => 'Hari ini';

  @override
  String get calendarNext => 'Berikutnya';

  @override
  String get calendarLoading => 'Memuat...';

  @override
  String get calendarNoData => 'Tidak ada data minggu ini.';

  @override
  String calendarSlotsFilled(Object booked, Object total) {
    return '$booked/$total slot terisi';
  }

  @override
  String get calendarAddAppointment => 'Tambah janji temu';

  @override
  String get calendarGuideTitle => 'Panduan';

  @override
  String get calendarPerson => 'Orang';

  @override
  String get calendarExistingPerson => 'Kontak yang ada';

  @override
  String get calendarNewPerson => 'Kontak baru';

  @override
  String get calendarSelectPerson => 'Pilih kontak';

  @override
  String get calendarDateTimeSection => 'Tanggal & waktu';

  @override
  String get calendarNoteHint => 'Tambahkan catatan...';

  @override
  String get calendarSlotBusy => 'Slot waktu yang dipilih sudah penuh.';

  @override
  String get appointmentsConsecutiveSlotsUnavailable =>
      'Tidak ada slot tersedia yang berurutan. Pilih waktu lain.';

  @override
  String get commonForbiddenAction =>
      'Anda tidak memiliki izin untuk tindakan ini.';

  @override
  String get commonHolidayDateUnavailable =>
      'Tanggal yang dipilih jatuh pada hari libur.';

  @override
  String get calendarCustomerInfoMissing => 'Info kontak tidak ditemukan.';

  @override
  String get calendarAppointmentInfoMissing =>
      'Info janji temu tidak ditemukan.';

  @override
  String get calendarAppointmentStatusMissing =>
      'Status janji temu tidak ditemukan.';

  @override
  String get calendarActionNew => 'Baru';

  @override
  String get calendarActionEdit => 'Edit';

  @override
  String get calendarFetchAvailableSlots => 'Lihat slot tersedia';

  @override
  String get calendarDateHint => 'Pilih dari kalender';

  @override
  String get calendarTimeSlotHint => 'Pilih slot';

  @override
  String get calendarSelectDateFirst => 'Pilih tanggal terlebih dahulu.';

  @override
  String get calendarDateTimeRequired => 'Tanggal dan waktu wajib diisi.';

  @override
  String get calendarCreateSuccess => 'Janji temu baru berhasil dibuat.';

  @override
  String get calendarUpdateSuccess => 'Janji temu berhasil diperbarui.';

  @override
  String get calendarCreateFailed => 'Janji temu tidak dapat dibuat';

  @override
  String get calendarUpdateFailed => 'Janji temu tidak dapat diperbarui';

  @override
  String get dayMonShort => 'Sen';

  @override
  String get dayTueShort => 'Sel';

  @override
  String get dayWedShort => 'Rab';

  @override
  String get dayThuShort => 'Kam';

  @override
  String get dayFriShort => 'Jum';

  @override
  String get daySatShort => 'Sab';

  @override
  String get daySunShort => 'Min';

  @override
  String get dayMonFull => 'Senin';

  @override
  String get dayTueFull => 'Selasa';

  @override
  String get dayWedFull => 'Rabu';

  @override
  String get dayThuFull => 'Kamis';

  @override
  String get dayFriFull => 'Jumat';

  @override
  String get daySatFull => 'Sabtu';

  @override
  String get daySunFull => 'Minggu';

  @override
  String get calendarTimeLabel => 'Waktu';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileSaved => 'Profil disimpan.';

  @override
  String get profileSaveError => 'Profil tidak dapat disimpan.';

  @override
  String get profileSessionMissing =>
      'Sesi tidak ditemukan. Silakan masuk lagi.';

  @override
  String profileFetchFailedStatus(Object status) {
    return 'Profil tidak dapat dimuat (HTTP $status).';
  }

  @override
  String profileFetchFailed(Object error) {
    return 'Profil tidak dapat dimuat: $error';
  }

  @override
  String get profileAvatarTooLarge => 'Foto profil harus kurang dari 3 MB.';

  @override
  String get profileAvatarInvalidFormat => 'Unggah JPG, PNG, atau WEBP.';

  @override
  String profileAvatarPrepareFailed(Object error) {
    return 'Foto profil tidak dapat disiapkan: $error';
  }

  @override
  String get profileUpdateFailedGeneric => 'Pembaruan gagal.';

  @override
  String profileUpdateFailed(Object error) {
    return 'Profil tidak dapat diperbarui: $error';
  }

  @override
  String get profilePasswordMismatch =>
      'Kata sandi baru dan konfirmasi tidak cocok.';

  @override
  String get profilePasswordUpdated => 'Kata sandi diperbarui.';

  @override
  String get profilePasswordUpdateFailed =>
      'Kata sandi tidak dapat diperbarui.';

  @override
  String profilePasswordUpdateFailedWithError(Object error) {
    return 'Kata sandi tidak dapat diperbarui: $error';
  }

  @override
  String get profileAvatarUpload => 'Unggah foto profil';

  @override
  String get profileNameMissing => 'Nama belum diatur';

  @override
  String get profileUsernamePlaceholder => '@pengguna';

  @override
  String get profileInfoTitle => 'Informasi profil';

  @override
  String get profileFieldName => 'Nama';

  @override
  String get profileFieldUsername => 'Nama pengguna';

  @override
  String get profileFieldDescription => 'Deskripsi';

  @override
  String get profileFieldFooter => 'Footer';

  @override
  String get profileSeoSectionTitle => 'SEO';

  @override
  String get profileSeoSubtitle => 'Judul, deskripsi, dan kata kunci';

  @override
  String get profileSeoTitleLabel => 'Judul';

  @override
  String get profileSeoDescriptionLabel => 'Deskripsi';

  @override
  String get profileSeoKeywordsLabel => 'Kata kunci';

  @override
  String get profileSaving => 'Menyimpan...';

  @override
  String get profilePasswordSectionTitle => 'Perbarui kata sandi';

  @override
  String get profilePasswordUpdatedSubtitle => 'Berhasil diperbarui';

  @override
  String get profileCurrentPassword => 'Kata sandi saat ini';

  @override
  String get profileNewPassword => 'Kata sandi baru';

  @override
  String get profileConfirmPassword => 'Konfirmasi kata sandi baru';

  @override
  String get profileChangePasswordSaving => 'Mengirim...';

  @override
  String get profileChangePasswordButton => 'Perbarui kata sandi';

  @override
  String profileSmsCount(Object count) {
    return 'SMS: $count';
  }

  @override
  String get myLinksTitle => 'Tautan saya';

  @override
  String get myLinksNewLink => 'Tautan baru';

  @override
  String get myLinksSearchType => 'Cari jenis tautan';

  @override
  String get myLinksNoResults => 'Tidak ada hasil ditemukan';

  @override
  String get myLinksLinkType => 'Jenis tautan';

  @override
  String get myLinksTypeMissing =>
      'Jenis tautan tidak ditemukan. Periksa pengaturan.';

  @override
  String get myLinksTitleLabel => 'Judul';

  @override
  String get myLinksUrlLabel => 'URL';

  @override
  String get myLinksColorLabel => 'Warna';

  @override
  String get myLinksColorMissing => 'Daftar warna tidak ditemukan.';

  @override
  String get myLinksAddLink => 'Tambah tautan';

  @override
  String get myLinksSaving => 'Menyimpan...';

  @override
  String get myLinksCreateRequired =>
      'Token, jenis, dan warna diperlukan untuk menambah tautan.';

  @override
  String get myLinksCreateSuccess => 'Tautan ditambahkan.';

  @override
  String get myLinksCreateFailed => 'Tautan tidak dapat ditambahkan.';

  @override
  String get myLinksCreateError => 'Terjadi kesalahan saat menambah tautan.';

  @override
  String get myLinksTokenMissing => 'Token tidak ditemukan.';

  @override
  String get myLinksDeleteSuccess => 'Tautan dihapus.';

  @override
  String get myLinksDeleteFailed => 'Tautan tidak dapat dihapus.';

  @override
  String get myLinksDeleteError => 'Terjadi kesalahan saat menghapus tautan.';

  @override
  String get myLinksUpdateSuccess => 'Tautan diperbarui.';

  @override
  String get myLinksUpdateFailed => 'Tautan tidak dapat diperbarui.';

  @override
  String get myLinksUpdateError => 'Terjadi kesalahan saat memperbarui tautan.';

  @override
  String get myLinksEditTitle => 'Edit tautan';

  @override
  String get myLinksUpdateButton => 'Perbarui';

  @override
  String myLinksTypeFallback(Object id) {
    return 'Jenis #$id';
  }

  @override
  String myLinksColorFallback(Object id) {
    return 'Warna #$id';
  }

  @override
  String get myLinksNoLinksTitle => 'Belum ada tautan';

  @override
  String get myLinksNoLinksSubtitle => 'Mulai dengan menambah tautan baru';

  @override
  String get myLinksDebugTitle => 'Data tidak lengkap';

  @override
  String get myLinksDebugSubtitle =>
      'Daftar yang diharapkan tidak dikembalikan oleh API';

  @override
  String get myLinksDebugNoLinks => '⚠️ API tidak mengembalikan tautan.';

  @override
  String get myLinksDebugNoTypes => '⚠️ Daftar jenis tautan kosong.';

  @override
  String get myLinksDebugNoColors => '⚠️ Daftar warna kosong.';

  @override
  String get myLinksOrderSaving => 'Menyimpan urutan...';

  @override
  String get myLinksShowForm => 'Tambah tautan baru';

  @override
  String get myLinksHideForm => 'Sembunyikan formulir';

  @override
  String get themesTitle => 'Tema';

  @override
  String get themesSessionMissing =>
      'Sesi tidak ditemukan. Silakan masuk lagi.';

  @override
  String get themesSessionExpired => 'Sesi Anda berakhir. Silakan masuk lagi.';

  @override
  String themesLoadFailed(Object error) {
    return 'Tema tidak dapat dimuat: $error';
  }

  @override
  String get themesPreviewError => 'Terjadi masalah saat memuat pratinjau.';

  @override
  String get themesSelectTheme => 'Pilih tema.';

  @override
  String get themesSaveSuccess => 'Tema diperbarui.';

  @override
  String themesSaveFailedStatus(Object status) {
    return 'Tema tidak dapat diperbarui (HTTP $status).';
  }

  @override
  String themesSaveError(Object error) {
    return 'Terjadi kesalahan saat menyimpan tema: $error';
  }

  @override
  String get themesRefreshTooltip => 'Muat ulang';

  @override
  String get themesRetry => 'Coba lagi';

  @override
  String get themesListTitle => 'Tema';

  @override
  String get themesNoThemes => 'Tidak ada tema tersedia.';

  @override
  String get themesLivePreview => 'Pratinjau langsung';

  @override
  String get themesSaving => 'Menyimpan...';

  @override
  String get themesSaveButton => 'Simpan tema';

  @override
  String get themesPreviewPlaceholder => 'Pilih tema untuk melihat pratinjau.';

  @override
  String get themesFallbackName => 'Tema';

  @override
  String get smsPacksTitle => 'Paket SMS';

  @override
  String get smsPacksSessionMissing =>
      'Sesi tidak ditemukan. Silakan masuk lagi.';

  @override
  String get smsPacksSessionExpired => 'Sesi berakhir. Silakan masuk lagi.';

  @override
  String smsPacksLoadFailedStatus(Object status) {
    return 'Paket tidak dapat dimuat (HTTP $status).';
  }

  @override
  String smsPacksLoadFailed(Object error) {
    return 'Paket tidak dapat dimuat: $error';
  }

  @override
  String smsPacksCountriesFailedStatus(Object status) {
    return 'Negara tidak dapat dimuat (HTTP $status).';
  }

  @override
  String smsPacksCountriesFailed(Object error) {
    return 'Negara tidak dapat dimuat: $error';
  }

  @override
  String smsPacksCitiesFailedStatus(Object status) {
    return 'Kota tidak dapat dimuat (HTTP $status).';
  }

  @override
  String smsPacksCitiesFailed(Object error) {
    return 'Kota tidak dapat dimuat: $error';
  }

  @override
  String smsPacksDistrictsFailedStatus(Object status) {
    return 'Kecamatan tidak dapat dimuat (HTTP $status).';
  }

  @override
  String smsPacksDistrictsFailed(Object error) {
    return 'Kecamatan tidak dapat dimuat: $error';
  }

  @override
  String smsPacksAddressesFailedStatus(Object status) {
    return 'Alamat tidak dapat dimuat (HTTP $status).';
  }

  @override
  String smsPacksAddressesFailed(Object error) {
    return 'Alamat tidak dapat dimuat: $error';
  }

  @override
  String get smsPacksContentMissing => 'Konten tidak ditemukan.';

  @override
  String get smsPacksContract => 'Perjanjian';

  @override
  String get smsPacksClose => 'Tutup';

  @override
  String get smsPacksFeatures => 'Fitur';

  @override
  String get smsPacksPlanMonthly => 'Bulanan';

  @override
  String get smsPacksPlanAnnual => 'Tahunan';

  @override
  String get smsPacksSelectPack => 'Pilih paket.';

  @override
  String get smsPacksSelectCountry => 'Pilih negara.';

  @override
  String get smsPacksSelectCity => 'Pilih kota.';

  @override
  String get smsPacksSelectDistrict => 'Pilih kecamatan.';

  @override
  String get smsPacksNameRequired => 'Nama tidak boleh kosong.';

  @override
  String get smsPacksLastNameRequired => 'Nama belakang tidak boleh kosong.';

  @override
  String get smsPacksPhoneRequired => 'Telepon tidak boleh kosong.';

  @override
  String get smsPacksAddressRequired => 'Alamat tidak boleh kosong.';

  @override
  String get smsPacksAgreementRequired =>
      'Anda harus menyetujui perjanjian pembelian.';

  @override
  String get smsPacksPurchaseSuccess =>
      'Pesanan dibuat, mengalihkan ke pembayaran.';

  @override
  String smsPacksPurchaseFailedStatus(Object status) {
    return 'Pembelian gagal (HTTP $status).';
  }

  @override
  String smsPacksPurchaseError(Object error) {
    return 'Terjadi kesalahan saat pembelian: $error';
  }

  @override
  String get smsPacksPaymentStartInvalid =>
      'Halaman pembayaran tidak dapat dibuka. Respons tidak valid.';

  @override
  String smsPacksPaymentStartFailedStatus(Object status) {
    return 'Pembayaran tidak dapat dimulai (HTTP $status).';
  }

  @override
  String smsPacksPaymentStartError(Object error) {
    return 'Terjadi kesalahan saat memulai pembayaran: $error';
  }

  @override
  String get smsPacksPaymentPending =>
      'Pembayaran sedang dikonfirmasi. Harap tunggu.';

  @override
  String get smsPacksPaymentVerify403 =>
      'Pembayaran tidak dapat diverifikasi (403).';

  @override
  String get smsPacksPaymentVerify404 => 'Transaksi tidak ditemukan (404).';

  @override
  String smsPacksPaymentVerifyFailedStatus(Object status) {
    return 'Pembayaran tidak dapat diverifikasi (HTTP $status).';
  }

  @override
  String smsPacksPaymentVerifyError(Object error) {
    return 'Pembayaran tidak dapat diverifikasi: $error';
  }

  @override
  String get smsPacksPaymentSuccessTitle => 'Pembayaran berhasil';

  @override
  String get smsPacksPaymentPendingTitle => 'Pembayaran tertunda';

  @override
  String get smsPacksPaymentFailedTitle => 'Pembayaran gagal';

  @override
  String get smsPacksPaymentLabel => 'Pembayaran';

  @override
  String get smsPacksPackLabel => 'Paket';

  @override
  String get smsPacksTypeLabel => 'Jenis';

  @override
  String get smsPacksAmountLabel => 'Jumlah';

  @override
  String get smsPacksInvoiceLabel => 'Nomor faktur';

  @override
  String get smsPacksPaymentVerifying => 'Memverifikasi pembayaran...';

  @override
  String get smsPacksGoHome => 'Ke beranda';

  @override
  String get smsPacksRetry => 'Coba lagi';

  @override
  String get smsPacksStepPack => 'Paket';

  @override
  String get smsPacksStepInfo => 'Info';

  @override
  String get smsPacksStepSummary => 'Ringkasan';

  @override
  String get smsPacksStepPayment => 'Pembayaran';

  @override
  String get smsPacksNext => 'Berikutnya';

  @override
  String get smsPacksBack => 'Kembali';

  @override
  String get smsPacksBuy => 'Beli';

  @override
  String get smsPacksDetails => 'Lihat fitur';

  @override
  String get smsPacksSelectButton => 'Pilih paket';

  @override
  String get smsPacksSelected => 'Dipilih';

  @override
  String get smsPacksRefresh => 'Muat ulang';

  @override
  String get smsPacksSavedAddresses => 'Alamat tersimpan';

  @override
  String get smsPacksNewAddress => 'Alamat baru';

  @override
  String get smsPacksAddressTitle => 'Label alamat';

  @override
  String get smsPacksFirstName => 'Nama depan';

  @override
  String get smsPacksLastName => 'Nama belakang';

  @override
  String get smsPacksCompany => 'Perusahaan (opsional)';

  @override
  String get smsPacksEmail => 'Email';

  @override
  String get smsPacksCountry => 'Negara';

  @override
  String get smsPacksCity => 'Kota';

  @override
  String get smsPacksDistrict => 'Kecamatan';

  @override
  String get smsPacksPhone => 'Telepon';

  @override
  String get smsPacksIdentity => 'Nomor identitas (opsional)';

  @override
  String get smsPacksTaxNumber => 'Nomor pajak (opsional)';

  @override
  String get smsPacksTaxOffice => 'Kantor pajak';

  @override
  String get smsPacksAddress => 'Alamat';

  @override
  String get smsPacksPaymentMethod => 'Metode pembayaran';

  @override
  String get smsPacksNote => 'Catatan';

  @override
  String get smsPacksNoteHint => 'Catatan atau permintaan khusus untuk faktur';

  @override
  String get smsPacksAgreementTitle =>
      'Saya telah membaca dan menyetujui perjanjian pembelian.';

  @override
  String get smsPacksPaymentSecurityNote =>
      'Pembayaran diselesaikan di halaman pembayaran aman PayTR. Aplikasi tidak mengumpulkan atau menyimpan detail kartu Anda.';

  @override
  String get smsPacksSummaryTitle => 'Ringkasan pembelian';

  @override
  String get smsPacksSummaryPurchaseInfo => 'Informasi pembelian';

  @override
  String get smsPacksSmsLabel => 'SMS';

  @override
  String get smsPacksCompanyLabel => 'Perusahaan';

  @override
  String get smsPacksBuyerLabel => 'Nama lengkap';

  @override
  String get smsPacksEmailLabel => 'Email';

  @override
  String get smsPacksCountryLabel => 'Negara';

  @override
  String get smsPacksCityLabel => 'Kota';

  @override
  String get smsPacksDistrictLabel => 'Kecamatan';

  @override
  String get smsPacksPhoneLabel => 'Telepon';

  @override
  String get smsPacksTaxNumberLabel => 'Nomor pajak';

  @override
  String get smsPacksTaxOfficeLabel => 'Kantor pajak';

  @override
  String get smsPacksIdentityLabel => 'Nomor identitas';

  @override
  String get smsPacksAddressLabel => 'Alamat';

  @override
  String get smsPacksNoteLabel => 'Catatan';

  @override
  String get smsPacksSubmitLabel => 'Kirim';

  @override
  String get smsPacksNoPacksForType =>
      'Tidak ada paket tersedia untuk jenis ini.';

  @override
  String smsPacksPriceWithTax(Object price) {
    return 'Termasuk PPN ₺$price';
  }

  @override
  String smsPacksSmsCount(Object count) {
    return '$count SMS';
  }

  @override
  String get smsPacksSelectPackForSummary =>
      'Pilih paket untuk melihat ringkasan.';

  @override
  String get smsPacksRefreshing => 'Memuat ulang...';

  @override
  String get smsPacksSavedAddressesLabel => 'Alamat tersimpan';

  @override
  String get smsPacksSelectAddress => 'Pilih';

  @override
  String get smsPacksPlanLabel => 'Paket';

  @override
  String get smsPacksPriceLabel => 'Harga';

  @override
  String get smsPacksVatIncluded => 'Termasuk PPN';

  @override
  String get smsPacksSubmitting => 'Mengirim...';

  @override
  String get smsPacksAndroidOnlyTitle => 'Pembelian di aplikasi Android';

  @override
  String get smsPacksAndroidOnlyMessage =>
      'Pembelian paket SMS hanya tersedia di aplikasi Android. Anda dapat melihat paket di perangkat ini.';

  @override
  String iosPacksPurchaseStreamError(Object error) {
    return 'Proses pembelian Apple tidak dapat dipantau: $error';
  }

  @override
  String get iosPacksPackIdMissing =>
      'ios_product_id tidak ditemukan untuk paket ini.';

  @override
  String iosPacksPackDetailsLoadFailed(Object error) {
    return 'Detail paket tidak dapat dimuat: $error';
  }

  @override
  String iosPacksPackDetailsTitle(Object name) {
    return 'Detail paket $name';
  }

  @override
  String get iosPacksNoPackDetails => 'Detail paket ini tidak ditemukan.';

  @override
  String iosPacksInvalidLink(Object value) {
    return 'Tautan tidak valid: $value';
  }

  @override
  String iosPacksLinkOpenFailed(Object value) {
    return 'Tautan tidak dapat dibuka: $value';
  }

  @override
  String get iosPacksStoreKitUnavailable =>
      'StoreKit tidak tersedia. Perangkat atau akun App Store mungkin belum siap.';

  @override
  String iosPacksStoreProductNotFound(Object productId) {
    return 'App Store mengembalikan notFound untuk \"$productId\".';
  }

  @override
  String iosPacksStoreProductMissing(Object productId) {
    return 'Produk \"$productId\" tidak dimuat dari App Store.';
  }

  @override
  String get iosPacksPlanSparkHeadline => 'Mulai dengan sederhana';

  @override
  String get iosPacksPlanBoostHeadline => 'Lebih cepat dan fleksibel';

  @override
  String get iosPacksPlanPowerHeadline => 'Untuk jadwal yang lebih padat';

  @override
  String get iosPacksPlanPrimeHeadline =>
      'Akses penuh untuk alur kerja premium Anda';

  @override
  String get iosPacksPlanDefaultHeadline =>
      'Pilih paket yang sesuai dengan alur kerja Anda';

  @override
  String get iosPacksSubscriptionGeneric => 'langganan';

  @override
  String iosPacksBenefitAppointmentAccess(Object duration) {
    return 'Pengelolaan janji temu tetap aktif dengan paket $duration Anda.';
  }

  @override
  String get iosPacksBenefitSecureCheckout =>
      'Pembayaran aman ditangani langsung oleh Apple.';

  @override
  String get iosPacksBenefitManageSubscription =>
      'Kelola perpanjangan dan pembatalan dari akun App Store Anda.';

  @override
  String get iosPacksAppleSubscription => 'Langganan Apple';

  @override
  String get iosPacksHeroDescription =>
      'Pilih periode penagihan, periksa harga, lalu lanjutkan pembelian aman di App Store.';

  @override
  String iosPacksStoreProductUnavailable(Object diagnostic) {
    return 'Produk App Store ini tidak tersedia. $diagnostic';
  }

  @override
  String get iosPacksPurchaseStartFailed =>
      'Permintaan pembelian App Store tidak dapat dimulai.';

  @override
  String iosPacksPurchaseFailed(Object error) {
    return 'Kesalahan pembelian App Store: $error';
  }

  @override
  String get iosPacksRestoreStarted => 'Memulihkan pembelian Apple...';

  @override
  String iosPacksRestoreFailed(Object error) {
    return 'Pemulihan tidak dapat dimulai: $error';
  }

  @override
  String get iosPacksRestoreSuccess => 'Langganan Apple dipulihkan.';

  @override
  String get iosPacksPurchaseSuccess => 'Langganan Apple berhasil dibeli.';

  @override
  String get iosPacksPurchaseUnknownError => 'Pembelian App Store gagal.';

  @override
  String get iosPacksPurchaseCancelled => 'Pembelian dibatalkan.';

  @override
  String get iosPacksUnavailableInStore => 'Tidak tersedia di App Store';

  @override
  String get iosPacksDetailsButton => 'Detail paket';

  @override
  String get iosPacksNoProductsForType =>
      'Tidak ada produk ditemukan untuk jenis paket ini.';

  @override
  String get iosPacksSelectedPlan => 'Paket yang dipilih';

  @override
  String get iosPacksActivationInfo =>
      'Aktivasi langsung setelah pembelian Apple';

  @override
  String get iosPacksAgreementDetails => 'Detail';

  @override
  String get iosPacksAppointmentPackageInfo =>
      'Pengelolaan janji temu menggunakan akses paket. Saldo SMS hanya digunakan saat pengiriman SMS atau pengingat diaktifkan.';

  @override
  String get iosPacksLegalConsent =>
      'Dengan melanjutkan, Anda menyetujui Ketentuan Penggunaan dan Kebijakan Privasi.';

  @override
  String get iosPacksTermsOfUse => 'Ketentuan Penggunaan';

  @override
  String get iosPacksPrivacyPolicy => 'Kebijakan Privasi';

  @override
  String get iosPacksStoreUnavailableNow =>
      'Produk App Store tidak tersedia saat ini.';

  @override
  String get iosPacksRestoreInProgress => 'Memulihkan…';

  @override
  String get iosPacksRestore => 'Pulihkan';

  @override
  String get ordersTitle => 'Pesanan';

  @override
  String get ordersSessionExpired => 'Sesi berakhir. Silakan masuk lagi.';

  @override
  String get ordersSessionMissing =>
      'Sesi tidak ditemukan. Silakan masuk lagi.';

  @override
  String ordersFetchFailedStatus(Object status) {
    return 'Pesanan tidak dapat dimuat (HTTP $status).';
  }

  @override
  String ordersFetchFailed(Object error) {
    return 'Pesanan tidak dapat dimuat: $error';
  }

  @override
  String get ordersRetry => 'Coba lagi';

  @override
  String get ordersEmpty => 'Belum ada pesanan.';

  @override
  String get ordersFilterAll => 'Semua';

  @override
  String get ordersFilterPaid => 'Dibayar';

  @override
  String get ordersFilterPending => 'Menunggu';

  @override
  String get ordersFilterFailed => 'Gagal';

  @override
  String get ordersPrev => 'Sebelumnya';

  @override
  String get ordersNext => 'Berikutnya';

  @override
  String ordersPageLabel(Object current, Object total) {
    return 'Halaman $current / $total';
  }

  @override
  String get ordersPack => 'Paket';

  @override
  String get ordersType => 'Jenis';

  @override
  String get ordersStatus => 'Status';

  @override
  String get ordersAmount => 'Jumlah';

  @override
  String get ordersDate => 'Tanggal';

  @override
  String get ordersTxnId => 'ID transaksi';

  @override
  String get ordersPrice => 'Harga';

  @override
  String get ordersTax => 'Pajak';

  @override
  String get ordersTotal => 'Total';

  @override
  String get ordersDetailTitle => 'Pesanan';

  @override
  String get ordersStatusPaid => 'Dibayar';

  @override
  String get ordersStatusPending => 'Menunggu';

  @override
  String get ordersStatusFailed => 'Gagal';

  @override
  String get ordersStatusCancelled => 'Dibatalkan';

  @override
  String get workingPrefsTitle => 'Jam kerja';

  @override
  String get workingPrefsSessionMissing =>
      'Sesi tidak ditemukan. Silakan masuk lagi.';

  @override
  String workingPrefsLoadFailedStatus(Object status) {
    return 'Jam kerja tidak dapat dimuat (HTTP $status).';
  }

  @override
  String workingPrefsLoadFailed(Object error) {
    return 'Jam kerja tidak dapat dimuat: $error';
  }

  @override
  String get workingPrefsSaveSuccess => 'Disimpan.';

  @override
  String workingPrefsSaveFailedStatus(Object status) {
    return 'Tidak dapat disimpan (HTTP $status).';
  }

  @override
  String workingPrefsSaveFailed(Object error) {
    return 'Tidak dapat disimpan: $error';
  }

  @override
  String get workingPrefsRetry => 'Coba lagi';

  @override
  String get workingPrefsFirstSessionTitle => 'Jumlah sesi janji temu pertama';

  @override
  String get workingPrefsSessionLabel => 'Sesi';

  @override
  String get workingPrefsSelect => 'Pilih';

  @override
  String workingPrefsSessionOption(Object count) {
    return '$count sesi';
  }

  @override
  String get workingPrefsDaySubtitle => 'Status kerja dan rentang waktu';

  @override
  String get workingPrefsStatusLabel => 'Status';

  @override
  String get workingPrefsTimeSlotsLabel => 'Slot waktu';

  @override
  String get workingPrefsWorking => 'Bekerja';

  @override
  String get workingPrefsAddSlot => 'Tambah slot waktu';

  @override
  String get workingPrefsStart => 'Mulai';

  @override
  String get workingPrefsEnd => 'Selesai';

  @override
  String get workingPrefsPeriod => 'Durasi (menit)';

  @override
  String get workingPrefsDelete => 'Hapus';

  @override
  String get workingPrefsSaving => 'Menyimpan...';

  @override
  String get workingPrefsSave => 'Simpan';

  @override
  String get workingPrefsHolidaysTitle => 'Hari libur';

  @override
  String get workingPrefsHolidaysEmpty => 'Belum ada hari libur ditambahkan.';

  @override
  String get workingPrefsHolidayAdd => 'Tambah hari libur';

  @override
  String get workingPrefsHolidayStart => 'Mulai';

  @override
  String get workingPrefsHolidayEnd => 'Selesai';

  @override
  String get workingPrefsHolidayReason => 'Alasan (opsional)';

  @override
  String get workingPrefsTemplatesTitle => 'Templat cepat';

  @override
  String get workingPrefsTemplatesSubtitle =>
      'Pilih templat untuk memulai dengan cepat';

  @override
  String get workingPrefsTemplatesApply => 'Terapkan';

  @override
  String workingPrefsTemplatesApplied(String name) {
    return 'Templat $name diterapkan.';
  }

  @override
  String get workingPrefsTemplatesConfirmTitle => 'Terapkan templat';

  @override
  String get workingPrefsTemplatesConfirmBody =>
      'Yakin ingin menerapkan templat ini? Jam kerja Anda saat ini akan diganti.';

  @override
  String get workingPrefsTemplatesCancel => 'Batal';

  @override
  String get smsTemplatesTitle => 'Templat SMS';

  @override
  String get smsTemplatesSessionMissing =>
      'Sesi tidak ditemukan. Silakan masuk lagi.';

  @override
  String smsTemplatesFetchFailedStatus(Object status) {
    return 'Templat tidak dapat dimuat (HTTP $status).';
  }

  @override
  String smsTemplatesFetchFailed(Object error) {
    return 'Templat tidak dapat dimuat: $error';
  }

  @override
  String get smsTemplatesUpdated => 'Templat SMS diperbarui.';

  @override
  String smsTemplatesSaveFailedStatus(Object status) {
    return 'Tidak dapat disimpan (HTTP $status).';
  }

  @override
  String smsTemplatesSaveFailed(Object error) {
    return 'Tidak dapat disimpan: $error';
  }

  @override
  String get smsTemplatesSelect => 'Pilih';

  @override
  String get smsTemplatesNotFound => 'Templat tidak ditemukan';

  @override
  String get smsTemplatesCustomerTemplates => 'Templat SMS pelanggan';

  @override
  String smsTemplatesSelectionId(Object id) {
    return 'ID pilihan: $id';
  }

  @override
  String get smsTemplatesMain => 'Pesan utama';

  @override
  String get smsTemplatesReminder => 'Pengingat';

  @override
  String get smsTemplatesCancel => 'Batal';

  @override
  String get smsTemplatesUpdate => 'Perbarui';

  @override
  String get smsTemplatesSave => 'Simpan';

  @override
  String get smsTemplatesSaving => 'Menyimpan...';

  @override
  String get smsTemplatesRefresh => 'Muat ulang';

  @override
  String smsTemplatesFallbackTitle(Object id) {
    return 'Templat #$id';
  }

  @override
  String get smsTemplatesGuideTitle => 'Pemilihan templat';

  @override
  String get smsTemplatesGuideBody =>
      'Pilih satu templat SMS untuk setiap kategori.';

  @override
  String get smsTemplatesGuideHint =>
      'Ketuk kartu untuk memilih templat. Kartu yang dipilih disorot dan ditampilkan di pratinjau langsung di bawah.';

  @override
  String get smsTemplatesMainDescription =>
      'Pesan yang dikirim saat janji temu baru dibuat.';

  @override
  String get smsTemplatesReminderDescription =>
      'Pesan yang dikirim sebagai pengingat sebelum janji temu.';

  @override
  String get smsTemplatesCancelDescription =>
      'Pesan yang dikirim saat janji temu dibatalkan.';

  @override
  String get smsTemplatesUpdateDescription =>
      'Pesan yang dikirim saat tanggal atau waktu janji temu diperbarui.';

  @override
  String get smsTemplatesPreviewTitle => 'Pratinjau langsung';

  @override
  String get smsTemplatesPreviewEmpty =>
      'Belum ada templat dipilih untuk kategori ini.';

  @override
  String get smsTemplatesSelected => 'Dipilih';

  @override
  String get supportTitle => 'Bantuan';

  @override
  String get supportSessionMissing =>
      'Sesi tidak ditemukan. Silakan masuk lagi.';

  @override
  String supportFetchFailedStatus(Object status) {
    return 'Tiket bantuan tidak dapat dimuat (HTTP $status).';
  }

  @override
  String supportFetchFailed(Object error) {
    return 'Tiket bantuan tidak dapat dimuat: $error';
  }

  @override
  String get supportCreateValidation => 'Judul dan pesan wajib diisi.';

  @override
  String get supportCreateSuccess => 'Tiket bantuan dibuat.';

  @override
  String supportCreateFailedStatus(Object status) {
    return 'Tiket tidak dapat dibuat (HTTP $status).';
  }

  @override
  String supportCreateFailed(Object error) {
    return 'Tiket tidak dapat dibuat: $error';
  }

  @override
  String get supportRetry => 'Coba lagi';

  @override
  String get supportEmpty => 'Anda belum memiliki tiket bantuan.';

  @override
  String get supportRefresh => 'Muat ulang';

  @override
  String get supportNewTicket => 'Tiket bantuan baru';

  @override
  String get supportTitleLabel => 'Judul';

  @override
  String get supportMessageLabel => 'Pesan Anda';

  @override
  String get supportSending => 'Mengirim...';

  @override
  String get supportSend => 'Kirim';

  @override
  String get supportTickets => 'Tiket bantuan';

  @override
  String get supportMessagesCount => 'Pesan';

  @override
  String get supportTicketDetail => 'Detail bantuan';

  @override
  String get supportTicketNotFound => 'Tiket tidak ditemukan.';

  @override
  String get supportMessages => 'Pesan';

  @override
  String get supportStatusClosing => 'Menutup';

  @override
  String get supportCloseTicket => 'Tutup tiket';

  @override
  String supportCreatedAt(Object date) {
    return 'Dibuat: $date';
  }

  @override
  String get supportSenderYou => 'Anda';

  @override
  String get supportSenderSupport => 'Bantuan';

  @override
  String get supportNoMessages => 'Belum ada pesan.';

  @override
  String get supportReplyPlaceholder => 'Pesan Anda';

  @override
  String get supportReplyClosed =>
      'Tiket ini telah ditutup. Anda tidak dapat mengirim pesan baru.';

  @override
  String get supportReplySending => 'Mengirim...';

  @override
  String get supportReplySend => 'Kirim balasan';

  @override
  String get supportReplyEmpty => 'Pesan tidak boleh kosong.';

  @override
  String get supportReplySuccess => 'Balasan dikirim.';

  @override
  String supportReplyFailedStatus(Object status) {
    return 'Balasan tidak dapat dikirim (HTTP $status).';
  }

  @override
  String supportReplyFailed(Object error) {
    return 'Balasan tidak dapat dikirim: $error';
  }

  @override
  String get supportCloseSuccess => 'Tiket ditutup.';

  @override
  String supportCloseFailedStatus(Object status) {
    return 'Tiket tidak dapat ditutup (HTTP $status).';
  }

  @override
  String supportCloseFailed(Object error) {
    return 'Tiket tidak dapat ditutup: $error';
  }

  @override
  String supportMessagesMeta(Object count, Object date) {
    return '$count pesan • $date';
  }

  @override
  String get supportStatusOpen => 'Buka';

  @override
  String get supportStatusPending => 'Menunggu';

  @override
  String get supportStatusClosed => 'Tutup';

  @override
  String get supportPriority => 'Prioritas';

  @override
  String get profileLanguage => 'Bahasa aplikasi';

  @override
  String get profileLanguageEnglish => 'Inggris';

  @override
  String get profileLanguageSaved => 'Bahasa diperbarui.';

  @override
  String get profileDeleteSectionTitle => 'Hapus akun';

  @override
  String get profileDeleteSectionSubtitle =>
      'Tindakan ini tidak dapat dibatalkan.';

  @override
  String get profileDeleteConfirmTitle => 'Hapus akun';

  @override
  String get profileDeleteConfirmBody =>
      'Yakin ingin menghapus akun Anda? Tindakan ini tidak dapat dibatalkan.';

  @override
  String get profileDeleteCancel => 'Batal';

  @override
  String get profileDeleteAction => 'Hapus akun';

  @override
  String get profileDeleteProcessing => 'Memproses...';

  @override
  String get profileDeleteSuccess => 'Akun berhasil dihapus.';

  @override
  String get profileDeleteFailed => 'Permintaan penghapusan akun gagal.';

  @override
  String profileDeleteError(Object error) {
    return 'Terjadi kesalahan saat menghapus akun: $error';
  }

  @override
  String get dashboardNoActivePackage =>
      'Anda tidak memiliki paket aktif. Beli paket untuk menggunakan SMS.';

  @override
  String get dashboardBuyPackage => 'Beli paket';

  @override
  String get aiProfileBannerBadge => 'Asisten AI Liik';

  @override
  String get aiProfileBannerTitle => 'Buat profil dengan AI';

  @override
  String get aiProfileBannerDesc =>
      'AI menulis profil yang mengubah pengikut menjadi janji temu. Anda cukup membagikan keahlian Anda.';

  @override
  String get aiProfileTitle => 'Profil AI';

  @override
  String get aiProfileAiBadge => 'Asisten AI Liik';

  @override
  String get aiProfileSubtitle =>
      'Buat profil profesional dalam hitungan detik';

  @override
  String get aiProfileLoading => 'Memuat profil AI...';

  @override
  String get aiProfileRetry => 'Coba lagi';

  @override
  String get aiProfileSave => 'Simpan';

  @override
  String get aiProfileSaving => 'Menyimpan...';

  @override
  String get aiProfileTabProfile => 'Profil';

  @override
  String get aiProfileTabLinks => 'Tautan';

  @override
  String get aiProfileTabTheme => 'Tema';

  @override
  String get aiProfileRemainingNone => 'Selesai';

  @override
  String get aiProfileGenerateTitle => 'Buat dengan AI';

  @override
  String get aiProfileGenerateSubtitle =>
      'Isi detail Anda dan biarkan AI membuat profil Anda';

  @override
  String get aiProfileGenerateButton => 'Buat dengan AI';

  @override
  String get aiProfileGenerating => 'Membuat...';

  @override
  String get aiProfileGenerateLocked => 'Kredit pembuatan AI habis';

  @override
  String get aiProfileGenerateSuccess => 'Profil Anda siap!';

  @override
  String get aiProfileGenerateSuccessHint =>
      'Anda dapat mengedit konten di bawah';

  @override
  String get aiProfileMsgAnalyzing => 'Menganalisis profil Anda...';

  @override
  String get aiProfileMsgPreparing => 'Menyiapkan konten untuk profesi Anda...';

  @override
  String get aiProfileMsgSelecting => 'Memilih ungkapan terbaik...';

  @override
  String get aiProfileMsgSeo => 'Menerapkan optimasi SEO...';

  @override
  String get aiProfileMsgFinalizing => 'Menambahkan sentuhan akhir...';

  @override
  String get aiProfileMsgWait => 'Ini mungkin memerlukan beberapa detik';

  @override
  String get aiProfileFieldProfession => 'Profesi *';

  @override
  String get aiProfileFieldProfessionError => 'Pilih profesi';

  @override
  String get aiProfileFieldExpertise => 'Bidang keahlian *';

  @override
  String get aiProfileFieldExpertiseHint =>
      'Nutrisi olahraga, pengelolaan berat badan';

  @override
  String get aiProfileFieldExpertiseError => 'Kolom wajib diisi';

  @override
  String get aiProfileFieldAudience => 'Target audiens *';

  @override
  String get aiProfileFieldAudienceHint =>
      'Orang dewasa yang ingin lebih bugar';

  @override
  String get aiProfileFieldAudienceError => 'Kolom wajib diisi';

  @override
  String get aiProfileFieldExperience => 'Pengalaman (tahun)';

  @override
  String get aiProfileFieldExperienceHint => '0–50';

  @override
  String get aiProfileFieldExperienceError => 'Harus antara 0 dan 50';

  @override
  String get aiProfileFieldTone => 'Nada';

  @override
  String get aiProfileFieldAchievement => 'Pencapaian / Keanggotaan';

  @override
  String get aiProfileFieldAchievementHint => 'Asosiasi profesi';

  @override
  String get aiProfileFieldNote => 'Catatan tambahan';

  @override
  String get aiProfileFieldNoteHint => 'Singkat dan jelas';

  @override
  String get aiProfileFieldBio => 'Bio / Deskripsi (min. 20 karakter)';

  @override
  String get aiProfileFieldFooter => 'Footer';

  @override
  String get aiProfileSectionSeo => 'Pengaturan SEO';

  @override
  String get aiProfileFieldSeoTitle => 'Judul SEO (maks. 70)';

  @override
  String get aiProfileFieldSeoDesc => 'Deskripsi meta (maks. 170)';

  @override
  String get aiProfileFieldSeoKeywords =>
      'Kata kunci — pisahkan dengan koma (maks. 300)';

  @override
  String get aiProfileLinksSubtitle =>
      'Tambahkan URL lalu aktifkan atau nonaktifkan.';

  @override
  String get aiProfileLinksSave => 'Simpan tautan';

  @override
  String get aiProfileLinksSaving => 'Menyimpan...';

  @override
  String get aiProfileThemeNoPreview => 'Pilih tema.';

  @override
  String get aiProfileThemeNoUser => 'Info pengguna tidak dapat dimuat.';

  @override
  String get aiProfileReminderTitle => 'Konten siap — jangan lupa simpan!';

  @override
  String get aiProfileReminderSubtitle => 'Ketuk tombol Simpan di kanan atas';

  @override
  String get aiProfileSaveSuccess => 'Disimpan!';

  @override
  String get aiProfileSaveBioMin => 'Bio harus berisi minimal 20 karakter.';

  @override
  String get aiProfileThemeApplied => 'Tema diterapkan.';

  @override
  String get aiProfileLinksSaved => 'Tautan disimpan.';

  @override
  String get aiProfileLimitReached => 'Batas AI harian tercapai.';

  @override
  String get aiProfileValidationErrors => 'Perbaiki kesalahan pada formulir.';

  @override
  String get aiProfileSessionMissing =>
      'Sesi tidak ditemukan. Silakan masuk lagi.';

  @override
  String aiProfileRemainingCount(Object count) {
    return 'Tersisa $count';
  }

  @override
  String aiProfileFetchError(Object status) {
    return 'Data tidak dapat dimuat (HTTP $status).';
  }

  @override
  String aiProfileConnectionError(Object error) {
    return 'Kesalahan koneksi: $error';
  }

  @override
  String aiProfileGenerateHttpError(Object status) {
    return 'Pembuatan gagal (HTTP $status).';
  }

  @override
  String aiProfileSaveHttpError(Object status) {
    return 'Gagal menyimpan (HTTP $status).';
  }

  @override
  String aiProfileThemeHttpError(Object status) {
    return 'Tema tidak dapat disimpan (HTTP $status).';
  }

  @override
  String aiProfileLinksHttpError(Object status) {
    return 'Tautan tidak dapat disimpan (HTTP $status).';
  }

  @override
  String get onboardBadge1 => 'RUANG MILIK ANDA';

  @override
  String get onboardBadge2 => 'JANJI TEMU LEBIH MUDAH';

  @override
  String get onboardBadge3 => 'SIAP DIBAGIKAN';

  @override
  String get onboardSkip => 'Lewati';

  @override
  String get onboardContinue => 'Lanjutkan';

  @override
  String get onboardStart => 'Mulai dengan Liik';

  @override
  String get onboardLogin => 'Sudah punya akun? Masuk';

  @override
  String get onboardPreviewName => 'Halo, saya Alex';

  @override
  String get onboardPreviewTagline => 'Berkarya. Berbagi. Terhubung.';

  @override
  String get onboardPreviewExplore => 'Jelajahi dunia saya';

  @override
  String get onboardPreviewBook => 'Mari pilih waktu';

  @override
  String get onboardPreviewCall => 'Sesi perkenalan';

  @override
  String get onboardPreviewDuration => '30 menit · Online';

  @override
  String get onboardPreviewReady => 'Tautan bio Anda siap';

  @override
  String get onboardPreviewShareHint =>
      'Tambahkan ke profil. Biarkan orang menemukan Anda.';

  @override
  String get onboardPreviewConnections => 'Satu tautan. Koneksi baru.';

  @override
  String get loginSubtitle => 'Masuk ke akun Anda dan lanjutkan aktivitas Anda';

  @override
  String get loginOr => 'atau';

  @override
  String get loginNoAccount => 'Belum punya akun?';

  @override
  String get registerTitle => 'Buat akun';

  @override
  String get registerConfirmPassword => 'Konfirmasi kata sandi';

  @override
  String get registerUsername => 'Nama pengguna (opsional)';

  @override
  String get registerSubmit => 'Daftar';

  @override
  String get registerError => 'Terjadi kesalahan saat pendaftaran.';

  @override
  String get authTokenMissing => 'Token masuk tidak dapat diperoleh.';

  @override
  String get authUnauthorized => 'Akses masuk tidak diizinkan.';

  @override
  String get authGoogleCancelled => 'Proses masuk Google dibatalkan.';

  @override
  String get authGoogleTokenMissing =>
      'Token masuk Google tidak dapat diperoleh.';

  @override
  String get verifyEmailPending =>
      'Email belum diverifikasi. Periksa kotak masuk Anda.';

  @override
  String get authConnectionError => 'Tidak dapat terhubung ke server.';

  @override
  String get verifyEmailResent => 'Email verifikasi dikirim ulang.';

  @override
  String get commonSendFailed => 'Tidak dapat mengirim.';

  @override
  String get verifyEmailTitle => 'Verifikasi email Anda';

  @override
  String get verifyEmailCheck => 'Saya sudah memverifikasi email';

  @override
  String get verifyEmailResend => 'Kirim ulang';

  @override
  String get verifyEmailOtherAccount => 'Masuk dengan akun lain';

  @override
  String get dashboardImageFailed => 'Gambar tidak dapat dibuat.';

  @override
  String get commonNoResults => 'Tidak ada hasil ditemukan';

  @override
  String get dashboardPackageActivated => 'Paket Anda aktif! 🎉';

  @override
  String get commonError => 'Terjadi kesalahan.';

  @override
  String get dashboardWelcomeGiftTitle => 'Klaim hadiah selamat datang Anda';

  @override
  String get dashboardWelcomeGiftDescription =>
      'Lengkapi formulir untuk mengaktifkan 100 SMS gratis selama satu bulan.';

  @override
  String get commonChoose => 'Pilih...';

  @override
  String get dashboardCityRequired => 'Kota *';

  @override
  String get dashboardCityHint => 'mis. Jakarta';

  @override
  String get dashboardInstagramOptional => 'Instagram (opsional)';

  @override
  String get dashboardActivatePackage => 'Aktifkan paket';

  @override
  String get dashboardWelcomeGiftBadge => 'HADIAH SELAMAT DATANG';

  @override
  String get dashboardWelcomeGiftOffer => '100 SMS gratis selama satu bulan';

  @override
  String get dashboardWelcomeGiftHint =>
      'Hadiah Anda menunggu. Lengkapi formulir untuk mengaktifkannya.';

  @override
  String get dashboardReviewTitle => 'Suka menggunakan Liik?';

  @override
  String get dashboardReviewHint => 'Ulasan Anda membantu kami berkembang.';

  @override
  String get dashboardReviewAction => 'Beri nilai Liik';

  @override
  String get commonView => 'Lihat';

  @override
  String get dashboardTopUp => 'Isi ulang';

  @override
  String get dashboardFeedbackTitle =>
      'Bagaimana pengalaman Anda menggunakan Liik?';

  @override
  String get dashboardFeedbackHint =>
      'Bagikan pengalaman Anda untuk membantu kami berkembang.';

  @override
  String get dashboardFeedbackComment => 'Komentar Anda (opsional)...';

  @override
  String get dashboardFeedbackSubmit => 'Kirim ulasan';

  @override
  String get commonNotNow => 'Nanti saja';

  @override
  String get ratingVeryBad => 'Sangat buruk';

  @override
  String get ratingBad => 'Buruk';

  @override
  String get ratingGood => 'Baik';

  @override
  String get ratingExcellent => 'Luar biasa!';

  @override
  String get ratingSelect => 'Pilih nilai';

  @override
  String get workingTemplateAfternoon => 'Siang';

  @override
  String get workingTemplateEvening => 'Malam';

  @override
  String get announcementWarning => 'Peringatan';

  @override
  String get announcementUpdate => 'Pembaruan';

  @override
  String get announcementConnectionError => 'Kesalahan koneksi.';

  @override
  String get announcementReadAll => 'Tandai semua sudah dibaca';

  @override
  String get announcementEmpty => 'Belum ada pengumuman';

  @override
  String get announcementDownload => 'Unduh pembaruan';

  @override
  String get blogTitle => 'Artikel';

  @override
  String get blogViewAll => 'Lihat semua';

  @override
  String get blogLoadFailed => 'Artikel tidak dapat dimuat.';

  @override
  String get commonAll => 'Semua';

  @override
  String get blogEmptyCategory => 'Belum ada artikel dalam kategori ini';

  @override
  String get blogReadMore => 'Baca selengkapnya';

  @override
  String get aiProfileBioPreview => 'Pratinjau halaman bio';

  @override
  String get aiProfileConversionPage => 'Halaman janji temu saya';

  @override
  String get aiProfileConversionHint => 'Ubah pengikut menjadi janji temu';

  @override
  String get aiProfilePageTitle => 'Judul halaman';

  @override
  String get aiProfileMetaPlaceholder =>
      'Deskripsi meta Anda muncul di sini. Jelaskan halaman Anda untuk hasil pencarian.';

  @override
  String get aiProfileGooglePreview => 'Pratinjau pencarian Google';

  @override
  String get aiProfileSeoWeak => 'Lemah';

  @override
  String get aiProfileSeoExcellent => 'Sangat baik';

  @override
  String get aiProfileThemeAutoSave =>
      'Ketuk tema untuk menyimpannya secara otomatis';

  @override
  String get aiProfileEditLinks => 'Edit tautan saya';

  @override
  String get aiProfilePreviewLoading => 'Memuat pratinjau...';

  @override
  String get aiProfilePreviewFailed => 'Pratinjau tidak dapat dimuat';

  @override
  String get professionTrainer => 'Pelatih pribadi';

  @override
  String get professionBeautician => 'Ahli kecantikan';

  @override
  String get professionCoach => 'Coach & konsultan';

  @override
  String get aiProfileProfessionTemplate => 'Mulai cepat sesuai profesi Anda';

  @override
  String get aiProfileReorderLinks =>
      'Seret dan lepas untuk mengurutkan tautan aktif';

  @override
  String get appointmentDateTimeHeading => 'TANGGAL & WAKTU';

  @override
  String authRegisterFailed(int status) {
    return 'Pendaftaran gagal (HTTP $status).';
  }

  @override
  String authLoginFailed(int status) {
    return 'Proses masuk gagal (HTTP $status).';
  }

  @override
  String authGoogleFailed(int status) {
    return 'Proses masuk Google gagal (HTTP $status).';
  }

  @override
  String authConnectionFailed(String error) {
    return 'Tidak dapat terhubung ke server: $error';
  }

  @override
  String authGoogleError(String error) {
    return 'Proses masuk Google gagal: $error';
  }

  @override
  String authAppleError(String error) {
    return 'Proses masuk Apple gagal: $error';
  }

  @override
  String verifyEmailFailed(int status) {
    return 'Status verifikasi tidak dapat diperiksa (HTTP $status).';
  }

  @override
  String verifyEmailDescription(String email) {
    return 'Kami mengirim tautan verifikasi ke $email. Buka tautan, lalu ketuk tombol di bawah.';
  }

  @override
  String verifyEmailResendCountdown(int seconds) {
    return 'Kirim ulang (${seconds}d)';
  }

  @override
  String get announcementInfo => 'Info';

  @override
  String get announcementPromo => 'Penawaran';

  @override
  String get announcementFeature => 'Fitur baru';

  @override
  String get announcementTitle => 'Pengumuman';

  @override
  String get announcementsTitle => 'Pengumuman';

  @override
  String get ratingAverage => 'Biasa';

  @override
  String get workingTemplateStandard => 'Standar';

  @override
  String get workingTemplateExpert => 'Ahli';

  @override
  String get workingTemplateWeekend => 'Akhir pekan';

  @override
  String get professionDietitian => 'Ahli gizi';

  @override
  String get professionPsychologist => 'Psikolog';

  @override
  String get professionPhysiotherapist => 'Fisioterapis';

  @override
  String get aiToneFriendly => 'Ramah';

  @override
  String get aiToneFriendlyHint => 'Bahasa hangat dan alami';

  @override
  String get aiToneProfessional => 'Profesional';

  @override
  String get aiToneProfessionalHint => 'Formal dan meyakinkan';

  @override
  String get aiToneWarm => 'Hangat';

  @override
  String get aiToneWarmHint => 'Empatik dan akrab';

  @override
  String get linkLocation => 'Lokasi';

  @override
  String get linkWebsite => 'Situs web';

  @override
  String previewLoadError(String error) {
    return 'Pratinjau tidak dapat dimuat: $error';
  }

  @override
  String announcementLoadFailed(int status) {
    return 'Pengumuman tidak dapat dimuat (HTTP $status).';
  }

  @override
  String announcementMinutesAgo(int count) {
    return '$count menit lalu';
  }

  @override
  String announcementHoursAgo(int count) {
    return '$count jam lalu';
  }

  @override
  String announcementDaysAgo(int count) {
    return '$count hari lalu';
  }

  @override
  String dashboardLowSms(int count) {
    return 'Saldo SMS Anda hampir habis — tersisa $count pesan.';
  }

  @override
  String get workingTemplateStandardDescription =>
      'Sen–Jum 09:00–12:00 / 13:00–17:00 · 20 menit';

  @override
  String get workingTemplateAfternoonDescription =>
      'Sen–Jum 13:00–17:00 · 20 menit';

  @override
  String get workingTemplateExpertDescription =>
      'Sen–Sab 09:00–12:00 / 13:00–17:00 · 20 menit';

  @override
  String get workingTemplateEveningDescription =>
      'Sen–Sab 17:00–21:00 · 45 menit';

  @override
  String get workingTemplateWeekendDescription =>
      'Sab–Min 10:00–17:00 · 30 menit';

  @override
  String get loginWelcome => 'Selamat datang kembali.';

  @override
  String get loginWelcomeDescription =>
      'Tautan, janji temu, dan koneksi baru Anda. Semua di satu tempat.';

  @override
  String get loginEmailHint => 'anda@contoh.com';

  @override
  String get loginPasswordHint => 'Masukkan kata sandi Anda';

  @override
  String get loginShowPassword => 'Tampilkan kata sandi';

  @override
  String get loginHidePassword => 'Sembunyikan kata sandi';

  @override
  String get loginEmailValidation => 'Masukkan alamat email yang valid.';

  @override
  String get loginPasswordValidation => 'Masukkan kata sandi Anda.';

  @override
  String get loginApple => 'Masuk dengan Apple';

  @override
  String get dashboardWelcome => 'Hari Anda, terhubung.';

  @override
  String get dashboardBioHint =>
      'Satu tautan untuk dunia Anda. Bagikan di mana pun orang menemukan Anda.';

  @override
  String get dashboardCopyLink => 'Salin tautan';

  @override
  String get dashboardBioEmptyTitle => 'Koneksi berikutnya dimulai di sini.';

  @override
  String get dashboardBioEmptyHint =>
      'Buat halaman Liik untuk menyatukan tautan dan janji temu Anda.';

  @override
  String get dashboardScheduleEmptyHint =>
      'Masih ada waktu luang. Tambahkan janji temu atau bagikan halaman Anda.';

  @override
  String get dashboardViewAppointments => 'Lihat janji temu';

  @override
  String dashboardAnnouncements(int count) {
    return '$count pengumuman baru';
  }

  @override
  String get appointmentsHeading => 'Jadwal lebih teratur.';

  @override
  String get appointmentsInView => 'Dalam tampilan ini';

  @override
  String get appointmentsPlanRequired =>
      'Paket Anda saat ini tidak mencakup pengelolaan janji temu.';

  @override
  String get calendarLoadError =>
      'Tidak dapat memuat minggu ini. Silakan coba lagi.';

  @override
  String get contactsSubtitle =>
      'Semua kontak Anda di satu tempat. Kelola detail dan janji temu bersama.';

  @override
  String get contactsAll => 'Semua';

  @override
  String contactsCount(int count) {
    return '$count kontak';
  }

  @override
  String get contactsNoResults =>
      'Kontak tidak ditemukan. Coba nama, nomor telepon, atau email lain.';

  @override
  String get contactsLoadError =>
      'Tidak dapat memuat kontak. Silakan coba lagi.';

  @override
  String get contactsSaveError =>
      'Tidak dapat menyimpan kontak ini. Silakan coba lagi.';

  @override
  String get contactsPhoneInvalid =>
      'Masukkan nomor telepon yang valid hingga 15 digit.';

  @override
  String get contactsEmailInvalid => 'Masukkan alamat email yang valid.';

  @override
  String get linksSubtitle =>
      'Tautan Anda, sesuai gaya Anda. Satukan semua yang Anda bagikan di halaman Liik.';

  @override
  String get linksFormSubtitle =>
      'Pilih jenis tautan, tambahkan tujuan, dan sesuaikan tampilannya.';

  @override
  String get linksOrderHint =>
      'Seret ikon untuk mengubah urutan di halaman Anda.';

  @override
  String get linksOrderError =>
      'Tidak dapat menyimpan urutan. Urutan sebelumnya telah dipulihkan.';

  @override
  String get linksLoadError => 'Tidak dapat memuat tautan Anda.';

  @override
  String get linksRetryHint => 'Periksa koneksi Anda dan coba lagi.';

  @override
  String get linksSettingsError =>
      'Tidak dapat memuat jenis tautan dan warna. Silakan coba lagi.';

  @override
  String get linksDeleteTitle => 'Hapus tautan ini?';

  @override
  String get linksDeleteBody =>
      'Tautan ini akan dihapus dari halaman Liik Anda.';

  @override
  String get linksDestinationRequired => 'Masukkan tujuan untuk tautan ini.';

  @override
  String get linksTextTooLong => 'Gunakan maksimal 255 karakter.';

  @override
  String get linksMoveUp => 'Pindah ke atas';

  @override
  String get linksMoveDown => 'Pindah ke bawah';

  @override
  String get linksDrag => 'Seret untuk mengurutkan';

  @override
  String get linksActions => 'Tindakan tautan';

  @override
  String get themesSubtitle =>
      'Jadikan halaman Liik sesuai gaya Anda. Pilih tema dan lihat pratinjaunya.';

  @override
  String get themesCurrent => 'Tema saat ini';

  @override
  String get themesUnsaved => 'Pratinjau tema baru · belum disimpan';

  @override
  String get themesApplied => 'Tema diterapkan';

  @override
  String get themesRefreshPreview => 'Muat ulang pratinjau';

  @override
  String get themesLoadError => 'Tidak dapat memuat tema. Silakan coba lagi.';

  @override
  String get themesSaveErrorMessage =>
      'Tidak dapat menyimpan tema ini. Silakan coba lagi.';

  @override
  String get themesViewPreview => 'Lihat pratinjau';

  @override
  String get profileTimezone => 'Zona waktu lokal';

  @override
  String get profileTimezoneHint =>
      'Janji temu dan jam kerja Anda menggunakan zona waktu ini. Perubahan waktu musim panas ditangani otomatis.';

  @override
  String get profileTimezoneSearch => 'Cari kota atau zona waktu';

  @override
  String get profileTimezoneLoadError =>
      'Tidak dapat memuat zona waktu. Silakan coba lagi.';

  @override
  String get supportSubtitle =>
      'Butuh bantuan? Hubungi kami dan pantau permintaan dukungan Anda di sini.';

  @override
  String get supportFormHint =>
      'Ceritakan apa yang terjadi dan bagaimana kami dapat membantu.';

  @override
  String get supportActive => 'Aktif';

  @override
  String get supportFinished => 'Selesai & ditutup';

  @override
  String get supportFilterEmpty => 'Tidak ada permintaan dalam kategori ini.';

  @override
  String get supportLoadError =>
      'Tidak dapat memuat permintaan dukungan. Silakan coba lagi.';

  @override
  String get supportSendError =>
      'Tidak dapat mengirim pesan Anda. Silakan coba lagi.';

  @override
  String get supportCloseError =>
      'Tidak dapat menutup permintaan ini. Silakan coba lagi.';

  @override
  String get supportMessageTooShort => 'Tulis minimal 5 karakter.';

  @override
  String get supportReplyTooShort => 'Tulis minimal 2 karakter.';

  @override
  String get supportCloseConfirm =>
      'Tutup permintaan ini? Anda tidak dapat membalasnya lagi.';

  @override
  String get supportInProgress => 'Sedang diproses';

  @override
  String get supportResolved => 'Selesai';

  @override
  String get supportPriorityLow => 'Prioritas rendah';

  @override
  String get supportPriorityMedium => 'Prioritas normal';

  @override
  String get supportPriorityHigh => 'Prioritas tinggi';

  @override
  String get supportPriorityUrgent => 'Mendesak';

  @override
  String get analyticsTitle => 'Analitik';

  @override
  String get analyticsIntro =>
      'Lihat bagaimana orang menemukan profil dan berinteraksi dengan tautan Anda.';

  @override
  String get analyticsPeriod => 'Periode laporan';

  @override
  String analyticsDays(int count) {
    return '$count hari';
  }

  @override
  String get analyticsOverview => 'Ringkasan';

  @override
  String get analyticsLinks => 'Kinerja tautan';

  @override
  String get analyticsAudience => 'Audiens';

  @override
  String get analyticsConversions => 'Rasio klik';

  @override
  String get analyticsClicks => 'Klik tautan';

  @override
  String get analyticsVisitors => 'Pengunjung unik';

  @override
  String get analyticsUniqueClicks => 'Pengklik unik';

  @override
  String get analyticsRate => 'Rasio klik';

  @override
  String get analyticsRedirects => 'Tampilan halaman pengalihan';

  @override
  String get analyticsPrevious => 'vs. periode sebelumnya';

  @override
  String get analyticsNoPrevious => 'Belum ada data pembanding';

  @override
  String get analyticsUnchanged => 'Tidak berubah';

  @override
  String get analyticsTrend => 'Klik tautan harian';

  @override
  String get analyticsTrendHint => 'Total klik dan pengklik unik setiap hari.';

  @override
  String get analyticsEmpty => 'Belum ada aktivitas pada periode ini';

  @override
  String get analyticsEmptyText =>
      'Kunjungan dan klik akan muncul saat orang menggunakan profil Anda.';

  @override
  String get analyticsTopLinks => 'Tautan teratas';

  @override
  String get analyticsLink => 'Tautan';

  @override
  String get analyticsShare => 'Porsi klik';

  @override
  String get analyticsNoLinks => 'Belum ada klik tautan.';

  @override
  String get analyticsViews => 'Pengunjung';

  @override
  String get analyticsFunnel => 'Dari profil ke tautan';

  @override
  String get analyticsFunnelHint =>
      'Pengunjung unik dan pengklik unik dihitung terpisah selama periode terpilih.';

  @override
  String get analyticsManual => 'Manual';

  @override
  String get analyticsAutomatic => 'Otomatis';

  @override
  String get analyticsNavigation => 'Metode navigasi';

  @override
  String get analyticsNavigationHint =>
      'Cara pengunjung berpindah dari halaman pengalihan ke tujuan.';

  @override
  String get analyticsSources => 'Sumber trafik';

  @override
  String get analyticsDevices => 'Perangkat';

  @override
  String get analyticsPlatforms => 'Platform';

  @override
  String get analyticsBrowsers => 'Browser';

  @override
  String get analyticsCountries => 'Negara';

  @override
  String get analyticsHours => 'Klik per jam';

  @override
  String get analyticsWeekdays => 'Klik per hari';

  @override
  String get analyticsUnknown => 'Tidak diketahui';

  @override
  String get analyticsMobile => 'Ponsel';

  @override
  String get analyticsDesktop => 'Desktop';

  @override
  String get analyticsTablet => 'Tablet';

  @override
  String analyticsTimezone(String timezone) {
    return 'Zona waktu laporan: $timezone';
  }

  @override
  String get analyticsDataNote =>
      'Hanya aktivitas yang tercatat yang disertakan. Metrik unik menggunakan pengenal pengunjung anonim.';

  @override
  String get analyticsRateNote =>
      'Pengklik unik dibagi pengunjung profil unik. Mengukur interaksi dengan tautan.';

  @override
  String get analyticsLoadError =>
      'Analitik tidak dapat dimuat. Silakan coba lagi.';

  @override
  String get themesFree => 'Gratis';

  @override
  String get themesPremium => 'Premium';

  @override
  String get themesClassic => 'Klasik';

  @override
  String get appointmentShare => 'Bagikan janji temu';

  @override
  String get appointmentCopyLink => 'Salin tautan';

  @override
  String get appointmentLinkCopied => 'Tautan disalin';

  @override
  String get appointmentCode => 'Kode janji temu';

  @override
  String get appointmentDetails => 'Detail janji temu';

  @override
  String get appointmentNotes => 'Catatan';

  @override
  String get appointmentStatusLabel => 'Status';

  @override
  String get appointmentOpenCalendar =>
      'Lihat janji temu / tambahkan ke kalender';

  @override
  String get appointmentHistory => 'Riwayat janji temu';

  @override
  String get appointmentShareFailed =>
      'Tidak dapat membagikan janji temu. Coba salin tautan.';

  @override
  String get appointmentTimezone => 'Zona waktu';

  @override
  String get calendarSubtitle =>
      'Rencanakan minggu Anda, lihat detail dan bagikan janji temu.';

  @override
  String get profileDesignIntro =>
      'Sesuaikan profil Anda. Kelola detail, visibilitas, dan pengaturan akun.';
}

/// The translations for Indonesian, as used in Indonesia (`id_ID`).
class AppLocalizationsIdId extends AppLocalizationsId {
  AppLocalizationsIdId() : super('id_ID');

  @override
  String get appointmentShare => 'Bagikan janji temu';

  @override
  String get appointmentCopyLink => 'Salin tautan';

  @override
  String get appointmentLinkCopied => 'Tautan disalin';

  @override
  String get appointmentCode => 'Kode janji temu';

  @override
  String get appointmentDetails => 'Detail janji temu';

  @override
  String get appointmentNotes => 'Catatan';

  @override
  String get appointmentStatusLabel => 'Status';

  @override
  String get appointmentOpenCalendar =>
      'Lihat janji temu / tambahkan ke kalender';

  @override
  String get appointmentHistory => 'Riwayat janji temu';

  @override
  String get appointmentShareFailed =>
      'Tidak dapat membagikan janji temu. Coba salin tautan.';

  @override
  String get appointmentTimezone => 'Zona waktu';

  @override
  String get calendarSubtitle =>
      'Rencanakan minggu Anda, lihat detail dan bagikan janji temu.';

  @override
  String get profileDesignIntro =>
      'Sesuaikan profil Anda. Kelola detail, visibilitas, dan pengaturan akun.';
}

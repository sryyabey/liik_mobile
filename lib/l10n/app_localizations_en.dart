// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get loginTitle => 'Login';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get facebookLogin => 'Continue with Facebook';

  @override
  String get googleLogin => 'Continue with Google';

  @override
  String get onboardTitle1 => 'Your world.\nOne simple link.';

  @override
  String get onboardDesc1 =>
      'Bring your links, services and everything that makes you, you, together on your Liik page.';

  @override
  String get onboardTitle2 => 'Your next booking.\nJust a tap away.';

  @override
  String get onboardDesc2 =>
      'Share your availability. Let visitors choose a time that works, while you focus on your day.';

  @override
  String get onboardTitle3 => 'Show up.\nMake connections.';

  @override
  String get onboardDesc3 =>
      'Create a page that feels like you, share your bio link and connect with new people.';

  @override
  String get menuTitle => 'Menu';

  @override
  String get myLinks => 'My Links';

  @override
  String get customersTitle => 'My Contacts';

  @override
  String get customersSessionMissing =>
      'Session not found. Please log in again.';

  @override
  String customersLoadFailedStatus(Object status) {
    return 'Customers could not be loaded (HTTP $status).';
  }

  @override
  String customersLoadFailed(Object error) {
    return 'Customers could not be loaded: $error';
  }

  @override
  String get customersSearchHint => 'Search contact (name, phone, email)';

  @override
  String get customersRetry => 'Retry';

  @override
  String get customersEmpty => 'No contacts yet.';

  @override
  String get customersLoadMore => 'Load more';

  @override
  String get customersRefresh => 'Refresh';

  @override
  String get customersAdd => 'Add Contact';

  @override
  String get customersEdit => 'Edit Contact';

  @override
  String get customersAddSubtitle => 'Add a new contact';

  @override
  String get customersEditSubtitle => 'Edit contact details';

  @override
  String get customersDelete => 'Delete';

  @override
  String get customersDeleteConfirmTitle => 'Delete contact?';

  @override
  String get customersDeleteConfirmBody =>
      'Are you sure you want to delete this contact?';

  @override
  String get customersCancel => 'Cancel';

  @override
  String get customersSave => 'Save';

  @override
  String get customersSaving => 'Saving...';

  @override
  String get customersName => 'Full Name';

  @override
  String get customersPhone => 'Phone';

  @override
  String get customersEmail => 'Email';

  @override
  String get customersAddress => 'Address';

  @override
  String get customersNotes => 'Notes';

  @override
  String get customersValidation => 'Full Name and Phone are required.';

  @override
  String get customersCreateSuccess => 'Contact created.';

  @override
  String get customersUpdateSuccess => 'Contact updated.';

  @override
  String customersSaveFailedStatus(Object status) {
    return 'Could not be saved (HTTP $status).';
  }

  @override
  String customersSaveFailed(Object error) {
    return 'Could not be saved: $error';
  }

  @override
  String get customersDeleteSuccess => 'Contact deleted.';

  @override
  String customersDeleteFailedStatus(Object status) {
    return 'Contact could not be deleted (HTTP $status).';
  }

  @override
  String customersDeleteFailed(Object error) {
    return 'Contact could not be deleted: $error';
  }

  @override
  String get customersAppointments => 'Appointments';

  @override
  String get customersNoAppointments => 'No appointments for this contact.';

  @override
  String customersAppointmentsLoadFailedStatus(Object status) {
    return 'Appointments could not be loaded (HTTP $status).';
  }

  @override
  String customersAppointmentsLoadFailed(Object error) {
    return 'Appointments could not be loaded: $error';
  }

  @override
  String get customersCreateAppointment => 'Add Appointment';

  @override
  String get customersAppointmentDate => 'Date';

  @override
  String get customersAppointmentTime => 'Time';

  @override
  String get customersAppointmentNote => 'Note';

  @override
  String get customersAppointmentNoteHint => 'Add an appointment note...';

  @override
  String customersEmptyForLetter(Object letter) {
    return 'No contacts starting with \"$letter\" were found.';
  }

  @override
  String get customersFirstAppointment => 'First appointment?';

  @override
  String get customersNoSms => 'Do not send SMS';

  @override
  String get customersNoReminder => 'Do not send reminder';

  @override
  String get customersCreateAppointmentSuccess => 'Appointment created.';

  @override
  String get customersCreateAppointmentFailed =>
      'Appointment could not be created.';

  @override
  String get themes => 'Themes';

  @override
  String get profile => 'Profile';

  @override
  String get support => 'Support';

  @override
  String get exit => 'Logout';

  @override
  String get loginButton => 'Login';

  @override
  String get dashboardTitle => 'Admin Panel';

  @override
  String get dashboardHeroSubtitle =>
      'Manage your links and appointments in one place.';

  @override
  String get dashboardQuickActions => 'Quick Actions';

  @override
  String get dashboardMenuMain => 'MAIN MENU';

  @override
  String get dashboardMenuManagement => 'MANAGEMENT';

  @override
  String get dashboardDrawerSubtitle =>
      'Manage your appointments and contacts here';

  @override
  String get dashboardTopClicks => 'Total Clicks';

  @override
  String get dashboardRemainingSms => 'Remaining SMS';

  @override
  String get dashboardBioPage => 'Your Bio Page';

  @override
  String get dashboardLinkCopied => 'Link copied.';

  @override
  String get dashboardShare => 'Share';

  @override
  String get dashboardDownload => 'Download';

  @override
  String get dashboardQr => 'QR';

  @override
  String get dashboardPackageInfo => 'Package Info';

  @override
  String get dashboardPackageName => 'Package name';

  @override
  String get dashboardStart => 'Start';

  @override
  String get dashboardEnd => 'End';

  @override
  String get dashboardDailyClicks => 'Daily Clicks';

  @override
  String get dashboardTopLinks => 'Top Clicked Links';

  @override
  String get dashboardNoClicks => 'No click data yet.';

  @override
  String get dashboardNoLinkClicks => 'No link clicks yet.';

  @override
  String get dashboardTodayAppointments => 'Today\'s Appointments';

  @override
  String dashboardTodayCount(Object count) {
    return '$count today';
  }

  @override
  String get dashboardNoAppointmentsData => 'No appointment data for today.';

  @override
  String get dashboardNoAppointments => 'No appointments for today.';

  @override
  String dashboardCustomerFallback(Object id) {
    return 'Customer #$id';
  }

  @override
  String get dashboardCalendar => 'Calendar';

  @override
  String get dashboardAppointments => 'Appointments';

  @override
  String get dashboardHome => 'Home';

  @override
  String get dashboardWeeklyCalendar => 'Weekly Calendar';

  @override
  String get dashboardSmsPacks => 'SMS Packs';

  @override
  String get dashboardOrders => 'Orders';

  @override
  String get dashboardWorkingHours => 'Working Hours';

  @override
  String get dashboardSmsTemplates => 'SMS Templates';

  @override
  String get dashboardRetry => 'Retry';

  @override
  String get dashboardNoInternet => 'Please check your internet connection.';

  @override
  String get dashboardSessionMissing =>
      'Session not found. Please log in again.';

  @override
  String dashboardLoadFailedWithStatus(Object status) {
    return 'Dashboard could not be loaded (HTTP $status).';
  }

  @override
  String dashboardLoadFailed(Object error) {
    return 'Dashboard could not be loaded: $error';
  }

  @override
  String get dashboardQrTitle => 'Bio Link QR';

  @override
  String dashboardShareFailed(Object error) {
    return 'Share failed: $error';
  }

  @override
  String dashboardQrDownloadFailed(Object error) {
    return 'QR could not be downloaded: $error';
  }

  @override
  String get dashboardLinkOpenFailed => 'Link could not be opened.';

  @override
  String get dashboardWhatsAppFailed => 'WhatsApp could not be opened.';

  @override
  String dashboardWhatsAppFailedWithError(Object error) {
    return 'WhatsApp could not be opened: $error';
  }

  @override
  String get dashboardShareBio => 'Liik bio link';

  @override
  String get dashboardWhatsappSupport => 'WhatsApp Support';

  @override
  String get appointmentManagement => 'Appointment Management';

  @override
  String get appointmentSubtitle =>
      'Track your daily appointments and create new ones quickly.';

  @override
  String get refresh => 'Refresh';

  @override
  String get today => 'Today';

  @override
  String get total => 'Total';

  @override
  String get quickAppointment => 'Add Appointment';

  @override
  String get showFilter => 'Filter';

  @override
  String get hideFilter => 'Hide filter';

  @override
  String get refreshList => 'Refresh List';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusConfirmed => 'Confirmed';

  @override
  String get statusRescheduled => 'Rescheduled';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusNoShow => 'No-show';

  @override
  String get customerPreview => 'Customer Preview';

  @override
  String get recentAppointments => 'Recent Appointments';

  @override
  String get reschedule => 'Reschedule';

  @override
  String get date => 'Date';

  @override
  String get timeSelect => 'Time (choose)';

  @override
  String get note => 'Note';

  @override
  String get disableSms => 'Disable SMS';

  @override
  String get smsOffForAppointment => 'SMS is disabled for this appointment.';

  @override
  String get disableReminder => 'Disable Reminder';

  @override
  String get reminderOffForAppointment =>
      'Reminder notification is disabled for this appointment.';

  @override
  String get rescheduleAppointment => 'Reschedule Appointment';

  @override
  String get editAppointment => 'Edit Appointment';

  @override
  String get status => 'Status';

  @override
  String get save => 'Save';

  @override
  String get quickAppointmentTitle => 'Add Appointment';

  @override
  String get quickAppointmentSubtitle =>
      'Fill customer and appointment info on one screen and save quickly.';

  @override
  String get customerInfo => 'Customer Info';

  @override
  String get appointmentInfo => 'Appointment Info';

  @override
  String get getAvailableTimes => 'Get Available Times';

  @override
  String get setWorkingHours => 'Set Working Hours';

  @override
  String get sendSms => 'Send SMS';

  @override
  String get doNotSendSms => 'Do not send SMS';

  @override
  String get sendReminder => 'Send Reminder';

  @override
  String get doNotSendReminder => 'Do not send reminder';

  @override
  String get googleLoginButton => 'Sign in with Google';

  @override
  String get googleConnecting => 'Connecting...';

  @override
  String get createAccountEmail => 'Create account with email';

  @override
  String get appointmentsTitle => 'Appointments';

  @override
  String get appointmentsEmpty => 'No appointments yet.';

  @override
  String appointmentsCountLabel(Object count) {
    return '$count records';
  }

  @override
  String get appointmentsFilterSubtitle =>
      'Filter by customer, date and time range';

  @override
  String get appointmentsPackageRequired =>
      'An active package or subscription is required for appointment actions. This check is separate from SMS sending; SMS balance is only used when an SMS or reminder is actually sent.';

  @override
  String get appointmentsSessionMissingLogin =>
      'Session not found. Please log in again.';

  @override
  String appointmentsCountriesFetchFailedStatus(Object status) {
    return 'Countries could not be fetched (HTTP $status).';
  }

  @override
  String appointmentsCountriesFetchFailed(Object error) {
    return 'Countries could not be fetched: $error';
  }

  @override
  String appointmentsStatusesFetchFailedStatus(Object status) {
    return 'Statuses could not be fetched (HTTP $status).';
  }

  @override
  String appointmentsStatusesFetchFailed(Object error) {
    return 'Statuses could not be fetched: $error';
  }

  @override
  String get appointmentsInvalidStartTime => 'Invalid start time. Format HH:MM';

  @override
  String get appointmentsInvalidEndTime => 'Invalid end time. Format HH:MM';

  @override
  String get appointmentsRequiredFields =>
      'Name, lastname, country, phone, date and time are required.';

  @override
  String get appointmentsSelectAvailableTime =>
      'Please select an available time.';

  @override
  String get appointmentsCreateSuccess => 'Appointment created.';

  @override
  String appointmentsCreateFailedStatus(Object status) {
    return 'Appointment could not be created (HTTP $status).';
  }

  @override
  String appointmentsCreateFailed(Object error) {
    return 'Appointment could not be created: $error';
  }

  @override
  String get appointmentsEnterDateFirst => 'Enter a date first.';

  @override
  String appointmentsSlotsFetchFailedStatus(Object status) {
    return 'Time slots could not be fetched (HTTP $status).';
  }

  @override
  String appointmentsSlotsFetchFailed(Object error) {
    return 'Time slots could not be fetched: $error';
  }

  @override
  String get appointmentsDateTimeRequired => 'Date and time are required.';

  @override
  String get appointmentsUpdateSuccess => 'Appointment updated.';

  @override
  String appointmentsUpdateFailedStatus(Object status) {
    return 'Appointment could not be updated (HTTP $status).';
  }

  @override
  String appointmentsUpdateFailed(Object error) {
    return 'Appointment could not be updated: $error';
  }

  @override
  String get appointmentsStatusMissing => 'Appointment status not found.';

  @override
  String get appointmentsRebookSuccess => 'New appointment created.';

  @override
  String get appointmentsInfoMissing => 'Appointment info not found.';

  @override
  String appointmentsInfoFetchFailedStatus(Object status) {
    return 'Information could not be fetched (HTTP $status).';
  }

  @override
  String appointmentsInfoFetchFailed(Object error) {
    return 'Information could not be fetched: $error';
  }

  @override
  String get appointmentsNoRecords => 'No records found.';

  @override
  String get appointmentsClose => 'Close';

  @override
  String get appointmentsClear => 'Clear';

  @override
  String get appointmentsCountry => 'Country';

  @override
  String get appointmentsSelectCountry => 'Select country';

  @override
  String get appointmentsFieldName => 'Name';

  @override
  String get appointmentsFieldNameHint => 'e.g. Alex';

  @override
  String get appointmentsFieldLastName => 'Lastname';

  @override
  String get appointmentsFieldLastNameHint => 'e.g. Brown';

  @override
  String get appointmentsFieldNameFilterHint => 'Customer name';

  @override
  String get appointmentsFieldLastNameFilterHint => 'Customer lastname';

  @override
  String get appointmentsFieldPhone => 'Phone';

  @override
  String get appointmentsFieldPhoneHint => 'e.g. 5554443322';

  @override
  String get appointmentsFieldEmailHint => 'Optional';

  @override
  String get appointmentsStatusSelectHint => 'Select status';

  @override
  String get appointmentsStartDate => 'Start Date';

  @override
  String get appointmentsEndDate => 'End Date';

  @override
  String get appointmentsStartTime => 'Start Time';

  @override
  String get appointmentsEndTime => 'End Time';

  @override
  String get appointmentsBuyPackage => 'Buy Package';

  @override
  String get appointmentsFirstAppointment => 'Is this first appointment?';

  @override
  String get appointmentsReminderDisableTitle => 'Do not send reminder';

  @override
  String get appointmentsSubmitting => 'Submitting...';

  @override
  String get appointmentsCustomerPreviewTooltip => 'Customer preview';

  @override
  String get appointmentsRebookTooltip => 'Rebook appointment';

  @override
  String get appointmentsEditTooltip => 'Edit';

  @override
  String get appointmentsHomeTooltip => 'Home';

  @override
  String get iosSmsPurchaseRestrictionMessage =>
      'SMS package purchasing is not supported in the iOS app due to Apple App Store policies.\nPurchases can be completed on the website.';

  @override
  String appointmentsFetchFailedStatus(Object status) {
    return 'Could not fetch appointments (HTTP $status).';
  }

  @override
  String appointmentsFetchFailed(Object error) {
    return 'Could not fetch appointments: $error';
  }

  @override
  String get calendarSessionMissing => 'Session not found.';

  @override
  String calendarFetchFailedStatus(Object status) {
    return 'Weekly calendar could not be loaded (HTTP $status).';
  }

  @override
  String calendarFetchFailed(Object error) {
    return 'Weekly calendar could not be loaded: $error';
  }

  @override
  String get calendarUnexpected => 'Unexpected response format.';

  @override
  String get calendarClosed => 'Closed';

  @override
  String get calendarCustomer => 'Customer';

  @override
  String get calendarWorkingHoursPrompt => 'Please set your working hours.';

  @override
  String get calendarWorkingHoursButton => 'Set working hours';

  @override
  String get calendarSessionExpired => 'Session expired, please log in again.';

  @override
  String get calendarTitle => 'Weekly Calendar';

  @override
  String get calendarPrev => 'Previous';

  @override
  String get calendarToday => 'Today';

  @override
  String get calendarNext => 'Next';

  @override
  String get calendarLoading => 'Loading...';

  @override
  String get calendarNoData => 'No data for this week.';

  @override
  String calendarSlotsFilled(Object booked, Object total) {
    return '$booked/$total slots filled';
  }

  @override
  String get calendarAddAppointment => 'Add appointment';

  @override
  String get calendarGuideTitle => 'Guide';

  @override
  String get calendarPerson => 'Person';

  @override
  String get calendarExistingPerson => 'Existing Person';

  @override
  String get calendarNewPerson => 'New Person';

  @override
  String get calendarSelectPerson => 'Please select a person';

  @override
  String get calendarDateTimeSection => 'Date & Time';

  @override
  String get calendarNoteHint => 'Add a note...';

  @override
  String get calendarSlotBusy => 'Selected time slot is full.';

  @override
  String get appointmentsConsecutiveSlotsUnavailable =>
      'No consecutive available slots were found. Please update your time selection.';

  @override
  String get commonForbiddenAction =>
      'You do not have permission for this action.';

  @override
  String get commonHolidayDateUnavailable =>
      'The selected date falls on a holiday.';

  @override
  String get calendarCustomerInfoMissing => 'Person info not found.';

  @override
  String get calendarAppointmentInfoMissing => 'Appointment info not found.';

  @override
  String get calendarAppointmentStatusMissing =>
      'Appointment status not found.';

  @override
  String get calendarActionNew => 'New';

  @override
  String get calendarActionEdit => 'Edit';

  @override
  String get calendarFetchAvailableSlots => 'Get available slots';

  @override
  String get calendarDateHint => 'Pick from calendar';

  @override
  String get calendarTimeSlotHint => 'Select slot';

  @override
  String get calendarSelectDateFirst => 'Select a date first.';

  @override
  String get calendarDateTimeRequired => 'Date and time are required.';

  @override
  String get calendarCreateSuccess => 'New appointment created.';

  @override
  String get calendarUpdateSuccess => 'Appointment updated.';

  @override
  String get calendarCreateFailed => 'Appointment could not be created';

  @override
  String get calendarUpdateFailed => 'Appointment could not be updated';

  @override
  String get dayMonShort => 'Mon';

  @override
  String get dayTueShort => 'Tue';

  @override
  String get dayWedShort => 'Wed';

  @override
  String get dayThuShort => 'Thu';

  @override
  String get dayFriShort => 'Fri';

  @override
  String get daySatShort => 'Sat';

  @override
  String get daySunShort => 'Sun';

  @override
  String get dayMonFull => 'Monday';

  @override
  String get dayTueFull => 'Tuesday';

  @override
  String get dayWedFull => 'Wednesday';

  @override
  String get dayThuFull => 'Thursday';

  @override
  String get dayFriFull => 'Friday';

  @override
  String get daySatFull => 'Saturday';

  @override
  String get daySunFull => 'Sunday';

  @override
  String get calendarTimeLabel => 'Time';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileSaved => 'Profile saved.';

  @override
  String get profileSaveError => 'Profile could not be saved.';

  @override
  String get profileSessionMissing => 'Session not found. Please log in again.';

  @override
  String profileFetchFailedStatus(Object status) {
    return 'Profile could not be loaded (HTTP $status).';
  }

  @override
  String profileFetchFailed(Object error) {
    return 'Profile could not be loaded: $error';
  }

  @override
  String get profileAvatarTooLarge => 'Avatar must be smaller than 3MB.';

  @override
  String get profileAvatarInvalidFormat => 'Please upload JPG, PNG, or WEBP.';

  @override
  String profileAvatarPrepareFailed(Object error) {
    return 'Avatar could not be prepared: $error';
  }

  @override
  String get profileUpdateFailedGeneric => 'Update failed.';

  @override
  String profileUpdateFailed(Object error) {
    return 'Profile could not be updated: $error';
  }

  @override
  String get profilePasswordMismatch =>
      'New password and confirmation do not match.';

  @override
  String get profilePasswordUpdated => 'Password updated.';

  @override
  String get profilePasswordUpdateFailed => 'Password could not be updated.';

  @override
  String profilePasswordUpdateFailedWithError(Object error) {
    return 'Password could not be updated: $error';
  }

  @override
  String get profileAvatarUpload => 'Upload Avatar';

  @override
  String get profileNameMissing => 'Name not set';

  @override
  String get profileUsernamePlaceholder => '@user';

  @override
  String get profileInfoTitle => 'Profile Information';

  @override
  String get profileFieldName => 'Name';

  @override
  String get profileFieldUsername => 'Username';

  @override
  String get profileFieldDescription => 'Description';

  @override
  String get profileFieldFooter => 'Footer';

  @override
  String get profileSeoSectionTitle => 'SEO';

  @override
  String get profileSeoSubtitle => 'Title, description and keywords';

  @override
  String get profileSeoTitleLabel => 'Title';

  @override
  String get profileSeoDescriptionLabel => 'Description';

  @override
  String get profileSeoKeywordsLabel => 'Keywords';

  @override
  String get profileSaving => 'Saving...';

  @override
  String get profilePasswordSectionTitle => 'Update Password';

  @override
  String get profilePasswordUpdatedSubtitle => 'Updated successfully';

  @override
  String get profileCurrentPassword => 'Current password';

  @override
  String get profileNewPassword => 'New password';

  @override
  String get profileConfirmPassword => 'Confirm new password';

  @override
  String get profileChangePasswordSaving => 'Sending...';

  @override
  String get profileChangePasswordButton => 'Update Password';

  @override
  String profileSmsCount(Object count) {
    return 'SMS: $count';
  }

  @override
  String get myLinksTitle => 'My Links';

  @override
  String get myLinksNewLink => 'New Link';

  @override
  String get myLinksSearchType => 'Search link type';

  @override
  String get myLinksNoResults => 'No results found';

  @override
  String get myLinksLinkType => 'Link Type';

  @override
  String get myLinksTypeMissing =>
      'No link types found, please check settings.';

  @override
  String get myLinksTitleLabel => 'Title';

  @override
  String get myLinksUrlLabel => 'URL';

  @override
  String get myLinksColorLabel => 'Color';

  @override
  String get myLinksColorMissing => 'No color list found.';

  @override
  String get myLinksAddLink => 'Add Link';

  @override
  String get myLinksSaving => 'Saving...';

  @override
  String get myLinksCreateRequired =>
      'Token, type, and color are required to add a link.';

  @override
  String get myLinksCreateSuccess => 'Link added.';

  @override
  String get myLinksCreateFailed => 'Link could not be added.';

  @override
  String get myLinksCreateError => 'An error occurred while adding the link.';

  @override
  String get myLinksTokenMissing => 'Token not found.';

  @override
  String get myLinksDeleteSuccess => 'Link deleted.';

  @override
  String get myLinksDeleteFailed => 'Link could not be deleted.';

  @override
  String get myLinksDeleteError => 'An error occurred while deleting the link.';

  @override
  String get myLinksUpdateSuccess => 'Link updated.';

  @override
  String get myLinksUpdateFailed => 'Link could not be updated.';

  @override
  String get myLinksUpdateError => 'An error occurred while updating the link.';

  @override
  String get myLinksEditTitle => 'Edit Link';

  @override
  String get myLinksUpdateButton => 'Update';

  @override
  String myLinksTypeFallback(Object id) {
    return 'Type #$id';
  }

  @override
  String myLinksColorFallback(Object id) {
    return 'Color #$id';
  }

  @override
  String get myLinksNoLinksTitle => 'No links yet';

  @override
  String get myLinksNoLinksSubtitle => 'Start by adding a new link';

  @override
  String get myLinksDebugTitle => 'Missing data';

  @override
  String get myLinksDebugSubtitle =>
      'Expected lists were not returned from API';

  @override
  String get myLinksDebugNoLinks => '⚠️ No links returned from API.';

  @override
  String get myLinksDebugNoTypes => '⚠️ Link types returned empty.';

  @override
  String get myLinksDebugNoColors => '⚠️ Color list returned empty.';

  @override
  String get myLinksOrderSaving => 'Saving order...';

  @override
  String get myLinksShowForm => 'Add New Link';

  @override
  String get myLinksHideForm => 'Hide Form';

  @override
  String get themesTitle => 'Themes';

  @override
  String get themesSessionMissing => 'Session not found. Please log in again.';

  @override
  String get themesSessionExpired =>
      'Your session has expired. Please log in again.';

  @override
  String themesLoadFailed(Object error) {
    return 'Themes could not be loaded: $error';
  }

  @override
  String get themesPreviewError => 'There was a problem loading the preview.';

  @override
  String get themesSelectTheme => 'Please select a theme.';

  @override
  String get themesSaveSuccess => 'Theme updated.';

  @override
  String themesSaveFailedStatus(Object status) {
    return 'Theme could not be updated (HTTP $status).';
  }

  @override
  String themesSaveError(Object error) {
    return 'An error occurred while saving the theme: $error';
  }

  @override
  String get themesRefreshTooltip => 'Refresh';

  @override
  String get themesRetry => 'Retry';

  @override
  String get themesListTitle => 'Themes';

  @override
  String get themesNoThemes => 'No themes available.';

  @override
  String get themesLivePreview => 'Live Preview';

  @override
  String get themesSaving => 'Saving...';

  @override
  String get themesSaveButton => 'Save Theme';

  @override
  String get themesPreviewPlaceholder => 'Select a theme to preview.';

  @override
  String get themesFallbackName => 'Theme';

  @override
  String get smsPacksTitle => 'SMS Packs';

  @override
  String get smsPacksSessionMissing =>
      'Session not found. Please log in again.';

  @override
  String get smsPacksSessionExpired => 'Session expired, please log in again.';

  @override
  String smsPacksLoadFailedStatus(Object status) {
    return 'Packages could not be fetched (HTTP $status).';
  }

  @override
  String smsPacksLoadFailed(Object error) {
    return 'Packages could not be fetched: $error';
  }

  @override
  String smsPacksCountriesFailedStatus(Object status) {
    return 'Countries could not be fetched (HTTP $status).';
  }

  @override
  String smsPacksCountriesFailed(Object error) {
    return 'Countries could not be fetched: $error';
  }

  @override
  String smsPacksCitiesFailedStatus(Object status) {
    return 'Cities could not be fetched (HTTP $status).';
  }

  @override
  String smsPacksCitiesFailed(Object error) {
    return 'Cities could not be fetched: $error';
  }

  @override
  String smsPacksDistrictsFailedStatus(Object status) {
    return 'Districts could not be fetched (HTTP $status).';
  }

  @override
  String smsPacksDistrictsFailed(Object error) {
    return 'Districts could not be fetched: $error';
  }

  @override
  String smsPacksAddressesFailedStatus(Object status) {
    return 'Addresses could not be fetched (HTTP $status).';
  }

  @override
  String smsPacksAddressesFailed(Object error) {
    return 'Addresses could not be fetched: $error';
  }

  @override
  String get smsPacksContentMissing => 'Content not found.';

  @override
  String get smsPacksContract => 'Agreement';

  @override
  String get smsPacksClose => 'Close';

  @override
  String get smsPacksFeatures => 'Features';

  @override
  String get smsPacksPlanMonthly => 'Monthly';

  @override
  String get smsPacksPlanAnnual => 'Annual';

  @override
  String get smsPacksSelectPack => 'Please select a pack.';

  @override
  String get smsPacksSelectCountry => 'Please select a country.';

  @override
  String get smsPacksSelectCity => 'Please select a city.';

  @override
  String get smsPacksSelectDistrict => 'Please select a district.';

  @override
  String get smsPacksNameRequired => 'Name cannot be empty.';

  @override
  String get smsPacksLastNameRequired => 'Last name cannot be empty.';

  @override
  String get smsPacksPhoneRequired => 'Phone cannot be empty.';

  @override
  String get smsPacksAddressRequired => 'Address cannot be empty.';

  @override
  String get smsPacksAgreementRequired =>
      'You must accept the purchase agreement.';

  @override
  String get smsPacksPurchaseSuccess =>
      'Order created, redirecting to payment.';

  @override
  String smsPacksPurchaseFailedStatus(Object status) {
    return 'Purchase failed (HTTP $status).';
  }

  @override
  String smsPacksPurchaseError(Object error) {
    return 'An error occurred during purchase: $error';
  }

  @override
  String get smsPacksPaymentStartInvalid =>
      'Payment page could not be opened, invalid response.';

  @override
  String smsPacksPaymentStartFailedStatus(Object status) {
    return 'Payment could not be started (HTTP $status).';
  }

  @override
  String smsPacksPaymentStartError(Object error) {
    return 'An error occurred while starting payment: $error';
  }

  @override
  String get smsPacksPaymentPending =>
      'Payment is being confirmed, please wait.';

  @override
  String get smsPacksPaymentVerify403 => 'Payment could not be verified (403).';

  @override
  String get smsPacksPaymentVerify404 => 'Transaction not found (404).';

  @override
  String smsPacksPaymentVerifyFailedStatus(Object status) {
    return 'Payment could not be verified (HTTP $status).';
  }

  @override
  String smsPacksPaymentVerifyError(Object error) {
    return 'Payment could not be verified: $error';
  }

  @override
  String get smsPacksPaymentSuccessTitle => 'Payment Successful';

  @override
  String get smsPacksPaymentPendingTitle => 'Payment Pending';

  @override
  String get smsPacksPaymentFailedTitle => 'Payment Failed';

  @override
  String get smsPacksPaymentLabel => 'Payment';

  @override
  String get smsPacksPackLabel => 'Pack';

  @override
  String get smsPacksTypeLabel => 'Type';

  @override
  String get smsPacksAmountLabel => 'Amount';

  @override
  String get smsPacksInvoiceLabel => 'Invoice No';

  @override
  String get smsPacksPaymentVerifying => 'Verifying payment...';

  @override
  String get smsPacksGoHome => 'Go to home';

  @override
  String get smsPacksRetry => 'Retry';

  @override
  String get smsPacksStepPack => 'Pack';

  @override
  String get smsPacksStepInfo => 'Info';

  @override
  String get smsPacksStepSummary => 'Summary';

  @override
  String get smsPacksStepPayment => 'Payment';

  @override
  String get smsPacksNext => 'Next';

  @override
  String get smsPacksBack => 'Back';

  @override
  String get smsPacksBuy => 'Buy';

  @override
  String get smsPacksDetails => 'See Features';

  @override
  String get smsPacksSelectButton => 'Select Pack';

  @override
  String get smsPacksSelected => 'Selected';

  @override
  String get smsPacksRefresh => 'Refresh';

  @override
  String get smsPacksSavedAddresses => 'Saved Addresses';

  @override
  String get smsPacksNewAddress => 'New Address';

  @override
  String get smsPacksAddressTitle => 'Address Title';

  @override
  String get smsPacksFirstName => 'First Name';

  @override
  String get smsPacksLastName => 'Last Name';

  @override
  String get smsPacksCompany => 'Company (optional)';

  @override
  String get smsPacksEmail => 'Email';

  @override
  String get smsPacksCountry => 'Country';

  @override
  String get smsPacksCity => 'City';

  @override
  String get smsPacksDistrict => 'District';

  @override
  String get smsPacksPhone => 'Phone';

  @override
  String get smsPacksIdentity => 'Identity No (optional)';

  @override
  String get smsPacksTaxNumber => 'Tax No (optional)';

  @override
  String get smsPacksTaxOffice => 'Tax Office';

  @override
  String get smsPacksAddress => 'Address';

  @override
  String get smsPacksPaymentMethod => 'Payment Method';

  @override
  String get smsPacksNote => 'Note';

  @override
  String get smsPacksNoteHint => 'Note or special requests to add to invoice';

  @override
  String get smsPacksAgreementTitle =>
      'I have read and accept the purchase agreement.';

  @override
  String get smsPacksPaymentSecurityNote =>
      'Payment is completed on PayTR\'s secure payment page. The app does not collect or store your credit card details.';

  @override
  String get smsPacksSummaryTitle => 'Purchase Summary';

  @override
  String get smsPacksSummaryPurchaseInfo => 'Purchase Information';

  @override
  String get smsPacksSmsLabel => 'SMS';

  @override
  String get smsPacksCompanyLabel => 'Company';

  @override
  String get smsPacksBuyerLabel => 'Name Surname';

  @override
  String get smsPacksEmailLabel => 'Email';

  @override
  String get smsPacksCountryLabel => 'Country';

  @override
  String get smsPacksCityLabel => 'City';

  @override
  String get smsPacksDistrictLabel => 'District';

  @override
  String get smsPacksPhoneLabel => 'Phone';

  @override
  String get smsPacksTaxNumberLabel => 'Tax No';

  @override
  String get smsPacksTaxOfficeLabel => 'Tax Office';

  @override
  String get smsPacksIdentityLabel => 'Identity No';

  @override
  String get smsPacksAddressLabel => 'Address';

  @override
  String get smsPacksNoteLabel => 'Note';

  @override
  String get smsPacksSubmitLabel => 'Submit';

  @override
  String get smsPacksNoPacksForType => 'No packs available for this type.';

  @override
  String smsPacksPriceWithTax(Object price) {
    return 'Incl. VAT ₺$price';
  }

  @override
  String smsPacksSmsCount(Object count) {
    return '$count SMS';
  }

  @override
  String get smsPacksSelectPackForSummary =>
      'Please select a pack to see the summary.';

  @override
  String get smsPacksRefreshing => 'Refreshing...';

  @override
  String get smsPacksSavedAddressesLabel => 'Saved Addresses';

  @override
  String get smsPacksSelectAddress => 'Select';

  @override
  String get smsPacksPlanLabel => 'Plan';

  @override
  String get smsPacksPriceLabel => 'Price';

  @override
  String get smsPacksVatIncluded => 'VAT Included';

  @override
  String get smsPacksSubmitting => 'Submitting...';

  @override
  String get smsPacksAndroidOnlyTitle => 'Purchases in Android App';

  @override
  String get smsPacksAndroidOnlyMessage =>
      'SMS package purchase steps are available only in the Android app. You can view packages on this device.';

  @override
  String iosPacksPurchaseStreamError(Object error) {
    return 'Apple purchase flow could not be monitored: $error';
  }

  @override
  String get iosPacksPackIdMissing =>
      'No ios_product_id was found for this package.';

  @override
  String iosPacksPackDetailsLoadFailed(Object error) {
    return 'Package details could not be loaded: $error';
  }

  @override
  String iosPacksPackDetailsTitle(Object name) {
    return '$name Package Details';
  }

  @override
  String get iosPacksNoPackDetails => 'No details were found for this package.';

  @override
  String iosPacksInvalidLink(Object value) {
    return 'Invalid link: $value';
  }

  @override
  String iosPacksLinkOpenFailed(Object value) {
    return 'Link could not be opened: $value';
  }

  @override
  String get iosPacksStoreKitUnavailable =>
      'StoreKit unavailable. Device/App Store account may not be ready.';

  @override
  String iosPacksStoreProductNotFound(Object productId) {
    return 'App Store returned notFound for \"$productId\".';
  }

  @override
  String iosPacksStoreProductMissing(Object productId) {
    return 'Product \"$productId\" was not loaded from App Store.';
  }

  @override
  String get iosPacksPlanSparkHeadline => 'Start clean and simple';

  @override
  String get iosPacksPlanBoostHeadline => 'Move faster with more flexibility';

  @override
  String get iosPacksPlanPowerHeadline => 'Built for a busier schedule';

  @override
  String get iosPacksPlanPrimeHeadline => 'Full access for your premium flow';

  @override
  String get iosPacksPlanDefaultHeadline =>
      'Choose the plan that fits your workflow';

  @override
  String get iosPacksSubscriptionGeneric => 'subscription';

  @override
  String iosPacksBenefitAppointmentAccess(Object duration) {
    return 'Appointment actions stay active with your $duration plan.';
  }

  @override
  String get iosPacksBenefitSecureCheckout =>
      'Secure checkout is handled directly by Apple.';

  @override
  String get iosPacksBenefitManageSubscription =>
      'Manage renewal and cancellation from your App Store account.';

  @override
  String get iosPacksAppleSubscription => 'Apple subscription';

  @override
  String get iosPacksHeroDescription =>
      'Pick your billing period, review the price, and continue with a secure App Store purchase.';

  @override
  String iosPacksStoreProductUnavailable(Object diagnostic) {
    return 'This App Store product is not available. $diagnostic';
  }

  @override
  String get iosPacksPurchaseStartFailed =>
      'The App Store purchase request could not be started.';

  @override
  String iosPacksPurchaseFailed(Object error) {
    return 'App Store purchase error: $error';
  }

  @override
  String get iosPacksRestoreStarted => 'Restoring Apple purchases...';

  @override
  String iosPacksRestoreFailed(Object error) {
    return 'Restore could not be started: $error';
  }

  @override
  String get iosPacksRestoreSuccess => 'Apple subscription restored.';

  @override
  String get iosPacksPurchaseSuccess =>
      'Apple subscription purchased successfully.';

  @override
  String get iosPacksPurchaseUnknownError => 'The App Store purchase failed.';

  @override
  String get iosPacksPurchaseCancelled => 'Purchase cancelled.';

  @override
  String get iosPacksUnavailableInStore => 'Unavailable in App Store';

  @override
  String get iosPacksDetailsButton => 'Package details';

  @override
  String get iosPacksNoProductsForType =>
      'No products were found for this plan type.';

  @override
  String get iosPacksSelectedPlan => 'Selected plan';

  @override
  String get iosPacksActivationInfo =>
      'Instant activation after Apple purchase';

  @override
  String get iosPacksAgreementDetails => 'Details';

  @override
  String get iosPacksAppointmentPackageInfo =>
      'Appointment actions use package access. SMS balance is only consumed when SMS or reminder sending is enabled.';

  @override
  String get iosPacksLegalConsent =>
      'By continuing, you agree to the Terms of Use and Privacy Policy.';

  @override
  String get iosPacksTermsOfUse => 'Terms of Use';

  @override
  String get iosPacksPrivacyPolicy => 'Privacy Policy';

  @override
  String get iosPacksStoreUnavailableNow =>
      'App Store products are not available right now.';

  @override
  String get iosPacksRestoreInProgress => 'Restoring…';

  @override
  String get iosPacksRestore => 'Restore';

  @override
  String get ordersTitle => 'Orders';

  @override
  String get ordersSessionExpired => 'Session expired, please log in again.';

  @override
  String get ordersSessionMissing => 'Session not found. Please log in again.';

  @override
  String ordersFetchFailedStatus(Object status) {
    return 'Orders could not be fetched (HTTP $status).';
  }

  @override
  String ordersFetchFailed(Object error) {
    return 'Orders could not be fetched: $error';
  }

  @override
  String get ordersRetry => 'Retry';

  @override
  String get ordersEmpty => 'No orders yet.';

  @override
  String get ordersFilterAll => 'All';

  @override
  String get ordersFilterPaid => 'Paid';

  @override
  String get ordersFilterPending => 'Pending';

  @override
  String get ordersFilterFailed => 'Failed';

  @override
  String get ordersPrev => 'Previous';

  @override
  String get ordersNext => 'Next';

  @override
  String ordersPageLabel(Object current, Object total) {
    return 'Page $current / $total';
  }

  @override
  String get ordersPack => 'Pack';

  @override
  String get ordersType => 'Type';

  @override
  String get ordersStatus => 'Status';

  @override
  String get ordersAmount => 'Amount';

  @override
  String get ordersDate => 'Date';

  @override
  String get ordersTxnId => 'Transaction ID';

  @override
  String get ordersPrice => 'Price';

  @override
  String get ordersTax => 'Tax';

  @override
  String get ordersTotal => 'Total';

  @override
  String get ordersDetailTitle => 'Order';

  @override
  String get ordersStatusPaid => 'Paid';

  @override
  String get ordersStatusPending => 'Pending';

  @override
  String get ordersStatusFailed => 'Failed';

  @override
  String get ordersStatusCancelled => 'Cancelled';

  @override
  String get workingPrefsTitle => 'Working Hours';

  @override
  String get workingPrefsSessionMissing =>
      'Session not found. Please log in again.';

  @override
  String workingPrefsLoadFailedStatus(Object status) {
    return 'Working hours could not be loaded (HTTP $status).';
  }

  @override
  String workingPrefsLoadFailed(Object error) {
    return 'Working hours could not be loaded: $error';
  }

  @override
  String get workingPrefsSaveSuccess => 'Saved.';

  @override
  String workingPrefsSaveFailedStatus(Object status) {
    return 'Could not be saved (HTTP $status).';
  }

  @override
  String workingPrefsSaveFailed(Object error) {
    return 'Could not be saved: $error';
  }

  @override
  String get workingPrefsRetry => 'Retry';

  @override
  String get workingPrefsFirstSessionTitle => 'First appointment session count';

  @override
  String get workingPrefsSessionLabel => 'Session';

  @override
  String get workingPrefsSelect => 'Select';

  @override
  String workingPrefsSessionOption(Object count) {
    return '$count Session';
  }

  @override
  String get workingPrefsDaySubtitle => 'Working status and time ranges';

  @override
  String get workingPrefsStatusLabel => 'Status';

  @override
  String get workingPrefsTimeSlotsLabel => 'Time slots';

  @override
  String get workingPrefsWorking => 'Working';

  @override
  String get workingPrefsAddSlot => 'Add time slot';

  @override
  String get workingPrefsStart => 'Start';

  @override
  String get workingPrefsEnd => 'End';

  @override
  String get workingPrefsPeriod => 'Period (minutes)';

  @override
  String get workingPrefsDelete => 'Delete';

  @override
  String get workingPrefsSaving => 'Saving...';

  @override
  String get workingPrefsSave => 'Save';

  @override
  String get workingPrefsHolidaysTitle => 'Holidays';

  @override
  String get workingPrefsHolidaysEmpty => 'No holiday added yet.';

  @override
  String get workingPrefsHolidayAdd => 'Add holiday';

  @override
  String get workingPrefsHolidayStart => 'Start';

  @override
  String get workingPrefsHolidayEnd => 'End';

  @override
  String get workingPrefsHolidayReason => 'Reason (optional)';

  @override
  String get workingPrefsTemplatesTitle => 'Quick Templates';

  @override
  String get workingPrefsTemplatesSubtitle =>
      'Select a template to get started quickly';

  @override
  String get workingPrefsTemplatesApply => 'Apply';

  @override
  String workingPrefsTemplatesApplied(String name) {
    return '$name template applied.';
  }

  @override
  String get workingPrefsTemplatesConfirmTitle => 'Apply Template';

  @override
  String get workingPrefsTemplatesConfirmBody =>
      'Are you sure you want to apply this template? Your current working hours will be replaced.';

  @override
  String get workingPrefsTemplatesCancel => 'Cancel';

  @override
  String get smsTemplatesTitle => 'SMS Templates';

  @override
  String get smsTemplatesSessionMissing =>
      'Session not found. Please log in again.';

  @override
  String smsTemplatesFetchFailedStatus(Object status) {
    return 'Templates could not be loaded (HTTP $status).';
  }

  @override
  String smsTemplatesFetchFailed(Object error) {
    return 'Templates could not be loaded: $error';
  }

  @override
  String get smsTemplatesUpdated => 'SMS templates updated.';

  @override
  String smsTemplatesSaveFailedStatus(Object status) {
    return 'Could not be saved (HTTP $status).';
  }

  @override
  String smsTemplatesSaveFailed(Object error) {
    return 'Could not be saved: $error';
  }

  @override
  String get smsTemplatesSelect => 'Select';

  @override
  String get smsTemplatesNotFound => 'No template found';

  @override
  String get smsTemplatesCustomerTemplates => 'Customer SMS Templates';

  @override
  String smsTemplatesSelectionId(Object id) {
    return 'Selection ID: $id';
  }

  @override
  String get smsTemplatesMain => 'Main Message';

  @override
  String get smsTemplatesReminder => 'Reminder';

  @override
  String get smsTemplatesCancel => 'Cancel';

  @override
  String get smsTemplatesUpdate => 'Update';

  @override
  String get smsTemplatesSave => 'Save';

  @override
  String get smsTemplatesSaving => 'Saving...';

  @override
  String get smsTemplatesRefresh => 'Refresh';

  @override
  String smsTemplatesFallbackTitle(Object id) {
    return 'Template #$id';
  }

  @override
  String get smsTemplatesGuideTitle => 'Template Selection';

  @override
  String get smsTemplatesGuideBody =>
      'Select one SMS template for each category.';

  @override
  String get smsTemplatesGuideHint =>
      'Tap cards to select templates. The selected card is highlighted and reflected in the live preview below.';

  @override
  String get smsTemplatesMainDescription =>
      'Message sent when a new appointment is created.';

  @override
  String get smsTemplatesReminderDescription =>
      'Message sent as a reminder before the appointment.';

  @override
  String get smsTemplatesCancelDescription =>
      'Message sent when an appointment is cancelled.';

  @override
  String get smsTemplatesUpdateDescription =>
      'Message sent when appointment date/time is updated.';

  @override
  String get smsTemplatesPreviewTitle => 'Live Preview';

  @override
  String get smsTemplatesPreviewEmpty =>
      'No template selected for this category yet.';

  @override
  String get smsTemplatesSelected => 'Selected';

  @override
  String get supportTitle => 'Support';

  @override
  String get supportSessionMissing => 'Session not found. Please log in again.';

  @override
  String supportFetchFailedStatus(Object status) {
    return 'Support tickets could not be loaded (HTTP $status).';
  }

  @override
  String supportFetchFailed(Object error) {
    return 'Support tickets could not be loaded: $error';
  }

  @override
  String get supportCreateValidation => 'Title and message are required.';

  @override
  String get supportCreateSuccess => 'Support ticket created.';

  @override
  String supportCreateFailedStatus(Object status) {
    return 'Ticket could not be created (HTTP $status).';
  }

  @override
  String supportCreateFailed(Object error) {
    return 'Ticket could not be created: $error';
  }

  @override
  String get supportRetry => 'Retry';

  @override
  String get supportEmpty => 'You don\'t have any support tickets yet.';

  @override
  String get supportRefresh => 'Refresh';

  @override
  String get supportNewTicket => 'New Support Ticket';

  @override
  String get supportTitleLabel => 'Title';

  @override
  String get supportMessageLabel => 'Your message';

  @override
  String get supportSending => 'Sending...';

  @override
  String get supportSend => 'Send';

  @override
  String get supportTickets => 'Support Tickets';

  @override
  String get supportMessagesCount => 'Messages';

  @override
  String get supportTicketDetail => 'Support Detail';

  @override
  String get supportTicketNotFound => 'Ticket not found.';

  @override
  String get supportMessages => 'Messages';

  @override
  String get supportStatusClosing => 'Closing';

  @override
  String get supportCloseTicket => 'Close Ticket';

  @override
  String supportCreatedAt(Object date) {
    return 'Created: $date';
  }

  @override
  String get supportSenderYou => 'You';

  @override
  String get supportSenderSupport => 'Support';

  @override
  String get supportNoMessages => 'No messages yet.';

  @override
  String get supportReplyPlaceholder => 'Your message';

  @override
  String get supportReplyClosed =>
      'This ticket is closed; you cannot send new messages.';

  @override
  String get supportReplySending => 'Sending...';

  @override
  String get supportReplySend => 'Send Reply';

  @override
  String get supportReplyEmpty => 'Message cannot be empty.';

  @override
  String get supportReplySuccess => 'Reply sent.';

  @override
  String supportReplyFailedStatus(Object status) {
    return 'Reply could not be sent (HTTP $status).';
  }

  @override
  String supportReplyFailed(Object error) {
    return 'Reply could not be sent: $error';
  }

  @override
  String get supportCloseSuccess => 'Ticket closed.';

  @override
  String supportCloseFailedStatus(Object status) {
    return 'Ticket could not be closed (HTTP $status).';
  }

  @override
  String supportCloseFailed(Object error) {
    return 'Ticket could not be closed: $error';
  }

  @override
  String supportMessagesMeta(Object count, Object date) {
    return '$count messages • $date';
  }

  @override
  String get supportStatusOpen => 'Open';

  @override
  String get supportStatusPending => 'Pending';

  @override
  String get supportStatusClosed => 'Closed';

  @override
  String get supportPriority => 'Priority';

  @override
  String get profileLanguage => 'App Language';

  @override
  String get profileLanguageEnglish => 'English';

  @override
  String get profileLanguageSaved => 'Language updated.';

  @override
  String get profileDeleteSectionTitle => 'Delete Account';

  @override
  String get profileDeleteSectionSubtitle => 'This action cannot be undone.';

  @override
  String get profileDeleteConfirmTitle => 'Delete account';

  @override
  String get profileDeleteConfirmBody =>
      'Are you sure you want to delete your account? This action cannot be undone.';

  @override
  String get profileDeleteCancel => 'Cancel';

  @override
  String get profileDeleteAction => 'Delete account';

  @override
  String get profileDeleteProcessing => 'Processing...';

  @override
  String get profileDeleteSuccess => 'Account removed successfully.';

  @override
  String get profileDeleteFailed => 'Account deletion request failed.';

  @override
  String profileDeleteError(Object error) {
    return 'An error occurred while deleting the account: $error';
  }

  @override
  String get dashboardNoActivePackage =>
      'You don\'t have an active package. Please buy a package for SMS operations.';

  @override
  String get dashboardBuyPackage => 'Buy Package';

  @override
  String get aiProfileBannerBadge => 'Liik AI Assistant';

  @override
  String get aiProfileBannerTitle => 'Create AI Profile';

  @override
  String get aiProfileBannerDesc =>
      'AI writes the profile that turns your followers into appointments — you just share your expertise.';

  @override
  String get aiProfileTitle => 'AI Profile';

  @override
  String get aiProfileAiBadge => 'Liik AI Assistant';

  @override
  String get aiProfileSubtitle => 'Build your professional profile in seconds';

  @override
  String get aiProfileLoading => 'Loading AI Profile...';

  @override
  String get aiProfileRetry => 'Try Again';

  @override
  String get aiProfileSave => 'Save';

  @override
  String get aiProfileSaving => 'Saving...';

  @override
  String get aiProfileTabProfile => 'Profile';

  @override
  String get aiProfileTabLinks => 'Links';

  @override
  String get aiProfileTabTheme => 'Theme';

  @override
  String get aiProfileRemainingNone => 'Done';

  @override
  String get aiProfileGenerateTitle => 'Generate with AI';

  @override
  String get aiProfileGenerateSubtitle =>
      'Fill in your details and let AI create your profile';

  @override
  String get aiProfileGenerateButton => 'Generate with AI';

  @override
  String get aiProfileGenerating => 'Generating...';

  @override
  String get aiProfileGenerateLocked => 'No AI generation credits left';

  @override
  String get aiProfileGenerateSuccess => 'Your profile is ready!';

  @override
  String get aiProfileGenerateSuccessHint => 'You can edit the content below';

  @override
  String get aiProfileMsgAnalyzing => 'Analyzing your profile...';

  @override
  String get aiProfileMsgPreparing => 'Crafting content for your profession...';

  @override
  String get aiProfileMsgSelecting => 'Picking the best expressions...';

  @override
  String get aiProfileMsgSeo => 'Applying SEO optimization...';

  @override
  String get aiProfileMsgFinalizing => 'Adding the finishing touches...';

  @override
  String get aiProfileMsgWait => 'This may take a few seconds';

  @override
  String get aiProfileFieldProfession => 'Profession *';

  @override
  String get aiProfileFieldProfessionError => 'Please select a profession';

  @override
  String get aiProfileFieldExpertise => 'Area of Expertise *';

  @override
  String get aiProfileFieldExpertiseHint =>
      'Sports nutrition, weight management';

  @override
  String get aiProfileFieldExpertiseError => 'Required field';

  @override
  String get aiProfileFieldAudience => 'Target Audience *';

  @override
  String get aiProfileFieldAudienceHint => 'Adults who want to get fit';

  @override
  String get aiProfileFieldAudienceError => 'Required field';

  @override
  String get aiProfileFieldExperience => 'Experience (years)';

  @override
  String get aiProfileFieldExperienceHint => '0–50';

  @override
  String get aiProfileFieldExperienceError => 'Must be between 0 and 50';

  @override
  String get aiProfileFieldTone => 'Tone';

  @override
  String get aiProfileFieldAchievement => 'Achievement / Membership';

  @override
  String get aiProfileFieldAchievementHint => 'Professional association';

  @override
  String get aiProfileFieldNote => 'Additional Note';

  @override
  String get aiProfileFieldNoteHint => 'Keep it short and clear';

  @override
  String get aiProfileFieldBio => 'Bio / Description (min 20 chars)';

  @override
  String get aiProfileFieldFooter => 'Footer';

  @override
  String get aiProfileSectionSeo => 'SEO Settings';

  @override
  String get aiProfileFieldSeoTitle => 'SEO Title (max 70)';

  @override
  String get aiProfileFieldSeoDesc => 'Meta Description (max 170)';

  @override
  String get aiProfileFieldSeoKeywords =>
      'Keywords — separate with commas (max 300)';

  @override
  String get aiProfileLinksSubtitle => 'Add URLs and toggle them on or off.';

  @override
  String get aiProfileLinksSave => 'Save Links';

  @override
  String get aiProfileLinksSaving => 'Saving...';

  @override
  String get aiProfileThemeNoPreview => 'Select a theme.';

  @override
  String get aiProfileThemeNoUser => 'Could not load user info.';

  @override
  String get aiProfileReminderTitle =>
      'Content is ready — don\'t forget to save!';

  @override
  String get aiProfileReminderSubtitle =>
      'Tap the Save button in the top right';

  @override
  String get aiProfileSaveSuccess => 'Saved!';

  @override
  String get aiProfileSaveBioMin => 'Bio must be at least 20 characters.';

  @override
  String get aiProfileThemeApplied => 'Theme applied.';

  @override
  String get aiProfileLinksSaved => 'Links saved.';

  @override
  String get aiProfileLimitReached => 'Daily AI limit reached.';

  @override
  String get aiProfileValidationErrors => 'Please fix the errors in the form.';

  @override
  String get aiProfileSessionMissing =>
      'Session not found. Please log in again.';

  @override
  String aiProfileRemainingCount(Object count) {
    return '$count left';
  }

  @override
  String aiProfileFetchError(Object status) {
    return 'Could not load data (HTTP $status).';
  }

  @override
  String aiProfileConnectionError(Object error) {
    return 'Connection error: $error';
  }

  @override
  String aiProfileGenerateHttpError(Object status) {
    return 'Generation failed (HTTP $status).';
  }

  @override
  String aiProfileSaveHttpError(Object status) {
    return 'Save failed (HTTP $status).';
  }

  @override
  String aiProfileThemeHttpError(Object status) {
    return 'Could not save theme (HTTP $status).';
  }

  @override
  String aiProfileLinksHttpError(Object status) {
    return 'Could not save links (HTTP $status).';
  }

  @override
  String get onboardBadge1 => 'A SPACE OF YOUR OWN';

  @override
  String get onboardBadge2 => 'SIMPLER SCHEDULING';

  @override
  String get onboardBadge3 => 'READY TO SHARE';

  @override
  String get onboardSkip => 'Skip';

  @override
  String get onboardContinue => 'Continue';

  @override
  String get onboardStart => 'Get started with Liik';

  @override
  String get onboardLogin => 'Already have an account? Log in';

  @override
  String get onboardPreviewName => 'Hi, I’m Alex';

  @override
  String get onboardPreviewTagline => 'Creating. Sharing. Connecting.';

  @override
  String get onboardPreviewExplore => 'Explore my world';

  @override
  String get onboardPreviewBook => 'Let’s find a time';

  @override
  String get onboardPreviewCall => 'Discovery call';

  @override
  String get onboardPreviewDuration => '30 min · Online';

  @override
  String get onboardPreviewReady => 'Your bio link is ready';

  @override
  String get onboardPreviewShareHint =>
      'Add it to your profile. Get discovered.';

  @override
  String get onboardPreviewConnections => 'One link. New connections.';

  @override
  String get loginSubtitle =>
      'Sign in to your account and pick up where you left off';

  @override
  String get loginOr => 'or';

  @override
  String get loginNoAccount => 'Don’t have an account?';

  @override
  String get registerTitle => 'Create account';

  @override
  String get registerConfirmPassword => 'Confirm password';

  @override
  String get registerUsername => 'Username (optional)';

  @override
  String get registerSubmit => 'Sign up';

  @override
  String get registerError => 'An error occurred during registration.';

  @override
  String get authTokenMissing => 'Could not retrieve the sign-in token.';

  @override
  String get authUnauthorized => 'Sign-in was not authorized.';

  @override
  String get authGoogleCancelled => 'Google sign-in was cancelled.';

  @override
  String get authGoogleTokenMissing =>
      'Could not retrieve the Google sign-in token.';

  @override
  String get verifyEmailPending => 'Email not verified yet. Check your inbox.';

  @override
  String get authConnectionError => 'Could not connect to the server.';

  @override
  String get verifyEmailResent => 'Verification email sent again.';

  @override
  String get commonSendFailed => 'Could not send.';

  @override
  String get verifyEmailTitle => 'Verify your email';

  @override
  String get verifyEmailCheck => 'I’ve verified my email';

  @override
  String get verifyEmailResend => 'Resend';

  @override
  String get verifyEmailOtherAccount => 'Sign in with a different account';

  @override
  String get dashboardImageFailed => 'Could not create the image.';

  @override
  String get commonNoResults => 'No results found';

  @override
  String get dashboardPackageActivated => 'Your package is active! 🎉';

  @override
  String get commonError => 'Something went wrong.';

  @override
  String get dashboardWelcomeGiftTitle => 'Claim your welcome gift';

  @override
  String get dashboardWelcomeGiftDescription =>
      'Complete the form to activate 100 free SMS for one month.';

  @override
  String get commonChoose => 'Select...';

  @override
  String get dashboardCityRequired => 'City *';

  @override
  String get dashboardCityHint => 'e.g. New York';

  @override
  String get dashboardInstagramOptional => 'Instagram (optional)';

  @override
  String get dashboardActivatePackage => 'Activate package';

  @override
  String get dashboardWelcomeGiftBadge => 'WELCOME GIFT';

  @override
  String get dashboardWelcomeGiftOffer => '100 free SMS for one month';

  @override
  String get dashboardWelcomeGiftHint =>
      'Your gift is waiting. Complete the form to activate it.';

  @override
  String get dashboardReviewTitle => 'Enjoying Liik?';

  @override
  String get dashboardReviewHint => 'Your review helps us grow.';

  @override
  String get dashboardReviewAction => 'Rate Liik';

  @override
  String get commonView => 'View';

  @override
  String get dashboardTopUp => 'Top up';

  @override
  String get dashboardFeedbackTitle => 'How is your Liik experience?';

  @override
  String get dashboardFeedbackHint =>
      'Share your experience to help us improve.';

  @override
  String get dashboardFeedbackComment => 'Your comment (optional)...';

  @override
  String get dashboardFeedbackSubmit => 'Submit review';

  @override
  String get commonNotNow => 'Not now';

  @override
  String get ratingVeryBad => 'Very bad';

  @override
  String get ratingBad => 'Bad';

  @override
  String get ratingGood => 'Good';

  @override
  String get ratingExcellent => 'Excellent!';

  @override
  String get ratingSelect => 'Select a rating';

  @override
  String get workingTemplateAfternoon => 'Afternoon';

  @override
  String get workingTemplateEvening => 'Evening';

  @override
  String get announcementWarning => 'Warning';

  @override
  String get announcementUpdate => 'Update';

  @override
  String get announcementConnectionError => 'Connection error.';

  @override
  String get announcementReadAll => 'Mark all as read';

  @override
  String get announcementEmpty => 'No announcements yet';

  @override
  String get announcementDownload => 'Download update';

  @override
  String get blogTitle => 'Articles';

  @override
  String get blogViewAll => 'View all';

  @override
  String get blogLoadFailed => 'Could not load articles.';

  @override
  String get commonAll => 'All';

  @override
  String get blogEmptyCategory => 'No articles in this category yet';

  @override
  String get blogReadMore => 'Read more';

  @override
  String get aiProfileBioPreview => 'Bio page preview';

  @override
  String get aiProfileConversionPage => 'My booking page';

  @override
  String get aiProfileConversionHint => 'Turn followers into bookings';

  @override
  String get aiProfilePageTitle => 'Page title';

  @override
  String get aiProfileMetaPlaceholder =>
      'Your meta description appears here. Describe your page for search results.';

  @override
  String get aiProfileGooglePreview => 'Google search preview';

  @override
  String get aiProfileSeoWeak => 'Weak';

  @override
  String get aiProfileSeoExcellent => 'Excellent';

  @override
  String get aiProfileThemeAutoSave => 'Tap a theme to save it automatically';

  @override
  String get aiProfileEditLinks => 'Edit my links';

  @override
  String get aiProfilePreviewLoading => 'Loading preview...';

  @override
  String get aiProfilePreviewFailed => 'Could not load preview';

  @override
  String get professionTrainer => 'Personal trainer';

  @override
  String get professionBeautician => 'Beauty professional';

  @override
  String get professionCoach => 'Coach & consultant';

  @override
  String get aiProfileProfessionTemplate => 'Quick start for your profession';

  @override
  String get aiProfileReorderLinks => 'Drag and drop to reorder active links';

  @override
  String get appointmentDateTimeHeading => 'DATE & TIME';

  @override
  String authRegisterFailed(int status) {
    return 'Registration failed (HTTP $status).';
  }

  @override
  String authLoginFailed(int status) {
    return 'Sign-in failed (HTTP $status).';
  }

  @override
  String authGoogleFailed(int status) {
    return 'Google sign-in failed (HTTP $status).';
  }

  @override
  String authConnectionFailed(String error) {
    return 'Could not connect to the server: $error';
  }

  @override
  String authGoogleError(String error) {
    return 'Google sign-in failed: $error';
  }

  @override
  String authAppleError(String error) {
    return 'Apple sign-in failed: $error';
  }

  @override
  String verifyEmailFailed(int status) {
    return 'Could not check verification (HTTP $status).';
  }

  @override
  String verifyEmailDescription(String email) {
    return 'We sent a verification link to $email. Open the link, then tap the button below.';
  }

  @override
  String verifyEmailResendCountdown(int seconds) {
    return 'Resend (${seconds}s)';
  }

  @override
  String get announcementInfo => 'Info';

  @override
  String get announcementPromo => 'Offer';

  @override
  String get announcementFeature => 'New feature';

  @override
  String get announcementTitle => 'Announcement';

  @override
  String get announcementsTitle => 'Announcements';

  @override
  String get ratingAverage => 'Average';

  @override
  String get workingTemplateStandard => 'Standard';

  @override
  String get workingTemplateExpert => 'Expert';

  @override
  String get workingTemplateWeekend => 'Weekend';

  @override
  String get professionDietitian => 'Dietitian';

  @override
  String get professionPsychologist => 'Psychologist';

  @override
  String get professionPhysiotherapist => 'Physiotherapist';

  @override
  String get aiToneFriendly => 'Friendly';

  @override
  String get aiToneFriendlyHint => 'Warm, natural language';

  @override
  String get aiToneProfessional => 'Professional';

  @override
  String get aiToneProfessionalHint => 'Formal and reassuring';

  @override
  String get aiToneWarm => 'Warm';

  @override
  String get aiToneWarmHint => 'Empathetic and approachable';

  @override
  String get linkLocation => 'Location';

  @override
  String get linkWebsite => 'Website';

  @override
  String previewLoadError(String error) {
    return 'Could not load preview: $error';
  }

  @override
  String announcementLoadFailed(int status) {
    return 'Could not load announcements (HTTP $status).';
  }

  @override
  String announcementMinutesAgo(int count) {
    return '$count min ago';
  }

  @override
  String announcementHoursAgo(int count) {
    return '$count hr ago';
  }

  @override
  String announcementDaysAgo(int count) {
    return '$count days ago';
  }

  @override
  String dashboardLowSms(int count) {
    return 'Your SMS balance is low — $count messages left.';
  }

  @override
  String get workingTemplateStandardDescription =>
      'Mon–Fri 09:00–12:00 / 13:00–17:00 · 20 min';

  @override
  String get workingTemplateAfternoonDescription =>
      'Mon–Fri 13:00–17:00 · 20 min';

  @override
  String get workingTemplateExpertDescription =>
      'Mon–Sat 09:00–12:00 / 13:00–17:00 · 20 min';

  @override
  String get workingTemplateEveningDescription =>
      'Mon–Sat 17:00–21:00 · 45 min';

  @override
  String get workingTemplateWeekendDescription =>
      'Sat–Sun 10:00–17:00 · 30 min';

  @override
  String get loginWelcome => 'Welcome back.';

  @override
  String get loginWelcomeDescription =>
      'Your links, your bookings, your next connection. All in one place.';

  @override
  String get loginEmailHint => 'you@example.com';

  @override
  String get loginPasswordHint => 'Enter your password';

  @override
  String get loginShowPassword => 'Show password';

  @override
  String get loginHidePassword => 'Hide password';

  @override
  String get loginEmailValidation => 'Enter a valid email address.';

  @override
  String get loginPasswordValidation => 'Enter your password.';

  @override
  String get loginApple => 'Sign in with Apple';

  @override
  String get dashboardWelcome => 'Your day, connected.';

  @override
  String get dashboardBioHint =>
      'One link for your world. Share it wherever people find you.';

  @override
  String get dashboardCopyLink => 'Copy link';

  @override
  String get dashboardBioEmptyTitle => 'Your next connection starts here.';

  @override
  String get dashboardBioEmptyHint =>
      'Create your Liik page to bring your links and bookings together.';

  @override
  String get dashboardScheduleEmptyHint =>
      'A little room in your day. Add an appointment or share your booking page.';

  @override
  String get dashboardViewAppointments => 'View appointments';

  @override
  String dashboardAnnouncements(int count) {
    return '$count new announcements';
  }

  @override
  String get appointmentsHeading => 'A little more organized.';

  @override
  String get appointmentsInView => 'In this view';

  @override
  String get appointmentsPlanRequired =>
      'Your current plan does not include appointment management.';

  @override
  String get calendarLoadError => 'Could not load this week. Please try again.';

  @override
  String get contactsSubtitle =>
      'Your people, all in one place. Keep details and appointments together.';

  @override
  String get contactsAll => 'All';

  @override
  String contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contacts',
      one: '1 contact',
    );
    return '$_temp0';
  }

  @override
  String get contactsNoResults =>
      'No matching contacts. Try another name, phone number or email.';

  @override
  String get contactsLoadError => 'Could not load contacts. Please try again.';

  @override
  String get contactsSaveError =>
      'Could not save this contact. Please try again.';

  @override
  String get contactsPhoneInvalid =>
      'Enter a valid phone number with up to 15 digits.';

  @override
  String get contactsEmailInvalid => 'Enter a valid email address.';

  @override
  String get linksSubtitle =>
      'Your links, your way. Bring everything you share onto your Liik page.';

  @override
  String get linksFormSubtitle =>
      'Choose a link type, add a destination and make it yours.';

  @override
  String get linksOrderHint =>
      'Drag the handle to change the order on your page.';

  @override
  String get linksOrderError =>
      'Could not save the order. Your previous order has been restored.';

  @override
  String get linksLoadError => 'Could not load your links.';

  @override
  String get linksRetryHint => 'Please check your connection and try again.';

  @override
  String get linksSettingsError =>
      'Link types and colors could not be loaded. Please try again.';

  @override
  String get linksDeleteTitle => 'Delete this link?';

  @override
  String get linksDeleteBody =>
      'This link will be removed from your Liik page.';

  @override
  String get linksDestinationRequired => 'Enter a destination for this link.';

  @override
  String get linksTextTooLong => 'Use 255 characters or fewer.';

  @override
  String get linksMoveUp => 'Move up';

  @override
  String get linksMoveDown => 'Move down';

  @override
  String get linksDrag => 'Drag to reorder';

  @override
  String get linksActions => 'Link actions';

  @override
  String get themesSubtitle =>
      'Make your Liik page feel like you. Choose a theme and preview your look.';

  @override
  String get themesCurrent => 'Current theme';

  @override
  String get themesUnsaved => 'Previewing a new theme · not saved yet';

  @override
  String get themesApplied => 'Theme applied';

  @override
  String get themesRefreshPreview => 'Refresh preview';

  @override
  String get themesLoadError => 'Could not load themes. Please try again.';

  @override
  String get themesSaveErrorMessage =>
      'Could not save this theme. Please try again.';

  @override
  String get themesViewPreview => 'View preview';

  @override
  String get profileTimezone => 'Local time zone';

  @override
  String get profileTimezoneHint =>
      'Your appointments and working hours use this time zone. Daylight saving changes are handled automatically.';

  @override
  String get profileTimezoneSearch => 'Search city or time zone';

  @override
  String get profileTimezoneLoadError =>
      'Could not load time zones. Please try again.';

  @override
  String get supportSubtitle =>
      'Need a hand? Talk to us and keep track of your support requests here.';

  @override
  String get supportFormHint => 'Tell us what happened and how we can help.';

  @override
  String get supportActive => 'Active';

  @override
  String get supportFinished => 'Resolved & closed';

  @override
  String get supportFilterEmpty => 'No requests in this category.';

  @override
  String get supportLoadError =>
      'Could not load support requests. Please try again.';

  @override
  String get supportSendError =>
      'Could not send your message. Please try again.';

  @override
  String get supportCloseError =>
      'Could not close this request. Please try again.';

  @override
  String get supportMessageTooShort => 'Write at least 5 characters.';

  @override
  String get supportReplyTooShort => 'Write at least 2 characters.';

  @override
  String get supportCloseConfirm =>
      'Close this request? You will no longer be able to reply to it.';

  @override
  String get supportInProgress => 'In progress';

  @override
  String get supportResolved => 'Resolved';

  @override
  String get supportPriorityLow => 'Low priority';

  @override
  String get supportPriorityMedium => 'Normal priority';

  @override
  String get supportPriorityHigh => 'High priority';

  @override
  String get supportPriorityUrgent => 'Urgent';

  @override
  String get analyticsTitle => 'Analytics';

  @override
  String get analyticsIntro =>
      'See how people discover your profile and interact with your links.';

  @override
  String get analyticsPeriod => 'Reporting period';

  @override
  String analyticsDays(int count) {
    return '$count days';
  }

  @override
  String get analyticsOverview => 'Overview';

  @override
  String get analyticsLinks => 'Link performance';

  @override
  String get analyticsAudience => 'Audience';

  @override
  String get analyticsConversions => 'Click-through';

  @override
  String get analyticsClicks => 'Link clicks';

  @override
  String get analyticsVisitors => 'Unique visitors';

  @override
  String get analyticsUniqueClicks => 'Unique clickers';

  @override
  String get analyticsRate => 'Click-through rate';

  @override
  String get analyticsRedirects => 'Redirect page views';

  @override
  String get analyticsPrevious => 'vs. previous period';

  @override
  String get analyticsNoPrevious => 'No previous baseline';

  @override
  String get analyticsUnchanged => 'No change';

  @override
  String get analyticsTrend => 'Daily link clicks';

  @override
  String get analyticsTrendHint =>
      'Total clicks and unique clickers for each day.';

  @override
  String get analyticsEmpty => 'No activity in this period';

  @override
  String get analyticsEmptyText =>
      'Visits and link clicks will appear here as people use your profile.';

  @override
  String get analyticsTopLinks => 'Top links';

  @override
  String get analyticsLink => 'Link';

  @override
  String get analyticsShare => 'Share of clicks';

  @override
  String get analyticsNoLinks => 'No link clicks yet.';

  @override
  String get analyticsViews => 'Visitors';

  @override
  String get analyticsFunnel => 'From profile to links';

  @override
  String get analyticsFunnelHint =>
      'Unique visitors and unique clickers are counted separately for the selected period.';

  @override
  String get analyticsManual => 'Manual';

  @override
  String get analyticsAutomatic => 'Automatic';

  @override
  String get analyticsNavigation => 'Navigation methods';

  @override
  String get analyticsNavigationHint =>
      'How visitors move from redirect pages to destinations.';

  @override
  String get analyticsSources => 'Traffic sources';

  @override
  String get analyticsDevices => 'Devices';

  @override
  String get analyticsPlatforms => 'Platforms';

  @override
  String get analyticsBrowsers => 'Browsers';

  @override
  String get analyticsCountries => 'Countries';

  @override
  String get analyticsHours => 'Clicks by hour';

  @override
  String get analyticsWeekdays => 'Clicks by weekday';

  @override
  String get analyticsUnknown => 'Unknown';

  @override
  String get analyticsMobile => 'Mobile';

  @override
  String get analyticsDesktop => 'Desktop';

  @override
  String get analyticsTablet => 'Tablet';

  @override
  String analyticsTimezone(String timezone) {
    return 'Report time zone: $timezone';
  }

  @override
  String get analyticsDataNote =>
      'Only recorded activity is included. Unique metrics use anonymous visitor identifiers.';

  @override
  String get analyticsRateNote =>
      'Unique clickers divided by unique profile visitors. This measures link engagement.';

  @override
  String get analyticsLoadError =>
      'Could not load analytics. Please try again.';

  @override
  String get themesFree => 'Free';

  @override
  String get themesPremium => 'Premium';

  @override
  String get themesClassic => 'Classic';

  @override
  String get appointmentShare => 'Share appointment';

  @override
  String get appointmentCopyLink => 'Copy link';

  @override
  String get appointmentLinkCopied => 'Link copied';

  @override
  String get appointmentCode => 'Appointment code';

  @override
  String get appointmentDetails => 'Appointment details';

  @override
  String get appointmentNotes => 'Notes';

  @override
  String get appointmentStatusLabel => 'Status';

  @override
  String get appointmentOpenCalendar => 'View appointment / add to calendar';

  @override
  String get appointmentHistory => 'Appointment history';

  @override
  String get appointmentShareFailed =>
      'Could not share the appointment. Try copying the link.';

  @override
  String get appointmentTimezone => 'Time zone';

  @override
  String get calendarSubtitle =>
      'Plan your week, view appointment details and share bookings.';

  @override
  String get profileDesignIntro =>
      'Make your profile yours. Manage your details, visibility and account settings.';
}

/// The translations for English, as used in the United Kingdom (`en_GB`).
class AppLocalizationsEnGb extends AppLocalizationsEn {
  AppLocalizationsEnGb() : super('en_GB');

  @override
  String get myLinksColorLabel => 'Colour';

  @override
  String myLinksColorFallback(Object id) {
    return 'Colour #$id';
  }

  @override
  String get myLinksDebugNoColors => '⚠️ Colour list returned empty.';

  @override
  String get aiProfileMsgAnalyzing => 'Analysing your profile...';

  @override
  String get aiProfileMsgSeo => 'Applying SEO optimisation...';

  @override
  String get appointmentShare => 'Share appointment';

  @override
  String get appointmentCopyLink => 'Copy link';

  @override
  String get appointmentLinkCopied => 'Link copied';

  @override
  String get appointmentCode => 'Appointment code';

  @override
  String get appointmentDetails => 'Appointment details';

  @override
  String get appointmentNotes => 'Notes';

  @override
  String get appointmentStatusLabel => 'Status';

  @override
  String get appointmentOpenCalendar => 'View appointment / add to calendar';

  @override
  String get appointmentHistory => 'Appointment history';

  @override
  String get appointmentShareFailed =>
      'Could not share the appointment. Try copying the link.';

  @override
  String get appointmentTimezone => 'Time zone';

  @override
  String get calendarSubtitle =>
      'Plan your week, view appointment details and share bookings.';

  @override
  String get profileDesignIntro =>
      'Make your profile yours. Manage your details, visibility and account settings.';
}

/// The translations for English, as used in the United States (`en_US`).
class AppLocalizationsEnUs extends AppLocalizationsEn {
  AppLocalizationsEnUs() : super('en_US');

  @override
  String get appointmentShare => 'Share appointment';

  @override
  String get appointmentCopyLink => 'Copy link';

  @override
  String get appointmentLinkCopied => 'Link copied';

  @override
  String get appointmentCode => 'Appointment code';

  @override
  String get appointmentDetails => 'Appointment details';

  @override
  String get appointmentNotes => 'Notes';

  @override
  String get appointmentStatusLabel => 'Status';

  @override
  String get appointmentOpenCalendar => 'View appointment / add to calendar';

  @override
  String get appointmentHistory => 'Appointment history';

  @override
  String get appointmentShareFailed =>
      'Could not share the appointment. Try copying the link.';

  @override
  String get appointmentTimezone => 'Time zone';

  @override
  String get calendarSubtitle =>
      'Plan your week, view appointment details and share bookings.';

  @override
  String get profileDesignIntro =>
      'Make your profile yours. Manage your details, visibility and account settings.';
}

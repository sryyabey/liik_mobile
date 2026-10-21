// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get loginTitle => 'Entrar';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get passwordLabel => 'Senha';

  @override
  String get facebookLogin => 'Continuar com Facebook';

  @override
  String get googleLogin => 'Continuar com Google';

  @override
  String get onboardTitle1 => 'Seu mundo.\nUm só link.';

  @override
  String get onboardDesc1 =>
      'Reúna seus links, serviços e tudo o que faz de você quem você é na sua página Liik.';

  @override
  String get onboardTitle2 =>
      'Seu próximo agendamento.\nA um toque de distância.';

  @override
  String get onboardDesc2 =>
      'Compartilhe seus horários disponíveis. Deixe os visitantes escolherem o melhor horário enquanto você cuida do seu dia.';

  @override
  String get onboardTitle3 => 'Mostre quem você é.\nCrie conexões.';

  @override
  String get onboardDesc3 =>
      'Crie uma página com a sua cara, compartilhe seu bio link e conecte-se com novas pessoas.';

  @override
  String get menuTitle => 'Menu';

  @override
  String get myLinks => 'Meus links';

  @override
  String get customersTitle => 'Meus contatos';

  @override
  String get customersSessionMissing =>
      'Sessão não encontrada. Entre novamente.';

  @override
  String customersLoadFailedStatus(Object status) {
    return 'Não foi possível carregar os contatos (HTTP $status).';
  }

  @override
  String customersLoadFailed(Object error) {
    return 'Não foi possível carregar os contatos: $error';
  }

  @override
  String get customersSearchHint => 'Buscar contato (nome, telefone, e-mail)';

  @override
  String get customersRetry => 'Tentar novamente';

  @override
  String get customersEmpty => 'Nenhum contato ainda.';

  @override
  String get customersLoadMore => 'Carregar mais';

  @override
  String get customersRefresh => 'Atualizar';

  @override
  String get customersAdd => 'Adicionar contato';

  @override
  String get customersEdit => 'Editar contato';

  @override
  String get customersAddSubtitle => 'Adicionar um novo contato';

  @override
  String get customersEditSubtitle => 'Editar dados do contato';

  @override
  String get customersDelete => 'Excluir';

  @override
  String get customersDeleteConfirmTitle => 'Excluir contato?';

  @override
  String get customersDeleteConfirmBody =>
      'Tem certeza de que deseja excluir este contato?';

  @override
  String get customersCancel => 'Cancelar';

  @override
  String get customersSave => 'Salvar';

  @override
  String get customersSaving => 'Salvando...';

  @override
  String get customersName => 'Nome completo';

  @override
  String get customersPhone => 'Telefone';

  @override
  String get customersEmail => 'E-mail';

  @override
  String get customersAddress => 'Endereço';

  @override
  String get customersNotes => 'Observações';

  @override
  String get customersValidation =>
      'Nome completo e telefone são obrigatórios.';

  @override
  String get customersCreateSuccess => 'Contato criado.';

  @override
  String get customersUpdateSuccess => 'Contato atualizado.';

  @override
  String customersSaveFailedStatus(Object status) {
    return 'Não foi possível salvar (HTTP $status).';
  }

  @override
  String customersSaveFailed(Object error) {
    return 'Não foi possível salvar: $error';
  }

  @override
  String get customersDeleteSuccess => 'Contato excluído.';

  @override
  String customersDeleteFailedStatus(Object status) {
    return 'Não foi possível excluir o contato (HTTP $status).';
  }

  @override
  String customersDeleteFailed(Object error) {
    return 'Não foi possível excluir o contato: $error';
  }

  @override
  String get customersAppointments => 'Agendamentos';

  @override
  String get customersNoAppointments => 'Nenhum agendamento para este contato.';

  @override
  String customersAppointmentsLoadFailedStatus(Object status) {
    return 'Não foi possível carregar os agendamentos (HTTP $status).';
  }

  @override
  String customersAppointmentsLoadFailed(Object error) {
    return 'Não foi possível carregar os agendamentos: $error';
  }

  @override
  String get customersCreateAppointment => 'Adicionar agendamento';

  @override
  String get customersAppointmentDate => 'Data';

  @override
  String get customersAppointmentTime => 'Horário';

  @override
  String get customersAppointmentNote => 'Observação';

  @override
  String get customersAppointmentNoteHint =>
      'Adicione uma observação ao agendamento...';

  @override
  String customersEmptyForLetter(Object letter) {
    return 'Nenhum contato começando com \"$letter\" foi encontrado.';
  }

  @override
  String get customersFirstAppointment => 'Primeiro agendamento?';

  @override
  String get customersNoSms => 'Não enviar SMS';

  @override
  String get customersNoReminder => 'Não enviar lembrete';

  @override
  String get customersCreateAppointmentSuccess => 'Agendamento criado.';

  @override
  String get customersCreateAppointmentFailed =>
      'Não foi possível criar o agendamento.';

  @override
  String get themes => 'Temas';

  @override
  String get profile => 'Perfil';

  @override
  String get support => 'Suporte';

  @override
  String get exit => 'Sair';

  @override
  String get loginButton => 'Entrar';

  @override
  String get dashboardTitle => 'Painel de controle';

  @override
  String get dashboardHeroSubtitle =>
      'Gerencie seus links e agendamentos em um só lugar.';

  @override
  String get dashboardQuickActions => 'Ações rápidas';

  @override
  String get dashboardMenuMain => 'MENU PRINCIPAL';

  @override
  String get dashboardMenuManagement => 'GERENCIAMENTO';

  @override
  String get dashboardDrawerSubtitle =>
      'Gerencie seus agendamentos e contatos aqui';

  @override
  String get dashboardTopClicks => 'Total de cliques';

  @override
  String get dashboardRemainingSms => 'SMS restantes';

  @override
  String get dashboardBioPage => 'Sua página de bio';

  @override
  String get dashboardLinkCopied => 'Link copiado.';

  @override
  String get dashboardShare => 'Compartilhar';

  @override
  String get dashboardDownload => 'Baixar';

  @override
  String get dashboardQr => 'QR';

  @override
  String get dashboardPackageInfo => 'Informações do pacote';

  @override
  String get dashboardPackageName => 'Nome do pacote';

  @override
  String get dashboardStart => 'Início';

  @override
  String get dashboardEnd => 'Fim';

  @override
  String get dashboardDailyClicks => 'Cliques diários';

  @override
  String get dashboardTopLinks => 'Links mais clicados';

  @override
  String get dashboardNoClicks => 'Nenhum dado de cliques ainda.';

  @override
  String get dashboardNoLinkClicks => 'Nenhum clique em links ainda.';

  @override
  String get dashboardTodayAppointments => 'Agendamentos de hoje';

  @override
  String dashboardTodayCount(Object count) {
    return '$count hoje';
  }

  @override
  String get dashboardNoAppointmentsData =>
      'Nenhum dado de agendamento para hoje.';

  @override
  String get dashboardNoAppointments => 'Nenhum agendamento para hoje.';

  @override
  String dashboardCustomerFallback(Object id) {
    return 'Cliente #$id';
  }

  @override
  String get dashboardCalendar => 'Calendário';

  @override
  String get dashboardAppointments => 'Agendamentos';

  @override
  String get dashboardHome => 'Início';

  @override
  String get dashboardWeeklyCalendar => 'Calendário semanal';

  @override
  String get dashboardSmsPacks => 'Pacotes de SMS';

  @override
  String get dashboardOrders => 'Pedidos';

  @override
  String get dashboardWorkingHours => 'Horários de atendimento';

  @override
  String get dashboardSmsTemplates => 'Modelos de SMS';

  @override
  String get dashboardRetry => 'Tentar novamente';

  @override
  String get dashboardNoInternet => 'Verifique sua conexão com a internet.';

  @override
  String get dashboardSessionMissing =>
      'Sessão não encontrada. Entre novamente.';

  @override
  String dashboardLoadFailedWithStatus(Object status) {
    return 'Não foi possível carregar o painel (HTTP $status).';
  }

  @override
  String dashboardLoadFailed(Object error) {
    return 'Não foi possível carregar o painel: $error';
  }

  @override
  String get dashboardQrTitle => 'QR do bio link';

  @override
  String dashboardShareFailed(Object error) {
    return 'Falha ao compartilhar: $error';
  }

  @override
  String dashboardQrDownloadFailed(Object error) {
    return 'Não foi possível baixar o QR: $error';
  }

  @override
  String get dashboardLinkOpenFailed => 'Não foi possível abrir o link.';

  @override
  String get dashboardWhatsAppFailed => 'Não foi possível abrir o WhatsApp.';

  @override
  String dashboardWhatsAppFailedWithError(Object error) {
    return 'Não foi possível abrir o WhatsApp: $error';
  }

  @override
  String get dashboardShareBio => 'Bio link Liik';

  @override
  String get dashboardWhatsappSupport => 'Suporte por WhatsApp';

  @override
  String get appointmentManagement => 'Gerenciamento de agendamentos';

  @override
  String get appointmentSubtitle =>
      'Acompanhe seus agendamentos diários e crie novos rapidamente.';

  @override
  String get refresh => 'Atualizar';

  @override
  String get today => 'Hoje';

  @override
  String get total => 'Total';

  @override
  String get quickAppointment => 'Adicionar agendamento';

  @override
  String get showFilter => 'Filtrar';

  @override
  String get hideFilter => 'Ocultar filtro';

  @override
  String get refreshList => 'Atualizar lista';

  @override
  String get statusPending => 'Pendentes';

  @override
  String get statusConfirmed => 'Confirmado';

  @override
  String get statusRescheduled => 'Reagendado';

  @override
  String get statusCompleted => 'Concluídos';

  @override
  String get statusCancelled => 'Cancelados';

  @override
  String get statusNoShow => 'Não compareceu';

  @override
  String get customerPreview => 'Prévia do cliente';

  @override
  String get recentAppointments => 'Agendamentos recentes';

  @override
  String get reschedule => 'Reagendar';

  @override
  String get date => 'Data';

  @override
  String get timeSelect => 'Horário (escolha)';

  @override
  String get note => 'Observação';

  @override
  String get disableSms => 'Desativar SMS';

  @override
  String get smsOffForAppointment =>
      'O SMS está desativado para este agendamento.';

  @override
  String get disableReminder => 'Desativar lembrete';

  @override
  String get reminderOffForAppointment =>
      'O lembrete está desativado para este agendamento.';

  @override
  String get rescheduleAppointment => 'Reagendar atendimento';

  @override
  String get editAppointment => 'Editar agendamento';

  @override
  String get status => 'Status';

  @override
  String get save => 'Salvar';

  @override
  String get quickAppointmentTitle => 'Adicionar agendamento';

  @override
  String get quickAppointmentSubtitle =>
      'Preencha os dados do cliente e do agendamento em uma tela e salve rapidamente.';

  @override
  String get customerInfo => 'Dados do cliente';

  @override
  String get appointmentInfo => 'Dados do agendamento';

  @override
  String get getAvailableTimes => 'Consultar horários disponíveis';

  @override
  String get setWorkingHours => 'Definir horários de atendimento';

  @override
  String get sendSms => 'Enviar SMS';

  @override
  String get doNotSendSms => 'Não enviar SMS';

  @override
  String get sendReminder => 'Enviar lembrete';

  @override
  String get doNotSendReminder => 'Não enviar lembrete';

  @override
  String get googleLoginButton => 'Entrar com Google';

  @override
  String get googleConnecting => 'Conectando...';

  @override
  String get createAccountEmail => 'Criar conta com e-mail';

  @override
  String get appointmentsTitle => 'Agendamentos';

  @override
  String get appointmentsEmpty => 'Nenhum agendamento ainda.';

  @override
  String appointmentsCountLabel(Object count) {
    return '$count registros';
  }

  @override
  String get appointmentsFilterSubtitle =>
      'Filtre por cliente, data e intervalo de horário';

  @override
  String get appointmentsPackageRequired =>
      'É necessário um pacote ou uma assinatura ativa para gerenciar agendamentos. O saldo de SMS só é utilizado quando um SMS ou lembrete é enviado.';

  @override
  String get appointmentsSessionMissingLogin =>
      'Sessão não encontrada. Entre novamente.';

  @override
  String appointmentsCountriesFetchFailedStatus(Object status) {
    return 'Não foi possível carregar os países (HTTP $status).';
  }

  @override
  String appointmentsCountriesFetchFailed(Object error) {
    return 'Não foi possível carregar os países: $error';
  }

  @override
  String appointmentsStatusesFetchFailedStatus(Object status) {
    return 'Não foi possível carregar os status (HTTP $status).';
  }

  @override
  String appointmentsStatusesFetchFailed(Object error) {
    return 'Não foi possível carregar os status: $error';
  }

  @override
  String get appointmentsInvalidStartTime =>
      'Horário inicial inválido. Formato HH:MM';

  @override
  String get appointmentsInvalidEndTime =>
      'Horário final inválido. Formato HH:MM';

  @override
  String get appointmentsRequiredFields =>
      'Nome, sobrenome, país, telefone, data e horário são obrigatórios.';

  @override
  String get appointmentsSelectAvailableTime =>
      'Selecione um horário disponível.';

  @override
  String get appointmentsCreateSuccess => 'Agendamento criado.';

  @override
  String appointmentsCreateFailedStatus(Object status) {
    return 'Não foi possível criar o agendamento (HTTP $status).';
  }

  @override
  String appointmentsCreateFailed(Object error) {
    return 'Não foi possível criar o agendamento: $error';
  }

  @override
  String get appointmentsEnterDateFirst => 'Informe uma data primeiro.';

  @override
  String appointmentsSlotsFetchFailedStatus(Object status) {
    return 'Não foi possível carregar os horários (HTTP $status).';
  }

  @override
  String appointmentsSlotsFetchFailed(Object error) {
    return 'Não foi possível carregar os horários: $error';
  }

  @override
  String get appointmentsDateTimeRequired => 'Data e horário são obrigatórios.';

  @override
  String get appointmentsUpdateSuccess => 'Agendamento atualizado.';

  @override
  String appointmentsUpdateFailedStatus(Object status) {
    return 'Não foi possível atualizar o agendamento (HTTP $status).';
  }

  @override
  String appointmentsUpdateFailed(Object error) {
    return 'Não foi possível atualizar o agendamento: $error';
  }

  @override
  String get appointmentsStatusMissing =>
      'Status do agendamento não encontrado.';

  @override
  String get appointmentsRebookSuccess => 'Novo agendamento criado.';

  @override
  String get appointmentsInfoMissing => 'Dados do agendamento não encontrados.';

  @override
  String appointmentsInfoFetchFailedStatus(Object status) {
    return 'Não foi possível carregar as informações (HTTP $status).';
  }

  @override
  String appointmentsInfoFetchFailed(Object error) {
    return 'Não foi possível carregar as informações: $error';
  }

  @override
  String get appointmentsNoRecords => 'Nenhum registro encontrado.';

  @override
  String get appointmentsClose => 'Fechar';

  @override
  String get appointmentsClear => 'Limpar';

  @override
  String get appointmentsCountry => 'País';

  @override
  String get appointmentsSelectCountry => 'Selecione o país';

  @override
  String get appointmentsFieldName => 'Nome';

  @override
  String get appointmentsFieldNameHint => 'ex.: Alex';

  @override
  String get appointmentsFieldLastName => 'Sobrenome';

  @override
  String get appointmentsFieldLastNameHint => 'ex.: Silva';

  @override
  String get appointmentsFieldNameFilterHint => 'Nome do cliente';

  @override
  String get appointmentsFieldLastNameFilterHint => 'Sobrenome do cliente';

  @override
  String get appointmentsFieldPhone => 'Telefone';

  @override
  String get appointmentsFieldPhoneHint => 'ex.: 11987654321';

  @override
  String get appointmentsFieldEmailHint => 'Opcional';

  @override
  String get appointmentsStatusSelectHint => 'Selecione o status';

  @override
  String get appointmentsStartDate => 'Data inicial';

  @override
  String get appointmentsEndDate => 'Data final';

  @override
  String get appointmentsStartTime => 'Horário inicial';

  @override
  String get appointmentsEndTime => 'Horário final';

  @override
  String get appointmentsBuyPackage => 'Comprar pacote';

  @override
  String get appointmentsFirstAppointment => 'Este é o primeiro agendamento?';

  @override
  String get appointmentsReminderDisableTitle => 'Não enviar lembrete';

  @override
  String get appointmentsSubmitting => 'Enviando...';

  @override
  String get appointmentsCustomerPreviewTooltip => 'Prévia do cliente';

  @override
  String get appointmentsRebookTooltip => 'Agendar novamente';

  @override
  String get appointmentsEditTooltip => 'Editar';

  @override
  String get appointmentsHomeTooltip => 'Início';

  @override
  String get iosSmsPurchaseRestrictionMessage =>
      'A compra de pacotes de SMS não está disponível no app iOS devido às políticas da Apple App Store.\nAs compras podem ser feitas no site.';

  @override
  String appointmentsFetchFailedStatus(Object status) {
    return 'Não foi possível carregar os agendamentos (HTTP $status).';
  }

  @override
  String appointmentsFetchFailed(Object error) {
    return 'Não foi possível carregar os agendamentos: $error';
  }

  @override
  String get calendarSessionMissing => 'Sessão não encontrada.';

  @override
  String calendarFetchFailedStatus(Object status) {
    return 'Não foi possível carregar o calendário semanal (HTTP $status).';
  }

  @override
  String calendarFetchFailed(Object error) {
    return 'Não foi possível carregar o calendário semanal: $error';
  }

  @override
  String get calendarUnexpected => 'Formato de resposta inesperado.';

  @override
  String get calendarClosed => 'Fechado';

  @override
  String get calendarCustomer => 'Cliente';

  @override
  String get calendarWorkingHoursPrompt =>
      'Defina seus horários de atendimento.';

  @override
  String get calendarWorkingHoursButton => 'Definir horários de atendimento';

  @override
  String get calendarSessionExpired => 'Sessão expirada. Entre novamente.';

  @override
  String get calendarTitle => 'Calendário semanal';

  @override
  String get calendarPrev => 'Anterior';

  @override
  String get calendarToday => 'Hoje';

  @override
  String get calendarNext => 'Próxima';

  @override
  String get calendarLoading => 'Carregando...';

  @override
  String get calendarNoData => 'Nenhum dado para esta semana.';

  @override
  String calendarSlotsFilled(Object booked, Object total) {
    return '$booked/$total horários ocupados';
  }

  @override
  String get calendarAddAppointment => 'Adicionar agendamento';

  @override
  String get calendarGuideTitle => 'Guia';

  @override
  String get calendarPerson => 'Pessoa';

  @override
  String get calendarExistingPerson => 'Pessoa cadastrada';

  @override
  String get calendarNewPerson => 'Nova pessoa';

  @override
  String get calendarSelectPerson => 'Selecione uma pessoa';

  @override
  String get calendarDateTimeSection => 'Data e horário';

  @override
  String get calendarNoteHint => 'Adicione uma observação...';

  @override
  String get calendarSlotBusy => 'O horário selecionado está ocupado.';

  @override
  String get appointmentsConsecutiveSlotsUnavailable =>
      'Nenhum horário consecutivo disponível. Escolha outro horário.';

  @override
  String get commonForbiddenAction => 'Você não tem permissão para esta ação.';

  @override
  String get commonHolidayDateUnavailable => 'A data selecionada é um feriado.';

  @override
  String get calendarCustomerInfoMissing => 'Dados da pessoa não encontrados.';

  @override
  String get calendarAppointmentInfoMissing =>
      'Dados do agendamento não encontrados.';

  @override
  String get calendarAppointmentStatusMissing =>
      'Status do agendamento não encontrado.';

  @override
  String get calendarActionNew => 'Novo';

  @override
  String get calendarActionEdit => 'Editar';

  @override
  String get calendarFetchAvailableSlots => 'Consultar horários disponíveis';

  @override
  String get calendarDateHint => 'Escolha no calendário';

  @override
  String get calendarTimeSlotHint => 'Selecione um horário';

  @override
  String get calendarSelectDateFirst => 'Selecione uma data primeiro.';

  @override
  String get calendarDateTimeRequired => 'Data e horário são obrigatórios.';

  @override
  String get calendarCreateSuccess => 'Novo agendamento criado.';

  @override
  String get calendarUpdateSuccess => 'Agendamento atualizado.';

  @override
  String get calendarCreateFailed => 'Não foi possível criar o agendamento';

  @override
  String get calendarUpdateFailed => 'Não foi possível atualizar o agendamento';

  @override
  String get dayMonShort => 'Seg';

  @override
  String get dayTueShort => 'Ter';

  @override
  String get dayWedShort => 'Qua';

  @override
  String get dayThuShort => 'Qui';

  @override
  String get dayFriShort => 'Sex';

  @override
  String get daySatShort => 'Sáb';

  @override
  String get daySunShort => 'Dom';

  @override
  String get dayMonFull => 'Segunda-feira';

  @override
  String get dayTueFull => 'Terça-feira';

  @override
  String get dayWedFull => 'Quarta-feira';

  @override
  String get dayThuFull => 'Quinta-feira';

  @override
  String get dayFriFull => 'Sexta-feira';

  @override
  String get daySatFull => 'Sábado';

  @override
  String get daySunFull => 'Domingo';

  @override
  String get calendarTimeLabel => 'Horário';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileSaved => 'Perfil salvo.';

  @override
  String get profileSaveError => 'Não foi possível salvar o perfil.';

  @override
  String get profileSessionMissing => 'Sessão não encontrada. Entre novamente.';

  @override
  String profileFetchFailedStatus(Object status) {
    return 'Não foi possível carregar o perfil (HTTP $status).';
  }

  @override
  String profileFetchFailed(Object error) {
    return 'Não foi possível carregar o perfil: $error';
  }

  @override
  String get profileAvatarTooLarge =>
      'A imagem de perfil deve ter menos de 3 MB.';

  @override
  String get profileAvatarInvalidFormat => 'Envie um arquivo JPG, PNG ou WEBP.';

  @override
  String profileAvatarPrepareFailed(Object error) {
    return 'Não foi possível preparar a imagem: $error';
  }

  @override
  String get profileUpdateFailedGeneric => 'Falha ao atualizar.';

  @override
  String profileUpdateFailed(Object error) {
    return 'Não foi possível atualizar o perfil: $error';
  }

  @override
  String get profilePasswordMismatch =>
      'A nova senha e a confirmação não coincidem.';

  @override
  String get profilePasswordUpdated => 'Senha atualizada.';

  @override
  String get profilePasswordUpdateFailed =>
      'Não foi possível atualizar a senha.';

  @override
  String profilePasswordUpdateFailedWithError(Object error) {
    return 'Não foi possível atualizar a senha: $error';
  }

  @override
  String get profileAvatarUpload => 'Enviar foto de perfil';

  @override
  String get profileNameMissing => 'Nome não definido';

  @override
  String get profileUsernamePlaceholder => '@usuario';

  @override
  String get profileInfoTitle => 'Informações do perfil';

  @override
  String get profileFieldName => 'Nome';

  @override
  String get profileFieldUsername => 'Nome de usuário';

  @override
  String get profileFieldDescription => 'Descrição';

  @override
  String get profileFieldFooter => 'Rodapé';

  @override
  String get profileSeoSectionTitle => 'SEO';

  @override
  String get profileSeoSubtitle => 'Título, descrição e palavras-chave';

  @override
  String get profileSeoTitleLabel => 'Título';

  @override
  String get profileSeoDescriptionLabel => 'Descrição';

  @override
  String get profileSeoKeywordsLabel => 'Palavras-chave';

  @override
  String get profileSaving => 'Salvando...';

  @override
  String get profilePasswordSectionTitle => 'Atualizar senha';

  @override
  String get profilePasswordUpdatedSubtitle => 'Atualizado com sucesso';

  @override
  String get profileCurrentPassword => 'Senha atual';

  @override
  String get profileNewPassword => 'Nova senha';

  @override
  String get profileConfirmPassword => 'Confirme a nova senha';

  @override
  String get profileChangePasswordSaving => 'Enviando...';

  @override
  String get profileChangePasswordButton => 'Atualizar senha';

  @override
  String profileSmsCount(Object count) {
    return 'SMS: $count';
  }

  @override
  String get myLinksTitle => 'Meus links';

  @override
  String get myLinksNewLink => 'Novo link';

  @override
  String get myLinksSearchType => 'Buscar tipo de link';

  @override
  String get myLinksNoResults => 'Nenhum resultado encontrado';

  @override
  String get myLinksLinkType => 'Tipo de link';

  @override
  String get myLinksTypeMissing =>
      'Nenhum tipo de link encontrado. Verifique as configurações.';

  @override
  String get myLinksTitleLabel => 'Título';

  @override
  String get myLinksUrlLabel => 'URL';

  @override
  String get myLinksColorLabel => 'Cor';

  @override
  String get myLinksColorMissing => 'Nenhuma lista de cores encontrada.';

  @override
  String get myLinksAddLink => 'Adicionar link';

  @override
  String get myLinksSaving => 'Salvando...';

  @override
  String get myLinksCreateRequired =>
      'Token, tipo e cor são obrigatórios para adicionar um link.';

  @override
  String get myLinksCreateSuccess => 'Link adicionado.';

  @override
  String get myLinksCreateFailed => 'Não foi possível adicionar o link.';

  @override
  String get myLinksCreateError => 'Ocorreu um erro ao adicionar o link.';

  @override
  String get myLinksTokenMissing => 'Token não encontrado.';

  @override
  String get myLinksDeleteSuccess => 'Link excluído.';

  @override
  String get myLinksDeleteFailed => 'Não foi possível excluir o link.';

  @override
  String get myLinksDeleteError => 'Ocorreu um erro ao excluir o link.';

  @override
  String get myLinksUpdateSuccess => 'Link atualizado.';

  @override
  String get myLinksUpdateFailed => 'Não foi possível atualizar o link.';

  @override
  String get myLinksUpdateError => 'Ocorreu um erro ao atualizar o link.';

  @override
  String get myLinksEditTitle => 'Editar link';

  @override
  String get myLinksUpdateButton => 'Atualizar';

  @override
  String myLinksTypeFallback(Object id) {
    return 'Tipo #$id';
  }

  @override
  String myLinksColorFallback(Object id) {
    return 'Cor #$id';
  }

  @override
  String get myLinksNoLinksTitle => 'Nenhum link ainda';

  @override
  String get myLinksNoLinksSubtitle => 'Comece adicionando um novo link';

  @override
  String get myLinksDebugTitle => 'Dados ausentes';

  @override
  String get myLinksDebugSubtitle =>
      'As listas esperadas não foram retornadas pela API';

  @override
  String get myLinksDebugNoLinks => '⚠️ A API não retornou links.';

  @override
  String get myLinksDebugNoTypes => '⚠️ A lista de tipos de link está vazia.';

  @override
  String get myLinksDebugNoColors => '⚠️ A lista de cores está vazia.';

  @override
  String get myLinksOrderSaving => 'Salvando ordem...';

  @override
  String get myLinksShowForm => 'Adicionar novo link';

  @override
  String get myLinksHideForm => 'Ocultar formulário';

  @override
  String get themesTitle => 'Temas';

  @override
  String get themesSessionMissing => 'Sessão não encontrada. Entre novamente.';

  @override
  String get themesSessionExpired => 'Sua sessão expirou. Entre novamente.';

  @override
  String themesLoadFailed(Object error) {
    return 'Não foi possível carregar os temas: $error';
  }

  @override
  String get themesPreviewError => 'Ocorreu um problema ao carregar a prévia.';

  @override
  String get themesSelectTheme => 'Selecione um tema.';

  @override
  String get themesSaveSuccess => 'Tema atualizado.';

  @override
  String themesSaveFailedStatus(Object status) {
    return 'Não foi possível atualizar o tema (HTTP $status).';
  }

  @override
  String themesSaveError(Object error) {
    return 'Ocorreu um erro ao salvar o tema: $error';
  }

  @override
  String get themesRefreshTooltip => 'Atualizar';

  @override
  String get themesRetry => 'Tentar novamente';

  @override
  String get themesListTitle => 'Temas';

  @override
  String get themesNoThemes => 'Nenhum tema disponível.';

  @override
  String get themesLivePreview => 'Prévia ao vivo';

  @override
  String get themesSaving => 'Salvando...';

  @override
  String get themesSaveButton => 'Salvar tema';

  @override
  String get themesPreviewPlaceholder => 'Selecione um tema para visualizar.';

  @override
  String get themesFallbackName => 'Tema';

  @override
  String get smsPacksTitle => 'Pacotes de SMS';

  @override
  String get smsPacksSessionMissing =>
      'Sessão não encontrada. Entre novamente.';

  @override
  String get smsPacksSessionExpired => 'Sessão expirada. Entre novamente.';

  @override
  String smsPacksLoadFailedStatus(Object status) {
    return 'Não foi possível carregar os pacotes (HTTP $status).';
  }

  @override
  String smsPacksLoadFailed(Object error) {
    return 'Não foi possível carregar os pacotes: $error';
  }

  @override
  String smsPacksCountriesFailedStatus(Object status) {
    return 'Não foi possível carregar os países (HTTP $status).';
  }

  @override
  String smsPacksCountriesFailed(Object error) {
    return 'Não foi possível carregar os países: $error';
  }

  @override
  String smsPacksCitiesFailedStatus(Object status) {
    return 'Não foi possível carregar as cidades (HTTP $status).';
  }

  @override
  String smsPacksCitiesFailed(Object error) {
    return 'Não foi possível carregar as cidades: $error';
  }

  @override
  String smsPacksDistrictsFailedStatus(Object status) {
    return 'Não foi possível carregar os bairros (HTTP $status).';
  }

  @override
  String smsPacksDistrictsFailed(Object error) {
    return 'Não foi possível carregar os bairros: $error';
  }

  @override
  String smsPacksAddressesFailedStatus(Object status) {
    return 'Não foi possível carregar os endereços (HTTP $status).';
  }

  @override
  String smsPacksAddressesFailed(Object error) {
    return 'Não foi possível carregar os endereços: $error';
  }

  @override
  String get smsPacksContentMissing => 'Conteúdo não encontrado.';

  @override
  String get smsPacksContract => 'Contrato';

  @override
  String get smsPacksClose => 'Fechar';

  @override
  String get smsPacksFeatures => 'Recursos';

  @override
  String get smsPacksPlanMonthly => 'Mensal';

  @override
  String get smsPacksPlanAnnual => 'Anual';

  @override
  String get smsPacksSelectPack => 'Selecione um pacote.';

  @override
  String get smsPacksSelectCountry => 'Selecione um país.';

  @override
  String get smsPacksSelectCity => 'Selecione uma cidade.';

  @override
  String get smsPacksSelectDistrict => 'Selecione um bairro.';

  @override
  String get smsPacksNameRequired => 'O nome não pode ficar em branco.';

  @override
  String get smsPacksLastNameRequired =>
      'O sobrenome não pode ficar em branco.';

  @override
  String get smsPacksPhoneRequired => 'O telefone não pode ficar em branco.';

  @override
  String get smsPacksAddressRequired => 'O endereço não pode ficar em branco.';

  @override
  String get smsPacksAgreementRequired =>
      'Você deve aceitar o contrato de compra.';

  @override
  String get smsPacksPurchaseSuccess =>
      'Pedido criado. Redirecionando para o pagamento.';

  @override
  String smsPacksPurchaseFailedStatus(Object status) {
    return 'Falha na compra (HTTP $status).';
  }

  @override
  String smsPacksPurchaseError(Object error) {
    return 'Ocorreu um erro durante a compra: $error';
  }

  @override
  String get smsPacksPaymentStartInvalid =>
      'Não foi possível abrir a página de pagamento. Resposta inválida.';

  @override
  String smsPacksPaymentStartFailedStatus(Object status) {
    return 'Não foi possível iniciar o pagamento (HTTP $status).';
  }

  @override
  String smsPacksPaymentStartError(Object error) {
    return 'Ocorreu um erro ao iniciar o pagamento: $error';
  }

  @override
  String get smsPacksPaymentPending =>
      'O pagamento está sendo confirmado. Aguarde.';

  @override
  String get smsPacksPaymentVerify403 =>
      'Não foi possível verificar o pagamento (403).';

  @override
  String get smsPacksPaymentVerify404 => 'Transação não encontrada (404).';

  @override
  String smsPacksPaymentVerifyFailedStatus(Object status) {
    return 'Não foi possível verificar o pagamento (HTTP $status).';
  }

  @override
  String smsPacksPaymentVerifyError(Object error) {
    return 'Não foi possível verificar o pagamento: $error';
  }

  @override
  String get smsPacksPaymentSuccessTitle => 'Pagamento aprovado';

  @override
  String get smsPacksPaymentPendingTitle => 'Pagamento pendente';

  @override
  String get smsPacksPaymentFailedTitle => 'Falha no pagamento';

  @override
  String get smsPacksPaymentLabel => 'Pagamento';

  @override
  String get smsPacksPackLabel => 'Pacote';

  @override
  String get smsPacksTypeLabel => 'Tipo';

  @override
  String get smsPacksAmountLabel => 'Valor';

  @override
  String get smsPacksInvoiceLabel => 'Número da nota fiscal';

  @override
  String get smsPacksPaymentVerifying => 'Verificando pagamento...';

  @override
  String get smsPacksGoHome => 'Ir para o início';

  @override
  String get smsPacksRetry => 'Tentar novamente';

  @override
  String get smsPacksStepPack => 'Pacote';

  @override
  String get smsPacksStepInfo => 'Informações';

  @override
  String get smsPacksStepSummary => 'Resumo';

  @override
  String get smsPacksStepPayment => 'Pagamento';

  @override
  String get smsPacksNext => 'Próxima';

  @override
  String get smsPacksBack => 'Voltar';

  @override
  String get smsPacksBuy => 'Comprar';

  @override
  String get smsPacksDetails => 'Ver recursos';

  @override
  String get smsPacksSelectButton => 'Selecionar pacote';

  @override
  String get smsPacksSelected => 'Selecionado';

  @override
  String get smsPacksRefresh => 'Atualizar';

  @override
  String get smsPacksSavedAddresses => 'Endereços salvos';

  @override
  String get smsPacksNewAddress => 'Novo endereço';

  @override
  String get smsPacksAddressTitle => 'Nome do endereço';

  @override
  String get smsPacksFirstName => 'Nome';

  @override
  String get smsPacksLastName => 'Sobrenome';

  @override
  String get smsPacksCompany => 'Empresa (opcional)';

  @override
  String get smsPacksEmail => 'E-mail';

  @override
  String get smsPacksCountry => 'País';

  @override
  String get smsPacksCity => 'Cidade';

  @override
  String get smsPacksDistrict => 'Bairro';

  @override
  String get smsPacksPhone => 'Telefone';

  @override
  String get smsPacksIdentity => 'Documento de identidade (opcional)';

  @override
  String get smsPacksTaxNumber => 'Documento fiscal (opcional)';

  @override
  String get smsPacksTaxOffice => 'Órgão fiscal';

  @override
  String get smsPacksAddress => 'Endereço';

  @override
  String get smsPacksPaymentMethod => 'Forma de pagamento';

  @override
  String get smsPacksNote => 'Observação';

  @override
  String get smsPacksNoteHint =>
      'Observações ou solicitações especiais para a nota fiscal';

  @override
  String get smsPacksAgreementTitle => 'Li e aceito o contrato de compra.';

  @override
  String get smsPacksPaymentSecurityNote =>
      'O pagamento é realizado na página segura do PayTR. O app não coleta nem armazena os dados do seu cartão.';

  @override
  String get smsPacksSummaryTitle => 'Resumo da compra';

  @override
  String get smsPacksSummaryPurchaseInfo => 'Informações da compra';

  @override
  String get smsPacksSmsLabel => 'SMS';

  @override
  String get smsPacksCompanyLabel => 'Empresa';

  @override
  String get smsPacksBuyerLabel => 'Nome completo';

  @override
  String get smsPacksEmailLabel => 'E-mail';

  @override
  String get smsPacksCountryLabel => 'País';

  @override
  String get smsPacksCityLabel => 'Cidade';

  @override
  String get smsPacksDistrictLabel => 'Bairro';

  @override
  String get smsPacksPhoneLabel => 'Telefone';

  @override
  String get smsPacksTaxNumberLabel => 'Documento fiscal';

  @override
  String get smsPacksTaxOfficeLabel => 'Órgão fiscal';

  @override
  String get smsPacksIdentityLabel => 'Documento de identidade';

  @override
  String get smsPacksAddressLabel => 'Endereço';

  @override
  String get smsPacksNoteLabel => 'Observação';

  @override
  String get smsPacksSubmitLabel => 'Enviar';

  @override
  String get smsPacksNoPacksForType =>
      'Nenhum pacote disponível para este tipo.';

  @override
  String smsPacksPriceWithTax(Object price) {
    return 'Com impostos ₺$price';
  }

  @override
  String smsPacksSmsCount(Object count) {
    return '$count SMS';
  }

  @override
  String get smsPacksSelectPackForSummary =>
      'Selecione um pacote para ver o resumo.';

  @override
  String get smsPacksRefreshing => 'Atualizando...';

  @override
  String get smsPacksSavedAddressesLabel => 'Endereços salvos';

  @override
  String get smsPacksSelectAddress => 'Selecionar';

  @override
  String get smsPacksPlanLabel => 'Plano';

  @override
  String get smsPacksPriceLabel => 'Preço';

  @override
  String get smsPacksVatIncluded => 'Impostos incluídos';

  @override
  String get smsPacksSubmitting => 'Enviando...';

  @override
  String get smsPacksAndroidOnlyTitle => 'Compras no app Android';

  @override
  String get smsPacksAndroidOnlyMessage =>
      'A compra de pacotes de SMS está disponível apenas no app Android. Você pode visualizar os pacotes neste dispositivo.';

  @override
  String iosPacksPurchaseStreamError(Object error) {
    return 'Não foi possível acompanhar a compra na Apple: $error';
  }

  @override
  String get iosPacksPackIdMissing =>
      'Nenhum ios_product_id encontrado para este pacote.';

  @override
  String iosPacksPackDetailsLoadFailed(Object error) {
    return 'Não foi possível carregar os detalhes do pacote: $error';
  }

  @override
  String iosPacksPackDetailsTitle(Object name) {
    return 'Detalhes do pacote $name';
  }

  @override
  String get iosPacksNoPackDetails =>
      'Nenhum detalhe encontrado para este pacote.';

  @override
  String iosPacksInvalidLink(Object value) {
    return 'Link inválido: $value';
  }

  @override
  String iosPacksLinkOpenFailed(Object value) {
    return 'Não foi possível abrir o link: $value';
  }

  @override
  String get iosPacksStoreKitUnavailable =>
      'StoreKit indisponível. O dispositivo ou a conta da App Store pode não estar pronto.';

  @override
  String iosPacksStoreProductNotFound(Object productId) {
    return 'A App Store retornou notFound para \"$productId\".';
  }

  @override
  String iosPacksStoreProductMissing(Object productId) {
    return 'O produto \"$productId\" não foi carregado da App Store.';
  }

  @override
  String get iosPacksPlanSparkHeadline => 'Comece de forma simples';

  @override
  String get iosPacksPlanBoostHeadline => 'Avance com mais flexibilidade';

  @override
  String get iosPacksPlanPowerHeadline => 'Feito para uma agenda mais cheia';

  @override
  String get iosPacksPlanPrimeHeadline =>
      'Acesso completo para sua rotina premium';

  @override
  String get iosPacksPlanDefaultHeadline =>
      'Escolha o plano ideal para sua rotina';

  @override
  String get iosPacksSubscriptionGeneric => 'assinatura';

  @override
  String iosPacksBenefitAppointmentAccess(Object duration) {
    return 'O gerenciamento de agendamentos permanece ativo com seu plano $duration.';
  }

  @override
  String get iosPacksBenefitSecureCheckout =>
      'O pagamento seguro é processado diretamente pela Apple.';

  @override
  String get iosPacksBenefitManageSubscription =>
      'Gerencie a renovação e o cancelamento na sua conta da App Store.';

  @override
  String get iosPacksAppleSubscription => 'Assinatura Apple';

  @override
  String get iosPacksHeroDescription =>
      'Escolha o período de cobrança, confira o preço e continue com uma compra segura na App Store.';

  @override
  String iosPacksStoreProductUnavailable(Object diagnostic) {
    return 'Este produto da App Store não está disponível. $diagnostic';
  }

  @override
  String get iosPacksPurchaseStartFailed =>
      'Não foi possível iniciar a solicitação de compra na App Store.';

  @override
  String iosPacksPurchaseFailed(Object error) {
    return 'Erro na compra da App Store: $error';
  }

  @override
  String get iosPacksRestoreStarted => 'Restaurando compras da Apple...';

  @override
  String iosPacksRestoreFailed(Object error) {
    return 'Não foi possível iniciar a restauração: $error';
  }

  @override
  String get iosPacksRestoreSuccess => 'Assinatura Apple restaurada.';

  @override
  String get iosPacksPurchaseSuccess =>
      'Assinatura Apple adquirida com sucesso.';

  @override
  String get iosPacksPurchaseUnknownError => 'A compra na App Store falhou.';

  @override
  String get iosPacksPurchaseCancelled => 'Compra cancelada.';

  @override
  String get iosPacksUnavailableInStore => 'Indisponível na App Store';

  @override
  String get iosPacksDetailsButton => 'Detalhes do pacote';

  @override
  String get iosPacksNoProductsForType =>
      'Nenhum produto encontrado para este tipo de plano.';

  @override
  String get iosPacksSelectedPlan => 'Plano selecionado';

  @override
  String get iosPacksActivationInfo =>
      'Ativação imediata após a compra na Apple';

  @override
  String get iosPacksAgreementDetails => 'Detalhes';

  @override
  String get iosPacksAppointmentPackageInfo =>
      'O gerenciamento de agendamentos depende do pacote. O saldo de SMS só é consumido quando o envio de SMS ou lembretes está ativado.';

  @override
  String get iosPacksLegalConsent =>
      'Ao continuar, você concorda com os Termos de Uso e a Política de Privacidade.';

  @override
  String get iosPacksTermsOfUse => 'Termos de Uso';

  @override
  String get iosPacksPrivacyPolicy => 'Política de Privacidade';

  @override
  String get iosPacksStoreUnavailableNow =>
      'Os produtos da App Store não estão disponíveis no momento.';

  @override
  String get iosPacksRestoreInProgress => 'Restaurando…';

  @override
  String get iosPacksRestore => 'Restaurar';

  @override
  String get ordersTitle => 'Pedidos';

  @override
  String get ordersSessionExpired => 'Sessão expirada. Entre novamente.';

  @override
  String get ordersSessionMissing => 'Sessão não encontrada. Entre novamente.';

  @override
  String ordersFetchFailedStatus(Object status) {
    return 'Não foi possível carregar os pedidos (HTTP $status).';
  }

  @override
  String ordersFetchFailed(Object error) {
    return 'Não foi possível carregar os pedidos: $error';
  }

  @override
  String get ordersRetry => 'Tentar novamente';

  @override
  String get ordersEmpty => 'Nenhum pedido ainda.';

  @override
  String get ordersFilterAll => 'Todos';

  @override
  String get ordersFilterPaid => 'Pago';

  @override
  String get ordersFilterPending => 'Pendentes';

  @override
  String get ordersFilterFailed => 'Falhou';

  @override
  String get ordersPrev => 'Anterior';

  @override
  String get ordersNext => 'Próxima';

  @override
  String ordersPageLabel(Object current, Object total) {
    return 'Página $current / $total';
  }

  @override
  String get ordersPack => 'Pacote';

  @override
  String get ordersType => 'Tipo';

  @override
  String get ordersStatus => 'Status';

  @override
  String get ordersAmount => 'Valor';

  @override
  String get ordersDate => 'Data';

  @override
  String get ordersTxnId => 'ID da transação';

  @override
  String get ordersPrice => 'Preço';

  @override
  String get ordersTax => 'Imposto';

  @override
  String get ordersTotal => 'Total';

  @override
  String get ordersDetailTitle => 'Pedido';

  @override
  String get ordersStatusPaid => 'Pago';

  @override
  String get ordersStatusPending => 'Pendentes';

  @override
  String get ordersStatusFailed => 'Falhou';

  @override
  String get ordersStatusCancelled => 'Cancelados';

  @override
  String get workingPrefsTitle => 'Horários de atendimento';

  @override
  String get workingPrefsSessionMissing =>
      'Sessão não encontrada. Entre novamente.';

  @override
  String workingPrefsLoadFailedStatus(Object status) {
    return 'Não foi possível carregar os horários de atendimento (HTTP $status).';
  }

  @override
  String workingPrefsLoadFailed(Object error) {
    return 'Não foi possível carregar os horários de atendimento: $error';
  }

  @override
  String get workingPrefsSaveSuccess => 'Salvo.';

  @override
  String workingPrefsSaveFailedStatus(Object status) {
    return 'Não foi possível salvar (HTTP $status).';
  }

  @override
  String workingPrefsSaveFailed(Object error) {
    return 'Não foi possível salvar: $error';
  }

  @override
  String get workingPrefsRetry => 'Tentar novamente';

  @override
  String get workingPrefsFirstSessionTitle =>
      'Número de sessões do primeiro agendamento';

  @override
  String get workingPrefsSessionLabel => 'Sessão';

  @override
  String get workingPrefsSelect => 'Selecionar';

  @override
  String workingPrefsSessionOption(Object count) {
    return '$count sessão(ões)';
  }

  @override
  String get workingPrefsDaySubtitle =>
      'Disponibilidade e intervalos de horário';

  @override
  String get workingPrefsStatusLabel => 'Status';

  @override
  String get workingPrefsTimeSlotsLabel => 'Horários';

  @override
  String get workingPrefsWorking => 'Atendendo';

  @override
  String get workingPrefsAddSlot => 'Adicionar horário';

  @override
  String get workingPrefsStart => 'Início';

  @override
  String get workingPrefsEnd => 'Fim';

  @override
  String get workingPrefsPeriod => 'Intervalo (minutos)';

  @override
  String get workingPrefsDelete => 'Excluir';

  @override
  String get workingPrefsSaving => 'Salvando...';

  @override
  String get workingPrefsSave => 'Salvar';

  @override
  String get workingPrefsHolidaysTitle => 'Feriados e folgas';

  @override
  String get workingPrefsHolidaysEmpty => 'Nenhum feriado ou folga adicionado.';

  @override
  String get workingPrefsHolidayAdd => 'Adicionar feriado ou folga';

  @override
  String get workingPrefsHolidayStart => 'Início';

  @override
  String get workingPrefsHolidayEnd => 'Fim';

  @override
  String get workingPrefsHolidayReason => 'Motivo (opcional)';

  @override
  String get workingPrefsTemplatesTitle => 'Modelos rápidos';

  @override
  String get workingPrefsTemplatesSubtitle =>
      'Selecione um modelo para começar rapidamente';

  @override
  String get workingPrefsTemplatesApply => 'Aplicar';

  @override
  String workingPrefsTemplatesApplied(String name) {
    return 'Modelo $name aplicado.';
  }

  @override
  String get workingPrefsTemplatesConfirmTitle => 'Aplicar modelo';

  @override
  String get workingPrefsTemplatesConfirmBody =>
      'Deseja aplicar este modelo? Seus horários de atendimento atuais serão substituídos.';

  @override
  String get workingPrefsTemplatesCancel => 'Cancelar';

  @override
  String get smsTemplatesTitle => 'Modelos de SMS';

  @override
  String get smsTemplatesSessionMissing =>
      'Sessão não encontrada. Entre novamente.';

  @override
  String smsTemplatesFetchFailedStatus(Object status) {
    return 'Não foi possível carregar os modelos (HTTP $status).';
  }

  @override
  String smsTemplatesFetchFailed(Object error) {
    return 'Não foi possível carregar os modelos: $error';
  }

  @override
  String get smsTemplatesUpdated => 'Modelos de SMS atualizados.';

  @override
  String smsTemplatesSaveFailedStatus(Object status) {
    return 'Não foi possível salvar (HTTP $status).';
  }

  @override
  String smsTemplatesSaveFailed(Object error) {
    return 'Não foi possível salvar: $error';
  }

  @override
  String get smsTemplatesSelect => 'Selecionar';

  @override
  String get smsTemplatesNotFound => 'Nenhum modelo encontrado';

  @override
  String get smsTemplatesCustomerTemplates => 'Modelos de SMS para clientes';

  @override
  String smsTemplatesSelectionId(Object id) {
    return 'ID da seleção: $id';
  }

  @override
  String get smsTemplatesMain => 'Mensagem principal';

  @override
  String get smsTemplatesReminder => 'Lembrete';

  @override
  String get smsTemplatesCancel => 'Cancelar';

  @override
  String get smsTemplatesUpdate => 'Atualizar';

  @override
  String get smsTemplatesSave => 'Salvar';

  @override
  String get smsTemplatesSaving => 'Salvando...';

  @override
  String get smsTemplatesRefresh => 'Atualizar';

  @override
  String smsTemplatesFallbackTitle(Object id) {
    return 'Modelo #$id';
  }

  @override
  String get smsTemplatesGuideTitle => 'Seleção de modelos';

  @override
  String get smsTemplatesGuideBody =>
      'Selecione um modelo de SMS para cada categoria.';

  @override
  String get smsTemplatesGuideHint =>
      'Toque nos cartões para selecionar modelos. O cartão selecionado fica destacado e aparece na prévia abaixo.';

  @override
  String get smsTemplatesMainDescription =>
      'Mensagem enviada quando um novo agendamento é criado.';

  @override
  String get smsTemplatesReminderDescription =>
      'Mensagem enviada como lembrete antes do agendamento.';

  @override
  String get smsTemplatesCancelDescription =>
      'Mensagem enviada quando um agendamento é cancelado.';

  @override
  String get smsTemplatesUpdateDescription =>
      'Mensagem enviada quando a data ou o horário do agendamento é atualizado.';

  @override
  String get smsTemplatesPreviewTitle => 'Prévia ao vivo';

  @override
  String get smsTemplatesPreviewEmpty =>
      'Nenhum modelo selecionado para esta categoria.';

  @override
  String get smsTemplatesSelected => 'Selecionado';

  @override
  String get supportTitle => 'Suporte';

  @override
  String get supportSessionMissing => 'Sessão não encontrada. Entre novamente.';

  @override
  String supportFetchFailedStatus(Object status) {
    return 'Não foi possível carregar os chamados (HTTP $status).';
  }

  @override
  String supportFetchFailed(Object error) {
    return 'Não foi possível carregar os chamados: $error';
  }

  @override
  String get supportCreateValidation => 'Título e mensagem são obrigatórios.';

  @override
  String get supportCreateSuccess => 'Chamado criado.';

  @override
  String supportCreateFailedStatus(Object status) {
    return 'Não foi possível criar o chamado (HTTP $status).';
  }

  @override
  String supportCreateFailed(Object error) {
    return 'Não foi possível criar o chamado: $error';
  }

  @override
  String get supportRetry => 'Tentar novamente';

  @override
  String get supportEmpty => 'Você ainda não tem chamados de suporte.';

  @override
  String get supportRefresh => 'Atualizar';

  @override
  String get supportNewTicket => 'Novo chamado';

  @override
  String get supportTitleLabel => 'Título';

  @override
  String get supportMessageLabel => 'Sua mensagem';

  @override
  String get supportSending => 'Enviando...';

  @override
  String get supportSend => 'Enviar';

  @override
  String get supportTickets => 'Chamados de suporte';

  @override
  String get supportMessagesCount => 'Mensagens';

  @override
  String get supportTicketDetail => 'Detalhes do chamado';

  @override
  String get supportTicketNotFound => 'Chamado não encontrado.';

  @override
  String get supportMessages => 'Mensagens';

  @override
  String get supportStatusClosing => 'Encerrando';

  @override
  String get supportCloseTicket => 'Encerrar chamado';

  @override
  String supportCreatedAt(Object date) {
    return 'Criado em: $date';
  }

  @override
  String get supportSenderYou => 'Você';

  @override
  String get supportSenderSupport => 'Suporte';

  @override
  String get supportNoMessages => 'Nenhuma mensagem ainda.';

  @override
  String get supportReplyPlaceholder => 'Sua mensagem';

  @override
  String get supportReplyClosed =>
      'Este chamado está encerrado. Não é possível enviar novas mensagens.';

  @override
  String get supportReplySending => 'Enviando...';

  @override
  String get supportReplySend => 'Enviar resposta';

  @override
  String get supportReplyEmpty => 'A mensagem não pode ficar em branco.';

  @override
  String get supportReplySuccess => 'Resposta enviada.';

  @override
  String supportReplyFailedStatus(Object status) {
    return 'Não foi possível enviar a resposta (HTTP $status).';
  }

  @override
  String supportReplyFailed(Object error) {
    return 'Não foi possível enviar a resposta: $error';
  }

  @override
  String get supportCloseSuccess => 'Chamado encerrado.';

  @override
  String supportCloseFailedStatus(Object status) {
    return 'Não foi possível encerrar o chamado (HTTP $status).';
  }

  @override
  String supportCloseFailed(Object error) {
    return 'Não foi possível encerrar o chamado: $error';
  }

  @override
  String supportMessagesMeta(Object count, Object date) {
    return '$count mensagens • $date';
  }

  @override
  String get supportStatusOpen => 'Aberto';

  @override
  String get supportStatusPending => 'Pendentes';

  @override
  String get supportStatusClosed => 'Fechado';

  @override
  String get supportPriority => 'Prioridade';

  @override
  String get profileLanguage => 'Idioma do app';

  @override
  String get profileLanguageEnglish => 'Inglês';

  @override
  String get profileLanguageSaved => 'Idioma atualizado.';

  @override
  String get profileDeleteSectionTitle => 'Excluir conta';

  @override
  String get profileDeleteSectionSubtitle => 'Esta ação não pode ser desfeita.';

  @override
  String get profileDeleteConfirmTitle => 'Excluir conta';

  @override
  String get profileDeleteConfirmBody =>
      'Tem certeza de que deseja excluir sua conta? Esta ação não pode ser desfeita.';

  @override
  String get profileDeleteCancel => 'Cancelar';

  @override
  String get profileDeleteAction => 'Excluir conta';

  @override
  String get profileDeleteProcessing => 'Processando...';

  @override
  String get profileDeleteSuccess => 'Conta excluída com sucesso.';

  @override
  String get profileDeleteFailed =>
      'Falha na solicitação de exclusão da conta.';

  @override
  String profileDeleteError(Object error) {
    return 'Ocorreu um erro ao excluir a conta: $error';
  }

  @override
  String get dashboardNoActivePackage =>
      'Você não tem um pacote ativo. Compre um pacote para utilizar SMS.';

  @override
  String get dashboardBuyPackage => 'Comprar pacote';

  @override
  String get aiProfileBannerBadge => 'Assistente de IA Liik';

  @override
  String get aiProfileBannerTitle => 'Criar perfil com IA';

  @override
  String get aiProfileBannerDesc =>
      'A IA escreve o perfil que transforma seus seguidores em agendamentos. Você só precisa compartilhar sua especialidade.';

  @override
  String get aiProfileTitle => 'Perfil com IA';

  @override
  String get aiProfileAiBadge => 'Assistente de IA Liik';

  @override
  String get aiProfileSubtitle => 'Crie seu perfil profissional em segundos';

  @override
  String get aiProfileLoading => 'Carregando perfil com IA...';

  @override
  String get aiProfileRetry => 'Tentar novamente';

  @override
  String get aiProfileSave => 'Salvar';

  @override
  String get aiProfileSaving => 'Salvando...';

  @override
  String get aiProfileTabProfile => 'Perfil';

  @override
  String get aiProfileTabLinks => 'Links';

  @override
  String get aiProfileTabTheme => 'Tema';

  @override
  String get aiProfileRemainingNone => 'Concluído';

  @override
  String get aiProfileGenerateTitle => 'Gerar com IA';

  @override
  String get aiProfileGenerateSubtitle =>
      'Preencha seus dados e deixe a IA criar seu perfil';

  @override
  String get aiProfileGenerateButton => 'Gerar com IA';

  @override
  String get aiProfileGenerating => 'Gerando...';

  @override
  String get aiProfileGenerateLocked =>
      'Seus créditos de geração com IA acabaram';

  @override
  String get aiProfileGenerateSuccess => 'Seu perfil está pronto!';

  @override
  String get aiProfileGenerateSuccessHint =>
      'Você pode editar o conteúdo abaixo';

  @override
  String get aiProfileMsgAnalyzing => 'Analisando seu perfil...';

  @override
  String get aiProfileMsgPreparing => 'Criando conteúdo para sua profissão...';

  @override
  String get aiProfileMsgSelecting => 'Selecionando as melhores expressões...';

  @override
  String get aiProfileMsgSeo => 'Aplicando otimização de SEO...';

  @override
  String get aiProfileMsgFinalizing => 'Dando os toques finais...';

  @override
  String get aiProfileMsgWait => 'Isso pode levar alguns segundos';

  @override
  String get aiProfileFieldProfession => 'Profissão *';

  @override
  String get aiProfileFieldProfessionError => 'Selecione uma profissão';

  @override
  String get aiProfileFieldExpertise => 'Área de especialidade *';

  @override
  String get aiProfileFieldExpertiseHint =>
      'Nutrição esportiva, controle de peso';

  @override
  String get aiProfileFieldExpertiseError => 'Campo obrigatório';

  @override
  String get aiProfileFieldAudience => 'Público-alvo *';

  @override
  String get aiProfileFieldAudienceHint =>
      'Adultos que querem melhorar a forma física';

  @override
  String get aiProfileFieldAudienceError => 'Campo obrigatório';

  @override
  String get aiProfileFieldExperience => 'Experiência (anos)';

  @override
  String get aiProfileFieldExperienceHint => '0–50';

  @override
  String get aiProfileFieldExperienceError => 'Deve estar entre 0 e 50';

  @override
  String get aiProfileFieldTone => 'Tom';

  @override
  String get aiProfileFieldAchievement => 'Conquista / Associação';

  @override
  String get aiProfileFieldAchievementHint => 'Associação profissional';

  @override
  String get aiProfileFieldNote => 'Observação adicional';

  @override
  String get aiProfileFieldNoteHint => 'Seja breve e claro';

  @override
  String get aiProfileFieldBio => 'Bio / Descrição (mín. 20 caracteres)';

  @override
  String get aiProfileFieldFooter => 'Rodapé';

  @override
  String get aiProfileSectionSeo => 'Configurações de SEO';

  @override
  String get aiProfileFieldSeoTitle => 'Título SEO (máx. 70)';

  @override
  String get aiProfileFieldSeoDesc => 'Meta descrição (máx. 170)';

  @override
  String get aiProfileFieldSeoKeywords =>
      'Palavras-chave — separe por vírgulas (máx. 300)';

  @override
  String get aiProfileLinksSubtitle =>
      'Adicione URLs e ative ou desative cada uma.';

  @override
  String get aiProfileLinksSave => 'Salvar links';

  @override
  String get aiProfileLinksSaving => 'Salvando...';

  @override
  String get aiProfileThemeNoPreview => 'Selecione um tema.';

  @override
  String get aiProfileThemeNoUser =>
      'Não foi possível carregar os dados do usuário.';

  @override
  String get aiProfileReminderTitle =>
      'O conteúdo está pronto — não esqueça de salvar!';

  @override
  String get aiProfileReminderSubtitle =>
      'Toque em Salvar no canto superior direito';

  @override
  String get aiProfileSaveSuccess => 'Salvo!';

  @override
  String get aiProfileSaveBioMin => 'A bio deve ter pelo menos 20 caracteres.';

  @override
  String get aiProfileThemeApplied => 'Tema aplicado.';

  @override
  String get aiProfileLinksSaved => 'Links salvos.';

  @override
  String get aiProfileLimitReached => 'Limite diário de IA atingido.';

  @override
  String get aiProfileValidationErrors => 'Corrija os erros no formulário.';

  @override
  String get aiProfileSessionMissing =>
      'Sessão não encontrada. Entre novamente.';

  @override
  String aiProfileRemainingCount(Object count) {
    return '$count restantes';
  }

  @override
  String aiProfileFetchError(Object status) {
    return 'Não foi possível carregar os dados (HTTP $status).';
  }

  @override
  String aiProfileConnectionError(Object error) {
    return 'Erro de conexão: $error';
  }

  @override
  String aiProfileGenerateHttpError(Object status) {
    return 'Falha na geração (HTTP $status).';
  }

  @override
  String aiProfileSaveHttpError(Object status) {
    return 'Falha ao salvar (HTTP $status).';
  }

  @override
  String aiProfileThemeHttpError(Object status) {
    return 'Não foi possível salvar o tema (HTTP $status).';
  }

  @override
  String aiProfileLinksHttpError(Object status) {
    return 'Não foi possível salvar os links (HTTP $status).';
  }

  @override
  String get onboardBadge1 => 'UM ESPAÇO SÓ SEU';

  @override
  String get onboardBadge2 => 'AGENDAR FICOU MAIS FÁCIL';

  @override
  String get onboardBadge3 => 'PRONTO PARA COMPARTILHAR';

  @override
  String get onboardSkip => 'Pular';

  @override
  String get onboardContinue => 'Continuar';

  @override
  String get onboardStart => 'Comece com o Liik';

  @override
  String get onboardLogin => 'Já tem uma conta? Entre';

  @override
  String get onboardPreviewName => 'Oi, eu sou Alex';

  @override
  String get onboardPreviewTagline => 'Criando. Compartilhando. Conectando.';

  @override
  String get onboardPreviewExplore => 'Explore meu mundo';

  @override
  String get onboardPreviewBook => 'Vamos escolher um horário';

  @override
  String get onboardPreviewCall => 'Conversa inicial';

  @override
  String get onboardPreviewDuration => '30 min · Online';

  @override
  String get onboardPreviewReady => 'Seu bio link está pronto';

  @override
  String get onboardPreviewShareHint =>
      'Adicione ao seu perfil. Seja descoberto.';

  @override
  String get onboardPreviewConnections => 'Um link. Novas conexões.';

  @override
  String get loginSubtitle => 'Entre na sua conta e continue de onde parou';

  @override
  String get loginOr => 'ou';

  @override
  String get loginNoAccount => 'Ainda não tem uma conta?';

  @override
  String get registerTitle => 'Criar conta';

  @override
  String get registerConfirmPassword => 'Confirmar senha';

  @override
  String get registerUsername => 'Nome de usuário (opcional)';

  @override
  String get registerSubmit => 'Criar conta';

  @override
  String get registerError => 'Ocorreu um erro durante o cadastro.';

  @override
  String get authTokenMissing => 'Não foi possível obter o token de acesso.';

  @override
  String get authUnauthorized => 'Acesso não autorizado.';

  @override
  String get authGoogleCancelled => 'O login com Google foi cancelado.';

  @override
  String get authGoogleTokenMissing =>
      'Não foi possível obter o token do Google.';

  @override
  String get verifyEmailPending =>
      'E-mail ainda não verificado. Confira sua caixa de entrada.';

  @override
  String get authConnectionError => 'Não foi possível conectar ao servidor.';

  @override
  String get verifyEmailResent => 'E-mail de verificação reenviado.';

  @override
  String get commonSendFailed => 'Não foi possível enviar.';

  @override
  String get verifyEmailTitle => 'Verifique seu e-mail';

  @override
  String get verifyEmailCheck => 'Já verifiquei meu e-mail';

  @override
  String get verifyEmailResend => 'Reenviar';

  @override
  String get verifyEmailOtherAccount => 'Entrar com outra conta';

  @override
  String get dashboardImageFailed => 'Não foi possível criar a imagem.';

  @override
  String get commonNoResults => 'Nenhum resultado encontrado';

  @override
  String get dashboardPackageActivated => 'Seu pacote está ativo! 🎉';

  @override
  String get commonError => 'Ocorreu um erro.';

  @override
  String get dashboardWelcomeGiftTitle => 'Resgate seu presente de boas-vindas';

  @override
  String get dashboardWelcomeGiftDescription =>
      'Preencha o formulário para ativar 100 SMS grátis por um mês.';

  @override
  String get commonChoose => 'Selecione...';

  @override
  String get dashboardCityRequired => 'Cidade *';

  @override
  String get dashboardCityHint => 'ex.: São Paulo';

  @override
  String get dashboardInstagramOptional => 'Instagram (opcional)';

  @override
  String get dashboardActivatePackage => 'Ativar pacote';

  @override
  String get dashboardWelcomeGiftBadge => 'PRESENTE DE BOAS-VINDAS';

  @override
  String get dashboardWelcomeGiftOffer => '100 SMS grátis por um mês';

  @override
  String get dashboardWelcomeGiftHint =>
      'Seu presente está esperando. Preencha o formulário para ativá-lo.';

  @override
  String get dashboardReviewTitle => 'Gostando do Liik?';

  @override
  String get dashboardReviewHint => 'Sua avaliação nos ajuda a crescer.';

  @override
  String get dashboardReviewAction => 'Avaliar Liik';

  @override
  String get commonView => 'Ver';

  @override
  String get dashboardTopUp => 'Recarregar';

  @override
  String get dashboardFeedbackTitle => 'Como está sua experiência com o Liik?';

  @override
  String get dashboardFeedbackHint =>
      'Compartilhe sua experiência para nos ajudar a melhorar.';

  @override
  String get dashboardFeedbackComment => 'Seu comentário (opcional)...';

  @override
  String get dashboardFeedbackSubmit => 'Enviar avaliação';

  @override
  String get commonNotNow => 'Agora não';

  @override
  String get ratingVeryBad => 'Muito ruim';

  @override
  String get ratingBad => 'Ruim';

  @override
  String get ratingGood => 'Bom';

  @override
  String get ratingExcellent => 'Excelente!';

  @override
  String get ratingSelect => 'Selecione uma nota';

  @override
  String get workingTemplateAfternoon => 'Tarde';

  @override
  String get workingTemplateEvening => 'Noite';

  @override
  String get announcementWarning => 'Aviso';

  @override
  String get announcementUpdate => 'Atualização';

  @override
  String get announcementConnectionError => 'Erro de conexão.';

  @override
  String get announcementReadAll => 'Marcar todas como lidas';

  @override
  String get announcementEmpty => 'Nenhum aviso ainda';

  @override
  String get announcementDownload => 'Baixar atualização';

  @override
  String get blogTitle => 'Artigos';

  @override
  String get blogViewAll => 'Ver todos';

  @override
  String get blogLoadFailed => 'Não foi possível carregar os artigos.';

  @override
  String get commonAll => 'Todos';

  @override
  String get blogEmptyCategory => 'Nenhum artigo nesta categoria ainda';

  @override
  String get blogReadMore => 'Leia mais';

  @override
  String get aiProfileBioPreview => 'Prévia da página de bio';

  @override
  String get aiProfileConversionPage => 'Minha página de agendamentos';

  @override
  String get aiProfileConversionHint => 'Transforme seguidores em agendamentos';

  @override
  String get aiProfilePageTitle => 'Título da página';

  @override
  String get aiProfileMetaPlaceholder =>
      'Sua meta descrição aparece aqui. Descreva sua página para os resultados de busca.';

  @override
  String get aiProfileGooglePreview => 'Prévia da busca do Google';

  @override
  String get aiProfileSeoWeak => 'Fraco';

  @override
  String get aiProfileSeoExcellent => 'Excelente';

  @override
  String get aiProfileThemeAutoSave =>
      'Toque em um tema para salvá-lo automaticamente';

  @override
  String get aiProfileEditLinks => 'Editar meus links';

  @override
  String get aiProfilePreviewLoading => 'Carregando prévia...';

  @override
  String get aiProfilePreviewFailed => 'Não foi possível carregar a prévia';

  @override
  String get professionTrainer => 'Personal trainer';

  @override
  String get professionBeautician => 'Profissional de beleza';

  @override
  String get professionCoach => 'Coach e consultor';

  @override
  String get aiProfileProfessionTemplate => 'Início rápido para sua profissão';

  @override
  String get aiProfileReorderLinks => 'Arraste para reordenar os links ativos';

  @override
  String get appointmentDateTimeHeading => 'DATA E HORÁRIO';

  @override
  String authRegisterFailed(int status) {
    return 'Falha no cadastro (HTTP $status).';
  }

  @override
  String authLoginFailed(int status) {
    return 'Falha no login (HTTP $status).';
  }

  @override
  String authGoogleFailed(int status) {
    return 'Falha no login com Google (HTTP $status).';
  }

  @override
  String authConnectionFailed(String error) {
    return 'Não foi possível conectar ao servidor: $error';
  }

  @override
  String authGoogleError(String error) {
    return 'Falha no login com Google: $error';
  }

  @override
  String authAppleError(String error) {
    return 'Falha no login com Apple: $error';
  }

  @override
  String verifyEmailFailed(int status) {
    return 'Não foi possível verificar a confirmação (HTTP $status).';
  }

  @override
  String verifyEmailDescription(String email) {
    return 'Enviamos um link de verificação para $email. Abra o link e toque no botão abaixo.';
  }

  @override
  String verifyEmailResendCountdown(int seconds) {
    return 'Reenviar (${seconds}s)';
  }

  @override
  String get announcementInfo => 'Informação';

  @override
  String get announcementPromo => 'Oferta';

  @override
  String get announcementFeature => 'Novidade';

  @override
  String get announcementTitle => 'Aviso';

  @override
  String get announcementsTitle => 'Avisos';

  @override
  String get ratingAverage => 'Regular';

  @override
  String get workingTemplateStandard => 'Padrão';

  @override
  String get workingTemplateExpert => 'Especialista';

  @override
  String get workingTemplateWeekend => 'Fim de semana';

  @override
  String get professionDietitian => 'Nutricionista';

  @override
  String get professionPsychologist => 'Psicólogo';

  @override
  String get professionPhysiotherapist => 'Fisioterapeuta';

  @override
  String get aiToneFriendly => 'Amigável';

  @override
  String get aiToneFriendlyHint => 'Linguagem natural e acolhedora';

  @override
  String get aiToneProfessional => 'Profissional';

  @override
  String get aiToneProfessionalHint => 'Formal e confiável';

  @override
  String get aiToneWarm => 'Acolhedor';

  @override
  String get aiToneWarmHint => 'Empático e acessível';

  @override
  String get linkLocation => 'Localização';

  @override
  String get linkWebsite => 'Site';

  @override
  String previewLoadError(String error) {
    return 'Não foi possível carregar a prévia: $error';
  }

  @override
  String announcementLoadFailed(int status) {
    return 'Não foi possível carregar os avisos (HTTP $status).';
  }

  @override
  String announcementMinutesAgo(int count) {
    return 'Há $count min';
  }

  @override
  String announcementHoursAgo(int count) {
    return 'Há $count h';
  }

  @override
  String announcementDaysAgo(int count) {
    return 'Há $count dias';
  }

  @override
  String dashboardLowSms(int count) {
    return 'Seu saldo de SMS está baixo — restam $count mensagens.';
  }

  @override
  String get workingTemplateStandardDescription =>
      'Seg–Sex 09:00–12:00 / 13:00–17:00 · 20 min';

  @override
  String get workingTemplateAfternoonDescription =>
      'Seg–Sex 13:00–17:00 · 20 min';

  @override
  String get workingTemplateExpertDescription =>
      'Seg–Sáb 09:00–12:00 / 13:00–17:00 · 20 min';

  @override
  String get workingTemplateEveningDescription =>
      'Seg–Sáb 17:00–21:00 · 45 min';

  @override
  String get workingTemplateWeekendDescription =>
      'Sáb–Dom 10:00–17:00 · 30 min';

  @override
  String get loginWelcome => 'Bem-vindo de volta.';

  @override
  String get loginWelcomeDescription =>
      'Seus links, seus agendamentos e sua próxima conexão. Tudo em um só lugar.';

  @override
  String get loginEmailHint => 'voce@exemplo.com';

  @override
  String get loginPasswordHint => 'Digite sua senha';

  @override
  String get loginShowPassword => 'Mostrar senha';

  @override
  String get loginHidePassword => 'Ocultar senha';

  @override
  String get loginEmailValidation => 'Digite um endereço de e-mail válido.';

  @override
  String get loginPasswordValidation => 'Digite sua senha.';

  @override
  String get loginApple => 'Iniciar sessão com a Apple';

  @override
  String get dashboardWelcome => 'Seu dia, conectado.';

  @override
  String get dashboardBioHint =>
      'Um link para o seu mundo. Compartilhe onde as pessoas encontram você.';

  @override
  String get dashboardCopyLink => 'Copiar link';

  @override
  String get dashboardBioEmptyTitle => 'Sua próxima conexão começa aqui.';

  @override
  String get dashboardBioEmptyHint =>
      'Crie sua página Liik para reunir links e agendamentos.';

  @override
  String get dashboardScheduleEmptyHint =>
      'Um espaço na sua agenda. Adicione um agendamento ou compartilhe sua página.';

  @override
  String get dashboardViewAppointments => 'Ver agendamentos';

  @override
  String dashboardAnnouncements(int count) {
    return '$count novos avisos';
  }

  @override
  String get appointmentsHeading => 'Sua agenda, mais organizada.';

  @override
  String get appointmentsInView => 'Nesta visualização';

  @override
  String get appointmentsPlanRequired =>
      'Seu plano atual não inclui o gerenciamento de agendamentos.';

  @override
  String get calendarLoadError =>
      'Não foi possível carregar esta semana. Tente novamente.';

  @override
  String get contactsSubtitle =>
      'Seus contatos em um só lugar. Organize informações e agendamentos.';

  @override
  String get contactsAll => 'Todos';

  @override
  String contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contatos',
      one: '1 contato',
    );
    return '$_temp0';
  }

  @override
  String get contactsNoResults =>
      'Nenhum contato encontrado. Tente outro nome, telefone ou e-mail.';

  @override
  String get contactsLoadError =>
      'Não foi possível carregar os contatos. Tente novamente.';

  @override
  String get contactsSaveError =>
      'Não foi possível salvar este contato. Tente novamente.';

  @override
  String get contactsPhoneInvalid =>
      'Digite um telefone válido com até 15 dígitos.';

  @override
  String get contactsEmailInvalid => 'Digite um e-mail válido.';

  @override
  String get linksSubtitle =>
      'Seus links, do seu jeito. Reúna tudo o que você compartilha na sua página Liik.';

  @override
  String get linksFormSubtitle =>
      'Escolha o tipo, adicione um destino e personalize seu link.';

  @override
  String get linksOrderHint =>
      'Arraste o ícone para mudar a ordem na sua página.';

  @override
  String get linksOrderError =>
      'Não foi possível salvar a ordem. A ordem anterior foi restaurada.';

  @override
  String get linksLoadError => 'Não foi possível carregar seus links.';

  @override
  String get linksRetryHint => 'Verifique sua conexão e tente novamente.';

  @override
  String get linksSettingsError =>
      'Não foi possível carregar os tipos e as cores. Tente novamente.';

  @override
  String get linksDeleteTitle => 'Excluir este link?';

  @override
  String get linksDeleteBody => 'Este link será removido da sua página Liik.';

  @override
  String get linksDestinationRequired => 'Digite um destino para este link.';

  @override
  String get linksTextTooLong => 'Use no máximo 255 caracteres.';

  @override
  String get linksMoveUp => 'Mover para cima';

  @override
  String get linksMoveDown => 'Mover para baixo';

  @override
  String get linksDrag => 'Arraste para reordenar';

  @override
  String get linksActions => 'Ações do link';

  @override
  String get themesSubtitle =>
      'Dê a sua cara à sua página Liik. Escolha um tema e veja o resultado.';

  @override
  String get themesCurrent => 'Tema atual';

  @override
  String get themesUnsaved => 'Prévia de um novo tema · ainda não salvo';

  @override
  String get themesApplied => 'Tema aplicado';

  @override
  String get themesRefreshPreview => 'Atualizar prévia';

  @override
  String get themesLoadError =>
      'Não foi possível carregar os temas. Tente novamente.';

  @override
  String get themesSaveErrorMessage =>
      'Não foi possível salvar este tema. Tente novamente.';

  @override
  String get themesViewPreview => 'Ver prévia';

  @override
  String get profileTimezone => 'Fuso horário local';

  @override
  String get profileTimezoneHint =>
      'Seus agendamentos e horários de trabalho usam este fuso. O horário de verão é ajustado automaticamente.';

  @override
  String get profileTimezoneSearch => 'Buscar cidade ou fuso horário';

  @override
  String get profileTimezoneLoadError =>
      'Não foi possível carregar os fusos horários. Tente novamente.';

  @override
  String get supportSubtitle =>
      'Precisa de ajuda? Fale com a gente e acompanhe suas solicitações aqui.';

  @override
  String get supportFormHint => 'Conte o que aconteceu e como podemos ajudar.';

  @override
  String get supportActive => 'Ativas';

  @override
  String get supportFinished => 'Resolvidas e encerradas';

  @override
  String get supportFilterEmpty => 'Nenhuma solicitação nesta categoria.';

  @override
  String get supportLoadError =>
      'Não foi possível carregar as solicitações. Tente novamente.';

  @override
  String get supportSendError =>
      'Não foi possível enviar sua mensagem. Tente novamente.';

  @override
  String get supportCloseError =>
      'Não foi possível encerrar esta solicitação. Tente novamente.';

  @override
  String get supportMessageTooShort => 'Escreva pelo menos 5 caracteres.';

  @override
  String get supportReplyTooShort => 'Escreva pelo menos 2 caracteres.';

  @override
  String get supportCloseConfirm =>
      'Encerrar esta solicitação? Você não poderá mais responder.';

  @override
  String get supportInProgress => 'Em andamento';

  @override
  String get supportResolved => 'Resolvida';

  @override
  String get supportPriorityLow => 'Prioridade baixa';

  @override
  String get supportPriorityMedium => 'Prioridade normal';

  @override
  String get supportPriorityHigh => 'Prioridade alta';

  @override
  String get supportPriorityUrgent => 'Urgente';

  @override
  String get analyticsTitle => 'Análises';

  @override
  String get analyticsIntro =>
      'Veja como as pessoas descobrem seu perfil e interagem com seus links.';

  @override
  String get analyticsPeriod => 'Período do relatório';

  @override
  String analyticsDays(int count) {
    return '$count dias';
  }

  @override
  String get analyticsOverview => 'Visão geral';

  @override
  String get analyticsLinks => 'Desempenho dos links';

  @override
  String get analyticsAudience => 'Público';

  @override
  String get analyticsConversions => 'Taxa de cliques';

  @override
  String get analyticsClicks => 'Cliques nos links';

  @override
  String get analyticsVisitors => 'Visitantes únicos';

  @override
  String get analyticsUniqueClicks => 'Pessoas que clicaram';

  @override
  String get analyticsRate => 'Taxa de cliques';

  @override
  String get analyticsRedirects => 'Visualizações de redirecionamento';

  @override
  String get analyticsPrevious => 'vs. período anterior';

  @override
  String get analyticsNoPrevious => 'Sem base anterior';

  @override
  String get analyticsUnchanged => 'Sem alteração';

  @override
  String get analyticsTrend => 'Cliques diários nos links';

  @override
  String get analyticsTrendHint =>
      'Cliques totais e pessoas que clicaram por dia.';

  @override
  String get analyticsEmpty => 'Nenhuma atividade neste período';

  @override
  String get analyticsEmptyText =>
      'Visitas e cliques aparecerão aqui conforme as pessoas usarem seu perfil.';

  @override
  String get analyticsTopLinks => 'Principais links';

  @override
  String get analyticsLink => 'Link';

  @override
  String get analyticsShare => 'Participação nos cliques';

  @override
  String get analyticsNoLinks => 'Ainda não há cliques nos links.';

  @override
  String get analyticsViews => 'Visitantes';

  @override
  String get analyticsFunnel => 'Do perfil aos links';

  @override
  String get analyticsFunnelHint =>
      'Visitantes únicos e pessoas que clicaram são contados separadamente no período selecionado.';

  @override
  String get analyticsManual => 'Manual';

  @override
  String get analyticsAutomatic => 'Automático';

  @override
  String get analyticsNavigation => 'Métodos de navegação';

  @override
  String get analyticsNavigationHint =>
      'Como visitantes saem das páginas de redirecionamento para os destinos.';

  @override
  String get analyticsSources => 'Fontes de tráfego';

  @override
  String get analyticsDevices => 'Dispositivos';

  @override
  String get analyticsPlatforms => 'Plataformas';

  @override
  String get analyticsBrowsers => 'Navegadores';

  @override
  String get analyticsCountries => 'Países';

  @override
  String get analyticsHours => 'Cliques por hora';

  @override
  String get analyticsWeekdays => 'Cliques por dia da semana';

  @override
  String get analyticsUnknown => 'Desconhecido';

  @override
  String get analyticsMobile => 'Celular';

  @override
  String get analyticsDesktop => 'Computador';

  @override
  String get analyticsTablet => 'Tablet';

  @override
  String analyticsTimezone(String timezone) {
    return 'Fuso horário do relatório: $timezone';
  }

  @override
  String get analyticsDataNote =>
      'Apenas atividades registradas são incluídas. Métricas únicas usam identificadores anônimos de visitantes.';

  @override
  String get analyticsRateNote =>
      'Pessoas que clicaram divididas pelos visitantes únicos do perfil. Mede o engajamento com links.';

  @override
  String get analyticsLoadError =>
      'Não foi possível carregar as análises. Tente novamente.';

  @override
  String get themesFree => 'Grátis';

  @override
  String get themesPremium => 'Premium';

  @override
  String get themesClassic => 'Clássico';

  @override
  String get appointmentShare => 'Compartilhar agendamento';

  @override
  String get appointmentCopyLink => 'Copiar link';

  @override
  String get appointmentLinkCopied => 'Link copiado';

  @override
  String get appointmentCode => 'Código do agendamento';

  @override
  String get appointmentDetails => 'Detalhes do agendamento';

  @override
  String get appointmentNotes => 'Notas';

  @override
  String get appointmentStatusLabel => 'Status';

  @override
  String get appointmentOpenCalendar =>
      'Ver agendamento / adicionar ao calendário';

  @override
  String get appointmentHistory => 'Histórico de agendamentos';

  @override
  String get appointmentShareFailed =>
      'Não foi possível compartilhar. Tente copiar o link.';

  @override
  String get appointmentTimezone => 'Fuso horário';

  @override
  String get calendarSubtitle =>
      'Planeje sua semana, veja os detalhes e compartilhe agendamentos.';

  @override
  String get profileDesignIntro =>
      'Deixe seu perfil com a sua cara. Gerencie seus dados, visibilidade e conta.';
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');

  @override
  String get appointmentShare => 'Compartilhar agendamento';

  @override
  String get appointmentCopyLink => 'Copiar link';

  @override
  String get appointmentLinkCopied => 'Link copiado';

  @override
  String get appointmentCode => 'Código do agendamento';

  @override
  String get appointmentDetails => 'Detalhes do agendamento';

  @override
  String get appointmentNotes => 'Notas';

  @override
  String get appointmentStatusLabel => 'Status';

  @override
  String get appointmentOpenCalendar =>
      'Ver agendamento / adicionar ao calendário';

  @override
  String get appointmentHistory => 'Histórico de agendamentos';

  @override
  String get appointmentShareFailed =>
      'Não foi possível compartilhar. Tente copiar o link.';

  @override
  String get appointmentTimezone => 'Fuso horário';

  @override
  String get calendarSubtitle =>
      'Planeje sua semana, veja os detalhes e compartilhe agendamentos.';

  @override
  String get profileDesignIntro =>
      'Deixe seu perfil com a sua cara. Gerencie seus dados, visibilidade e conta.';
}

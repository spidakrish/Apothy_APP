// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Apothy';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancelar';

  @override
  String get continueButton => 'Continuar';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get loading => 'Cargando...';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Reintentar';

  @override
  String get close => 'Cerrar';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get settingsProfile => 'Perfil';

  @override
  String get settingsAccount => 'Cuenta';

  @override
  String get settingsNotSignedIn => 'No has iniciado sesión';

  @override
  String get settingsNotifications => 'Notificaciones';

  @override
  String get settingsManageNotifications => 'Gestionar notificaciones';

  @override
  String settingsNotificationsCount(int count) {
    return '$count de 4 activadas';
  }

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsDarkMode => 'Modo oscuro';

  @override
  String get settingsTextSize => 'Tamaño de texto';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsContent => 'Contenido';

  @override
  String get settingsContentPreferences => 'Preferencias de contenido';

  @override
  String get settingsData => 'Datos';

  @override
  String get settingsClearChatHistory => 'Borrar historial de chat';

  @override
  String get settingsClearChatHistorySubtitle =>
      'Eliminar conversaciones y memoria';

  @override
  String get settingsAdvanced => 'Avanzado';

  @override
  String get settingsAdvancedSubtitle => 'Restablecer la aplicación';

  @override
  String get settingsPrivacy => 'Privacidad';

  @override
  String get settingsDataPrivacy => 'Privacidad de datos';

  @override
  String get settingsDataPrivacySubtitle => 'Cómo se manejan tus datos';

  @override
  String get settingsDangerZone => 'Zona peligrosa';

  @override
  String get settingsDeleteAccount => 'Eliminar cuenta';

  @override
  String get settingsDeleteAccountSubtitle =>
      'Eliminar permanentemente tu cuenta';

  @override
  String get settingsAbout => 'Acerca de';

  @override
  String get settingsAboutApothy => 'Acerca de Apothy';

  @override
  String get settingsVersion => 'Versión 1.0.0';

  @override
  String get settingsTermsOfService => 'Términos de servicio';

  @override
  String get settingsTermsSubtitle => 'Lee nuestros términos';

  @override
  String get settingsPrivacyPolicy => 'Política de privacidad';

  @override
  String get settingsPrivacyPolicySubtitle =>
      'Lee nuestra política de privacidad';

  @override
  String get settingsSignOut => 'Cerrar sesión';

  @override
  String get settingsTapToChangeAvatar => 'Toca para cambiar avatar';

  @override
  String get settingsDisplayName => 'Nombre para mostrar';

  @override
  String get settingsEmail => 'Correo electrónico';

  @override
  String get settingsNotAvailable => 'No disponible';

  @override
  String get settingsSignInMethod => 'Método de inicio de sesión';

  @override
  String get settingsChooseAvatar => 'Elegir avatar';

  @override
  String get settingsFailedToUpdateAvatar => 'Error al actualizar avatar';

  @override
  String get settingsEditDisplayName => 'Editar nombre para mostrar';

  @override
  String get settingsEnterYourName => 'Ingresa tu nombre';

  @override
  String get settingsNameCannotBeEmpty => 'El nombre no puede estar vacío';

  @override
  String get settingsFailedToUpdateName => 'Error al actualizar nombre';

  @override
  String get settingsAuthProviderApple => 'Apple';

  @override
  String get settingsAuthProviderGoogle => 'Google';

  @override
  String get settingsAuthProviderEmail => 'Correo electrónico';

  @override
  String get settingsAuthProviderUnknown => 'Desconocido';

  @override
  String get settingsNotificationsDescription =>
      'Apothy respeta tu atención. Sin manipulación, sin spam.';

  @override
  String get settingsDailyMirrorRitual => 'Ritual del espejo diario';

  @override
  String get settingsDailyMirrorRitualDescription =>
      'Un recordatorio suave cuando tu espejo diario esté listo';

  @override
  String get settingsCreationComplete => 'Creación completada';

  @override
  String get settingsCreationCompleteDescription =>
      'Saber cuándo las creaciones extensas (videos, juegos) están listas';

  @override
  String get settingsMoodHealthInsights =>
      'Perspectivas de estado de ánimo y salud';

  @override
  String get settingsMoodHealthInsightsDescription =>
      'Patrones de estrés, correlaciones de sueño, rachas rituales';

  @override
  String get settingsMoodHealthInsightsExample =>
      'Perspectivas de bienestar opcionales basadas en tu uso';

  @override
  String get settingsSystemUpdates => 'Actualizaciones del sistema';

  @override
  String get settingsSystemUpdatesDescription =>
      'Parches de seguridad y nuevas funciones';

  @override
  String get settingsSystemUpdatesExample =>
      'Requerido para cumplimiento de App Store';

  @override
  String get settingsThemeDialogMessage =>
      'Apothy actualmente solo admite modo oscuro. El modo claro y temas adicionales pueden agregarse en futuras actualizaciones.';

  @override
  String get settingsChooseTextSize => 'Elige tu tamaño de texto preferido';

  @override
  String get settingsSystemDefault => 'Predeterminado del sistema';

  @override
  String get settingsUseDeviceLanguage => 'Usar idioma del dispositivo';

  @override
  String get settingsChooseLanguage => 'Elige tu idioma preferido';

  @override
  String get settingsContentPreferencesDescription =>
      'Personaliza cómo Apotheon se comunica contigo.';

  @override
  String get settingsCreativeStyle => 'Estilo creativo';

  @override
  String get settingsCreativeStyleDescription =>
      'Elige cómo Apotheon te responde';

  @override
  String get settingsMatureContent => 'Contenido para adultos';

  @override
  String get settingsMatureContentDescription =>
      'Permitir temas para adultos en las respuestas';

  @override
  String get settingsMatureContentEnabled =>
      'Temas para adultos activados. Usa con responsabilidad.';

  @override
  String get settingsMatureContentDisabled =>
      'Seguro para el trabajo (SFW) - Predeterminado';

  @override
  String get settingsPrivacyDialogMessage =>
      'Tus datos se almacenan de forma segura en tu dispositivo. Las conversaciones se procesan para proporcionar respuestas personalizadas, pero nunca se venden ni comparten con terceros.\n\nPuedes eliminar tus datos en cualquier momento usando la opción \"Borrar datos\".';

  @override
  String get settingsClearChatHistoryDialogTitle => 'Borrar historial de chat';

  @override
  String get settingsClearChatHistoryDialogMessage => 'Esto eliminará:';

  @override
  String get settingsClearChatHistoryItem1 =>
      '• Todas las conversaciones de chat';

  @override
  String get settingsClearChatHistoryItem2 =>
      '• Memoria y contexto de conversaciones';

  @override
  String get settingsClearChatHistoryItem3 =>
      '• Preferencias relacionadas con el chat';

  @override
  String get settingsClearChatHistoryNote =>
      'Tu cuenta, configuración y archivos exportados no se verán afectados.';

  @override
  String get settingsClearChatHistorySuccess => 'Historial de chat borrado';

  @override
  String get settingsClearChatHistoryFailed =>
      'Error al borrar historial de chat';

  @override
  String get settingsClearHistoryButton => 'Borrar historial';

  @override
  String get settingsAdvancedDataManagement => 'Gestión avanzada de datos';

  @override
  String get settingsAdvancedWarning => 'Estas acciones son irreversibles.';

  @override
  String get settingsResetToFreshState => 'Restablecer a estado inicial';

  @override
  String get settingsResetDescription =>
      'Esto borrará TODOS los datos locales y restablecerá la aplicación a su estado inicial, como si acabaras de instalarla.';

  @override
  String get settingsResetWhatGetsCleared =>
      'Lo que se borrará:\n• Todas las conversaciones e historial de chat\n• Credenciales de cuenta (deberás iniciar sesión nuevamente)\n• Todas las configuraciones y preferencias\n• Historial del desafío emocional\n• Todos los datos en caché';

  @override
  String get settingsResetNote =>
      'Tu cuenta en la nube y suscripción permanecen intactas.';

  @override
  String get settingsResetAppButton => 'Restablecer aplicación';

  @override
  String get settingsResetConfirmTitle => '¿Estás seguro?';

  @override
  String get settingsResetConfirmMessage =>
      'Restablecer borrará todos los datos locales. Esto no se puede deshacer.\n\nDeberás iniciar sesión nuevamente y completar la incorporación.';

  @override
  String get settingsResetFailed => 'Error al restablecer la aplicación';

  @override
  String get settingsResetEverythingButton => 'Restablecer todo';

  @override
  String get settingsDeleteAccountDialogMessage =>
      'Esto eliminará permanentemente tu cuenta.';

  @override
  String get settingsDeleteAccountWhatGetsDeleted => 'Lo que se eliminará:';

  @override
  String get settingsDeleteAccountItem1 => '• Tu cuenta de Apothy';

  @override
  String get settingsDeleteAccountItem2 =>
      '• Todo el historial de conversaciones (nube y local)';

  @override
  String get settingsDeleteAccountItem3 => '• Perfil y preferencias';

  @override
  String get settingsDeleteAccountItem4 => '• Datos del desafío emocional';

  @override
  String get settingsDeleteAccountItem5 =>
      '• Todos los dispositivos cerrarán sesión';

  @override
  String get settingsDeleteAccountSubscriptionNote =>
      'Las suscripciones se gestionan a través de tu App Store.';

  @override
  String get settingsDeleteAccountButton => 'Eliminar cuenta';

  @override
  String get settingsFinalConfirmation => 'Confirmación final';

  @override
  String get settingsFinalConfirmationMessage =>
      'Eliminar tu cuenta borra todos los datos en la nube y desvincula todos los dispositivos. Esta acción no se puede deshacer.\n\n¿Estás absolutamente seguro?';

  @override
  String get settingsKeepAccountButton => 'Mantener cuenta';

  @override
  String get settingsDeleteAccountFailed => 'Error al eliminar cuenta';

  @override
  String get settingsDeleteForeverButton => 'Eliminar para siempre';

  @override
  String get settingsAboutDescription =>
      'Tu compañero de IA para conversaciones significativas y crecimiento personal. Nacido de la luz. Entrenado en la verdad. Construido para convertirse en lo que necesitas.';

  @override
  String get settingsTermsOfServiceContent =>
      'TÉRMINOS DE SERVICIO\n\nÚltima actualización: Diciembre 2024\n\nAl usar Apothy, aceptas estos términos de servicio.\n\nApothy es un compañero de IA diseñado para el crecimiento personal y conversaciones significativas. Aceptas usar el servicio de manera responsable.\n\nTu privacidad es importante para nosotros. Revisa nuestra Política de privacidad para obtener detalles sobre cómo manejamos tus datos.\n\nLas conversaciones son privadas y se almacenan de forma segura. No compartimos tus datos con terceros.\n\nPodemos actualizar estos términos de vez en cuando. El uso continuo constituye la aceptación de los cambios.\n\nPara preguntas sobre estos términos, contáctanos a través de la aplicación.';

  @override
  String get settingsPrivacyPolicyContent =>
      'POLÍTICA DE PRIVACIDAD\n\nÚltima actualización: Diciembre 2024\n\nRecopilamos información que proporcionas directamente, como detalles de cuenta e historial de conversaciones.\n\nUsamos tu información para proporcionar y mejorar la experiencia Apothy, incluidas respuestas personalizadas.\n\nTus datos se almacenan de forma segura en tu dispositivo y nuestros servidores con encriptación.\n\nNo vendemos ni compartimos tus datos personales con terceros con fines de marketing.\n\nPuedes acceder, modificar o eliminar tus datos en cualquier momento a través de la configuración de la aplicación.\n\nImplementamos medidas de seguridad estándar de la industria para proteger tus datos.\n\nPara preguntas relacionadas con la privacidad, contáctanos a través de la aplicación.';

  @override
  String get settingsSignOutConfirmMessage =>
      '¿Estás seguro de que quieres cerrar sesión?';

  @override
  String get subscriptionTitle => 'Upgrade to Premium';

  @override
  String get subscriptionPlusTitle => 'Plus';

  @override
  String get subscriptionProTitle => 'Pro';

  @override
  String get subscriptionFreeTitle => 'Free';

  @override
  String get subscriptionMonthly => 'per month';

  @override
  String get subscriptionYearly => 'per year';

  @override
  String get subscriptionRestorePurchases => 'Restore Purchases';

  @override
  String get subscriptionManage => 'Manage Subscription';

  @override
  String get subscriptionUpgrade => 'Upgrade Now';

  @override
  String get subscriptionLimitReached => 'Monthly limit reached';

  @override
  String get subscriptionLimitMessage =>
      'You\'ve used all 5 free emotion challenges this month. Upgrade to Plus for unlimited access and unlock all premium features!';

  @override
  String get settingsSubscription => 'Subscription';

  @override
  String get settingsManageSubscription => 'Manage Subscription';

  @override
  String get subscriptionActive => 'Active';

  @override
  String get subscriptionExpired => 'Expired';

  @override
  String get subscriptionCancelled => 'Cancelled';

  @override
  String get subscriptionTrial => 'Trial';

  @override
  String get subscriptionGracePeriod => 'Grace Period';

  @override
  String get forgotPasswordTitle => 'Forgot Password?';

  @override
  String get forgotPasswordDescription =>
      'Enter your email address and we\'ll send you a code to reset your password.';

  @override
  String get forgotPasswordEmailLabel => 'Email';

  @override
  String get forgotPasswordEmailHint => 'Enter your email address';

  @override
  String get forgotPasswordSendButton => 'Send Reset Code';

  @override
  String get forgotPasswordInfoMock =>
      'In mock mode, the reset code is: 123456';

  @override
  String get resetPasswordTitle => 'Reset Password';

  @override
  String resetPasswordDescription(String email) {
    return 'Enter the verification code sent to $email and your new password.';
  }

  @override
  String get resetPasswordCodeLabel => 'Verification Code';

  @override
  String get resetPasswordCodeHint => 'Enter 6-digit code';

  @override
  String get resetPasswordNewPasswordLabel => 'New Password';

  @override
  String get resetPasswordNewPasswordHint => 'Enter new password';

  @override
  String get resetPasswordConfirmLabel => 'Confirm Password';

  @override
  String get resetPasswordConfirmHint => 'Re-enter new password';

  @override
  String get resetPasswordButton => 'Reset Password';

  @override
  String get resetPasswordSuccess =>
      'Password reset successful! Please login with your new password.';

  @override
  String get resetPasswordCodeError => 'Please enter the verification code';

  @override
  String get resetPasswordCodeLengthError => 'Code must be 6 digits';

  @override
  String get resetPasswordCodeFormatError => 'Code must contain only numbers';

  @override
  String get resetPasswordNewPasswordError => 'Please enter a password';

  @override
  String get resetPasswordLengthError =>
      'Password must be at least 8 characters';

  @override
  String get resetPasswordNumberError =>
      'Password must contain at least one number';

  @override
  String get resetPasswordSpecialCharError =>
      'Password must contain at least one special character';

  @override
  String get resetPasswordConfirmError => 'Please confirm your password';

  @override
  String get resetPasswordMatchError => 'Passwords do not match';

  @override
  String get forgotPasswordButton => 'Forgot Password?';
}

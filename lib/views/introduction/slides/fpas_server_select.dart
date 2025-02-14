import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/services/alert_api/fpas.dart';
import 'package:foss_warn/services/api_handler.dart';
import 'package:foss_warn/services/url_launcher.dart';
import 'package:foss_warn/constants.dart' as constants;
import 'package:foss_warn/views/introduction/widgets/base_slide.dart';

final _fpasServerExplanationURL =
    'https://github.com/nucleus-ffm/foss_warn/wiki/What-is-the-FOSS-Public-Alert-Server-and-why-do-I-have-to-select-a-server%3F';

class IntroductionFPASServerSelectionSlide extends ConsumerStatefulWidget {
  const IntroductionFPASServerSelectionSlide({
    required this.selectedServerSettings,
    required this.onServerSelected,
    super.key,
  });

  final ServerSettings? selectedServerSettings;
  final void Function(ServerSettings serverSettings) onServerSelected;

  @override
  ConsumerState<IntroductionFPASServerSelectionSlide> createState() =>
      _IntroductionFPASServerSelectionSlideState();
}

class _IntroductionFPASServerSelectionSlideState
    extends ConsumerState<IntroductionFPASServerSelectionSlide> {
  bool isCustomServerSelected = false;
  bool? isServerURLValid;
  bool serverSettingsConfirmed = false;

  final _formKey = GlobalKey<FormState>();
  final _serverURLTextfieldController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.selectedServerSettings != null) {
      isCustomServerSelected =
          widget.selectedServerSettings!.url != constants.defaultFPASServerUrl;
      _serverURLTextfieldController.text = widget.selectedServerSettings!.url;
    }
  }

  @override
  void dispose() {
    _serverURLTextfieldController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void onServerOptionSelected(bool? option) {
      isCustomServerSelected = option ?? false;

      setState(() {});
    }

    Future<void> fetchServerSettings({String? newUrl}) async {
      var url = newUrl ?? constants.defaultFPASServerUrl;
      ServerSettings? serverSettings;
      try {
        serverSettings = await ref
            .read(alertApiProvider)
            .fetchServerSettings(overrideUrl: url);
      } on UnreachableServerError {
        serverSettings = null;
      } on ArgumentError {
        serverSettings = null;
      }

      serverSettingsConfirmed = newUrl != null ? false : serverSettings != null;
      isServerURLValid = serverSettings != null;

      if (serverSettings != null) {
        widget.onServerSelected(serverSettings);
      }

      setState(() {});
    }

    Future<void> onSave() async {
      if (!_formKey.currentState!.validate()) {
        serverSettingsConfirmed = false;
        isServerURLValid = false;

        setState(() {});
        return;
      }

      await fetchServerSettings(newUrl: _serverURLTextfieldController.text);

      // unset focus to hide the keyboard again
      FocusManager.instance.primaryFocus?.unfocus();
    }

    return _FPASServerSlideLayout(
      isCustomServerSelected: isCustomServerSelected,
      serverSettingsConfirmed: serverSettingsConfirmed,
      isServerURLValid: isServerURLValid,
      serverSettings: widget.selectedServerSettings,
      formKey: _formKey,
      serverURLTextfieldController: _serverURLTextfieldController,
      onServerOptionSelected: onServerOptionSelected,
      onDefaultServerConfirmPressed: fetchServerSettings,
      onSave: onSave,
    );
  }
}

class _FPASServerSlideLayout extends StatelessWidget {
  const _FPASServerSlideLayout({
    required this.isCustomServerSelected,
    required this.serverSettingsConfirmed,
    required this.isServerURLValid,
    required this.serverSettings,
    required this.formKey,
    required this.serverURLTextfieldController,
    required this.onServerOptionSelected,
    required this.onDefaultServerConfirmPressed,
    required this.onSave,
  });

  final bool isCustomServerSelected;
  final bool serverSettingsConfirmed;
  final bool? isServerURLValid;
  final ServerSettings? serverSettings;
  final GlobalKey<FormState> formKey;
  final TextEditingController serverURLTextfieldController;
  final void Function(bool? option) onServerOptionSelected;
  final VoidCallback onDefaultServerConfirmPressed;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context)!;
    var theme = Theme.of(context);

    return IntroductionBaseSlide(
      imagePath: "assets/app_icon/app_icon.png",
      title: localizations.welcome_view_foss_server_selection_headline,
      text: localizations.welcome_view_foss_server_selection_text,
      footer: Column(
        children: [
          Text(
            localizations.welcome_view_foss_server_selection_select,
            style: TextStyle(fontSize: 17),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.open_in_browser),
              Flexible(
                fit: FlexFit.loose,
                child: TextButton(
                  onPressed: () =>
                      launchUrlInBrowser(_fpasServerExplanationURL),
                  child: Text(
                    localizations
                        .welcome_view_foss_server_selection_select_instance_helptext,
                  ),
                ),
              ),
            ],
          ),
          // Server selection
          DropdownButtonFormField<bool>(
            value: isCustomServerSelected,
            icon: const Icon(Icons.arrow_downward),
            iconSize: 24,
            elevation: 16,
            style: TextStyle(color: theme.colorScheme.primary),
            onChanged: onServerOptionSelected,
            items: [false, true]
                .map<DropdownMenuItem<bool>>((isCustomServerSelected) {
              var text = localizations
                  .welcome_view_foss_server_selection_option_default_title(
                constants.defaultFPASServerUrl,
              );

              if (isCustomServerSelected) {
                text = localizations
                    .welcome_view_foss_server_selection_option_custom_title;
              }

              return DropdownMenuItem<bool>(
                value: isCustomServerSelected,
                child: Text(text),
              );
            }).toList(),
          ),
          SizedBox(
            height: 10,
          ),

          if (!isCustomServerSelected) ...[
            _DefaultServerSelection(
              areServerSettingsConfirmed: serverSettingsConfirmed,
              onConfirmPressed: onDefaultServerConfirmPressed,
            ),
          ] else ...[
            _CustomServerSelection(
              formKey: formKey,
              serverURLTextfieldController: serverURLTextfieldController,
              isServerURLValid: isServerURLValid,
              onSave: onSave,
            ),
          ],

          if (serverSettings != null) ...[
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                localizations.welcome_view_foss_server_operator(
                  serverSettings!.operator,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DefaultServerSelection extends StatelessWidget {
  const _DefaultServerSelection({
    required this.areServerSettingsConfirmed,
    required this.onConfirmPressed,
  });

  final bool areServerSettingsConfirmed;
  final VoidCallback onConfirmPressed;

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context)!;
    var theme = Theme.of(context);

    return Column(
      children: [
        if (!areServerSettingsConfirmed) ...[
          TextButton(
            onPressed: onConfirmPressed,
            style: TextButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
            ),
            child: Text(
              localizations.welcome_view_foss_server_selection_save,
              style: TextStyle(color: theme.colorScheme.onPrimary),
            ),
          ),
        ] else ...[
          Text(localizations.welcome_view_foss_server_selection_saved),
        ],
      ],
    );
  }
}

class _CustomServerSelection extends StatelessWidget {
  const _CustomServerSelection({
    required this.formKey,
    required this.serverURLTextfieldController,
    required this.isServerURLValid,
    required this.onSave,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController serverURLTextfieldController;
  final bool? isServerURLValid;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context)!;

    return Form(
      key: formKey,
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: serverURLTextfieldController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return localizations
                      .welcome_view_foss_server_enter_url_validator_empty;
                }
                return null;
              },
              decoration: InputDecoration(
                labelText:
                    localizations.welcome_view_foss_server_enter_url_label,
                errorText: isServerURLValid != null && !isServerURLValid!
                    ? localizations.welcome_view_foss_server_enter_url_error
                    : null,
              ),
            ),
          ),
          TextButton(
            onPressed: onSave,
            child: Text(localizations.main_dialog_save),
          ),
        ],
      ),
    );
  }
}

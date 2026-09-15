part of 'host_operational_roster_panel.dart';

class HostManualAttendeeSheet extends StatefulWidget {
  const HostManualAttendeeSheet({super.key});

  @override
  State<HostManualAttendeeSheet> createState() =>
      _HostManualAttendeeSheetState();
}

class _HostManualAttendeeSheetState extends State<HostManualAttendeeSheet> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  var _showNameError = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CatchSheet(
      title: context.l10n.hostsOperationalRosterManualTitle,
      subtitle: context.l10n.hostsOperationalRosterManualSubtitle,
      keyboardSafe: true,
      footer: CatchButton(
        label: context.l10n.hostsOperationalRosterManualSave,
        onPressed: _submit,
        fullWidth: true,
      ),
      child: CatchFieldLanes.divided(
        children: [
          CatchField.input(
            copy: catchFieldCopy(context.l10n),
            title: context.l10n.hostsOperationalRosterFieldName,
            contract: CatchContractConstraints
                .importEventAttendeesCallablePayloadRowsItemsDisplayName,
            controller: _nameController,
            errorText: _showNameError
                ? context.l10n.hostsOperationalRosterManualNameRequired
                : null,
          ),
          CatchField.input(
            copy: catchFieldCopy(context.l10n),
            title: context.l10n.hostsOperationalRosterFieldPhone,
            contract: CatchContractConstraints
                .importEventAttendeesCallablePayloadRowsItemsPhone,
            controller: _phoneController,
            keyboardType: TextInputType.phone,
          ),
          CatchField.input(
            copy: catchFieldCopy(context.l10n),
            title: context.l10n.hostsOperationalRosterFieldEmail,
            contract: CatchContractConstraints
                .importEventAttendeesCallablePayloadRowsItemsEmail,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _showNameError = true);
      return;
    }
    Navigator.of(context).pop(
      EventAttendeeImportRow(
        rowId: 'manual',
        displayName: name,
        phone: _nullableText(_phoneController.text),
        email: _nullableText(_emailController.text),
        status: EventAttendeeStatus.registered,
      ),
    );
  }
}

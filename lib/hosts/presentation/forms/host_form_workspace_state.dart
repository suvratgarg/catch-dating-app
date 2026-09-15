enum HostFormWorkspaceView { overview, questions, responses, settings }

HostFormWorkspaceView? hostFormViewFromQuery(String? value) =>
    HostFormWorkspaceView.values
        .where((view) => view.name == value)
        .firstOrNull;

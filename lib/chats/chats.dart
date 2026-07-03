/// Chats feature barrel file.
///
/// Export the public surface: domain models, repository interface, and
/// top-level screens and widgets that external features and Widgetbook
/// depend on.
library;

export 'data/conversation_repository.dart' show ConversationRepository;
export 'domain/chat_message.dart';
export 'domain/suvbot_action_item.dart';
export 'presentation/chat_screen.dart'; // public-api: route entry point exposed to app routing
export 'presentation/widgets/chat_input_bar.dart'; // public-api: shared presentation component used outside this feature
export 'presentation/widgets/chat_message_list.dart'; // public-api: shared presentation component used outside this feature
export 'presentation/widgets/chat_share_card.dart'; // public-api: shared presentation component used outside this feature
export 'presentation/widgets/message_bubble.dart'; // public-api: shared presentation component used outside this feature
export 'presentation/widgets/suvbot_action_bar.dart'; // public-api: shared presentation component used outside this feature

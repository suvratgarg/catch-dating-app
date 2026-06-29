/// Chats feature barrel file.
///
/// Export the public surface: domain models, repository interface, and
/// top-level screens and widgets that external features and Widgetbook
/// depend on.
library chats;

export 'data/conversation_repository.dart' show ConversationRepository;
export 'domain/chat_message.dart';
export 'domain/suvbot_action_item.dart';
export 'presentation/chat_screen.dart';
export 'presentation/widgets/chat_input_bar.dart';
export 'presentation/widgets/chat_message_list.dart';
export 'presentation/widgets/chat_share_card.dart';
export 'presentation/widgets/message_bubble.dart';
export 'presentation/widgets/suvbot_action_bar.dart';

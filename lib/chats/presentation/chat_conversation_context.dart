enum ChatConversationContext { match, contactedHost, attendeeInquiry }

ChatConversationContext chatConversationContextFor({
  required bool isHostInquiry,
  required bool viewerIsHost,
}) {
  if (!isHostInquiry) return ChatConversationContext.match;
  return viewerIsHost
      ? ChatConversationContext.attendeeInquiry
      : ChatConversationContext.contactedHost;
}

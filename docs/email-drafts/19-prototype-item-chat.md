# Email Draft: Adding prototypeItem to chat ListView

## Why

The chat screen uses `ListView.builder` which estimates item positions based on
a default height (usually 0 or a platform default). Without `prototypeItem`,
every new message forces Flutter to recompute all item extents from scratch
because it doesn't know the typical item size.

Adding a `prototypeItem` gives Flutter a representative widget to measure
once, then use that measurement as the estimated height for all items. This
significantly reduces layout work when messages stream in rapidly.

## What changed

```dart
ListView.builder(
  controller: _scrollController,
  padding: const EdgeInsets.symmetric(horizontal: Sizes.p12, vertical: Sizes.p16),
  itemCount: messages.length,
  prototypeItem: const MessageBubble(    // NEW
    message: ChatMessage(
      id: '',
      matchId: '',
      senderId: '',
      text: 'placeholder',
      timestamp: null,
      textMetadata: null,
    ),
    isOwn: false,
  ),
  itemBuilder: (context, i) { ... },
)
```

## How it works

Flutter lays out the `prototypeItem` once during the initial build. It uses
that widget's height as a base estimate for all items in the list. When
`itemBuilder` produces real items, Flutter only needs to adjust the offset
for items that differ significantly from the prototype — which for chat
messages is most of them, but the initial estimate still prevents layout
thrashing on first render.

## How to verify

Send several messages rapidly and observe scroll performance. The
`ListView.builder` should maintain smooth scrolling without jank.

import { ContextMenuWithView } from 'context-menu-with-view';
import { ScrollView, StyleSheet, Text, View } from 'react-native';

const messages = [
  { id: '1', text: 'Hey! How are you?', isOwn: false },
  { id: '2', text: 'I am doing great, thanks!', isOwn: true },
  { id: '3', text: 'That is awesome to hear!', isOwn: false },
  { id: '4', text: 'What are you up to today?', isOwn: false },
  { id: '5', text: 'Working on this cool React Native project', isOwn: true },
  { id: '6', text: 'Sounds exciting!', isOwn: false },
];

export default function App() {
  return (
    <View style={styles.container}>
      <ScrollView style={styles.scrollContainer} contentContainerStyle={styles.scrollContent}>
        <Text style={styles.header}>Messages</Text>

        {messages.map((message) => (
          <ContextMenuWithView
            key={message.id}
            menuItems={[
              { id: 'reply', title: 'Reply', systemImage: 'arrowshape.turn.up.left' },
              { id: 'copy', title: 'Copy', systemImage: 'doc.on.doc' },
              { id: 'delete', title: 'Delete', systemImage: 'trash' },
            ]}
            auxiliaryAlignment={message.isOwn ? 'right' : 'left'}
            auxiliaryBackgroundColor={message.isOwn ? '#007AFF' : '#2C2C2E'}
            plusButtonColor="#FFFFFF"
            emojis={['❤️', '👍', '😂', '😮', '😢', '🙏']}
            onMenuAction={(event) => {
              console.log('Menu action:', event.nativeEvent, 'for message:', message.id);
            }}
            onEmojiSelected={(event) => {
              console.log('Emoji selected:', event.nativeEvent.emoji, 'for message:', message.id);
            }}
            onPlusButtonPressed={() => {
              console.log('Plus button pressed for message:', message.id);
            }}
            style={[styles.messageContainer, message.isOwn && styles.ownMessage]}
          >
            <View style={[styles.messageBubble, message.isOwn && styles.ownBubble]}>
              <Text style={[styles.messageText, message.isOwn && styles.ownText]}>
                {message.text}
              </Text>
            </View>
          </ContextMenuWithView>
        ))}
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#000',
  },
  scrollContainer: {
    flex: 1,
  },
  scrollContent: {
    padding: 16,
  },
  header: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#fff',
    marginBottom: 20,
  },
  messageContainer: {
    marginBottom: 8,
    alignSelf: 'flex-start',
    maxWidth: '75%',
  },
  ownMessage: {
    alignSelf: 'flex-end',
  },
  messageBubble: {
    backgroundColor: '#2C2C2E',
    borderRadius: 18,
    paddingHorizontal: 16,
    paddingVertical: 10,
  },
  ownBubble: {
    backgroundColor: '#007AFF',
  },
  messageText: {
    fontSize: 16,
    color: '#fff',
  },
  ownText: {
    color: '#fff',
  },
});

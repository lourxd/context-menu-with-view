import { ContextMenuWithView } from 'context-menu-with-view';
import { ScrollView, StyleSheet, Text, View } from 'react-native';

const messages = [
  { id: "1", text: "Hey! How are you?", isOwn: false },
  { id: "2", text: "I am doing great, thanks!", isOwn: true },
  { id: "3", text: "That is awesome to hear!", isOwn: false },
  { id: "4", text: "What are you up to today?", isOwn: false },
  { id: "5", text: "Working on this cool React Native project", isOwn: true },
  { id: "6", text: "Sounds exciting!", isOwn: false },
  { id: "7", text: "Yeah, it's a context menu component", isOwn: true },
  { id: "8", text: "What does it do?", isOwn: false },
  {
    id: "9",
    text: "It adds long-press context menus to any view with emoji reactions",
    isOwn: true,
  },
  { id: "10", text: "That's really cool! Can you customize it?", isOwn: false },
  {
    id: "11",
    text: "Absolutely! You can add custom menu items, emojis, colors",
    isOwn: true,
  },
  { id: "12", text: "Nice! Is it hard to implement?", isOwn: false },
  { id: "13", text: "Not at all, super simple API", isOwn: true },
  {
    id: "14",
    text: "I might need something like that for my app",
    isOwn: false,
  },
  { id: "15", text: "You should check it out! It works on iOS", isOwn: true },
  { id: "16", text: "What about Android?", isOwn: false },
  {
    id: "17",
    text: "iOS only for now, using native UIKit components",
    isOwn: true,
  },
  { id: "18", text: "Makes sense. How's the performance?", isOwn: false },
  {
    id: "19",
    text: "Really smooth! Native performance all the way",
    isOwn: true,
  },
  { id: "20", text: "Awesome! Can I try it?", isOwn: false },
  { id: "21", text: "Of course! Let me send you the link", isOwn: true },
  { id: "22", text: "Thanks! Appreciate it", isOwn: false },
  { id: "23", text: "No problem at all!", isOwn: true },
  {
    id: "24",
    text: "By the way, are you going to the meetup next week?",
    isOwn: false,
  },
  { id: "25", text: "Yeah, I'll be there! You?", isOwn: true },
  { id: "26", text: "Definitely! Should be fun", isOwn: false },
  {
    id: "27",
    text: "Great! We can talk more about React Native stuff",
    isOwn: true,
  },
  { id: "28", text: "Sounds like a plan!", isOwn: false },
  { id: "29", text: "Perfect! See you then", isOwn: true },
  { id: "29", text: "Perfect! See you aojsfoiahsdfashdfhasdhfiuashdfiuhasdiufhaisudhfiuahsdifuhasiduhfaiushdfiuahsdifuhasiduhfaiushdfiuahsdfiuhasdiufhaisudhfiaushdfiuahsdfiuhasdiufhaisudhfiuashdfiuahsdfiuhasdiufhaisudhfiausdhfiuashdfiuahsdfiuahsdifuhasidufhaisudhfiuashdfiuashdfiuh", isOwn: true },
  { id: "30", text: "See you! 👋", isOwn: false },
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

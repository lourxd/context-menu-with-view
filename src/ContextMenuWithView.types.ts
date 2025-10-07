import type { ReactNode } from 'react';
import type { StyleProp, ViewStyle } from 'react-native';

export type OnMenuActionEventPayload = {
  id: string;
  title: string;
};

export type OnEmojiSelectedEventPayload = {
  emoji: string;
};

export type MenuItem = {
  id: string;
  title: string;
  systemImage?: string;
};

export type AuxiliaryAlignment = 'left' | 'center' | 'right';

export type ContextMenuWithViewProps = {
  children: ReactNode;
  menuItems?: MenuItem[];
  auxiliaryAlignment?: AuxiliaryAlignment;
  auxiliaryBackgroundColor?: string;
  plusButtonColor?: string;
  emojis?: string[];
  onMenuAction?: (event: { nativeEvent: OnMenuActionEventPayload }) => void;
  onEmojiSelected?: (event: { nativeEvent: OnEmojiSelectedEventPayload }) => void;
  onPlusButtonPressed?: () => void;
  style?: StyleProp<ViewStyle>;
};

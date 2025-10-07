import { requireNativeView } from 'expo';
import * as React from 'react';

import { ContextMenuWithViewProps } from './ContextMenuWithView.types';

const NativeView: React.ComponentType<ContextMenuWithViewProps> =
  requireNativeView('ContextMenuWithView');

export default function ContextMenuWithView(props: ContextMenuWithViewProps) {
  return <NativeView {...props} />;
}

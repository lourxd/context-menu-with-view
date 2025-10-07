import * as React from 'react';

import { ContextMenuWithViewProps } from './ContextMenuWithView.types';

export default function ContextMenuWithView(props: ContextMenuWithViewProps) {
  return (
    <div>
      <iframe
        style={{ flex: 1 }}
        src={props.url}
        onLoad={() => props.onLoad({ nativeEvent: { url: props.url } })}
      />
    </div>
  );
}

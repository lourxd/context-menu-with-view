import { registerWebModule, NativeModule } from 'expo';

import { ContextMenuWithViewModuleEvents } from './ContextMenuWithView.types';

class ContextMenuWithViewModule extends NativeModule<ContextMenuWithViewModuleEvents> {
  PI = Math.PI;
  async setValueAsync(value: string): Promise<void> {
    this.emit('onChange', { value });
  }
  hello() {
    return 'Hello world! 👋';
  }
}

export default registerWebModule(ContextMenuWithViewModule, 'ContextMenuWithViewModule');

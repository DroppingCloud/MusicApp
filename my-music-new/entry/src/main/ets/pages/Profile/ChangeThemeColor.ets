import AppConstants from '../../constants/AppConstants';
import preferences from '@ohos.data.preferences';
import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import { ConfigurationConstant } from '@kit.AbilityKit';

@Entry
@Component
struct ChangeThemeColor {
  @StorageLink('theme') theme: string = 'auto';
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;

  aboutToAppear() {
    this.loadTheme();
  }

  async loadTheme() {
    try {
      const pref = await preferences.getPreferences(this.context, 'app_settings');
      const value = await pref.get(AppConstants.STORAGE_KEYS.THEME, 'auto') as string;
      this.theme = value;
      this.applyColorMode(value);
      AppStorage.setOrCreate('theme', value);
    } catch (error) {
      console.error('Failed to load theme:', error);
    }
  }

  async setTheme(theme: string) {
    try {
      this.theme = theme;
      const pref = await preferences.getPreferences(this.context, 'app_settings');
      await pref.put(AppConstants.STORAGE_KEYS.THEME, theme);
      await pref.flush();
      AppStorage.setOrCreate('theme', theme);
      this.applyColorMode(theme);
    } catch (error) {
      console.error('Failed to save theme:', error);
    }
  }

  applyColorMode(theme: string) {
    if (theme === 'dark') {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
    } else if (theme === 'light') {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
    } else {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    }
  }

  build() {
    Column() {
      Text('主题模式选择')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 32, top: 32 })
        .alignSelf(ItemAlign.Center)
        .fontColor(this.theme === 'dark' ? $r('app.color.text_primary') : $r('app.color.text_primary'))

      Row() {
        Button('浅色')
          .width(120)
          .height(48)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .backgroundColor(this.theme === 'light' ? $r('app.color.primary') : $r('app.color.surface'))
          .fontColor(this.theme === 'light' ? $r('app.color.text_primary') : $r('app.color.text_primary'))
          .borderRadius(24)
          .margin({ right: 16 })
          .onClick(() => {
            this.setTheme('light');
          })

        Button('深色')
          .width(120)
          .height(48)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .backgroundColor(this.theme === 'dark' ? $r('app.color.primary') : $r('app.color.surface'))
          .fontColor(this.theme === 'dark' ? $r('app.color.text_primary') : $r('app.color.text_primary'))
          .borderRadius(24)
          .onClick(() => {
            this.setTheme('dark');
          })
      }
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: 32 })

      Button('返回')
        .width(120)
        .height(40)
        .fontSize(16)
        .margin({ top: 32 })
        .onClick(() => {
          router.back();
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.theme === 'dark' ? $r('app.color.page_background') : $r('app.color.page_background'))
    .justifyContent(FlexAlign.Center)
  }
}

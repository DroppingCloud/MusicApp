import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AuthManager } from '../services/AuthManager';
import preferences from '@ohos.data.preferences';
import AppConstants from '../constants/AppConstants';
import common from '@ohos.app.ability.common';
const DOMAIN = 0x0000;

async function applySavedTheme(context: common.UIAbilityContext) {
   try {
      const pref = await preferences.getPreferences(context, 'app_settings');
      const theme = await pref.get(AppConstants.STORAGE_KEYS.THEME, 'auto');
      if (theme === 'dark') {
         context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
      } else if (theme === 'light') {
         context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
      } else {
         context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
      }
   } catch (e) {
      // ignore
   }
}
export default class EntryAbility extends UIAbility {
   onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
      hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
   }

   onDestroy(): void {
      hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
   }

   async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
      // Main window is created, set main page for this ability
      hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

      try {
         // 初始化AuthManager
         const authManager = AuthManager.getInstance();
         await authManager.init(this.context);

         // 根据登录状态决定加载哪个页面
         const isLoggedIn = authManager.getIsLoggedIn();
         const entryPage = isLoggedIn ? 'pages/Index' : 'pages/Auth/AuthPage';
         
         windowStage.loadContent(entryPage, (err) => {
         if (err.code) {
            hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
            return;
         }
         hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
      });
      } catch (error) {
         hilog.error(DOMAIN, 'testTag', 'Auth initialization failed: %{public}s', JSON.stringify(error));
         
         // 初始化失败，加载认证页面
         windowStage.loadContent('pages/Auth/AuthPage', (err) => {
            if (err.code) {
               hilog.error(DOMAIN, 'testTag', 'Failed to load auth page. Cause: %{public}s', JSON.stringify(err));
               return;
            }
            hilog.info(DOMAIN, 'testTag', 'Loaded auth page as fallback.');
         });
      }
   }

   onWindowStageDestroy(): void {
      // Main window is destroyed, release UI related resources
      hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
   }

   onForeground(): void {
      // Ability has brought to foreground
      hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
   }

   onBackground(): void {
      // Ability has back to background
      hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
   }
}
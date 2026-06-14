import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import storageUtil from '../common/utils/StorageUtil';
import distributedDataObject from '@ohos.data.distributedDataObject';
import { BreakpointSystem } from '../common/utils/BreakpointSystem';

const DOMAIN = 0x0000;

// 流转数据对象接口
interface ContinueData {
  selectedDate?: string;
  mealRecords?: string;
  currentPage?: string;
}

export default class EntryAbility extends UIAbility {
  private distributedObject: distributedDataObject.DistributedObject | undefined = undefined;
  private breakpointSystem: BreakpointSystem = BreakpointSystem.getInstance();
  
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
    
    // 初始化存储工具
    storageUtil.init(this.context);
    
    // 恢复流转数据
    this.restoreContinueData(want, launchParam);
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    // 注册断点监听
    this.breakpointSystem.register();
    hilog.info(DOMAIN, 'testTag', 'Breakpoint system registered');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
    
    // 注销断点监听
    this.breakpointSystem.unregister();
    hilog.info(DOMAIN, 'testTag', 'Breakpoint system unregistered');
  }
  
  // 窗口恢复回调（流转时使用）
  onWindowStageRestore(windowStage: window.WindowStage): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageRestore');
    
    // 流转恢复时加载MealCheckInPage页面
    windowStage.loadContent('pages/MealCheckInPage', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
  
  // 自由流转：保存数据
  onContinue(wantParam: Record<string, Object>): AbilityConstant.OnContinueResult {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onContinue');
    
    try {
      // 获取当前日期和打卡记录
      const selectedDate = storageUtil.loadString('selectedDate', '');
      const mealRecords = storageUtil.loadString(`mealRecords_${selectedDate}`, '[]');
      
      // 保存流转数据到wantParam
      wantParam['selectedDate'] = selectedDate;
      wantParam['mealRecords'] = mealRecords;
      wantParam['currentPage'] = 'MealCheckInPage';
      
      hilog.info(DOMAIN, 'testTag', 'onContinue data: date=%{public}s, records=%{public}s', 
        selectedDate, mealRecords.substring(0, 100));
      
      return AbilityConstant.OnContinueResult.AGREE;
    } catch (error) {
      hilog.error(DOMAIN, 'testTag', 'onContinue failed: %{public}s', JSON.stringify(error));
      return AbilityConstant.OnContinueResult.REJECT;
    }
  }
  
  // 恢复流转数据
  private restoreContinueData(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    // 检查是否为流转启动
    if (launchParam.launchReason === AbilityConstant.LaunchReason.CONTINUATION) {
      hilog.info(DOMAIN, 'testTag', '%{public}s', 'Restore continue data');
      
      try {
        // 从want参数中恢复数据
        const selectedDate = want.parameters?.['selectedDate'] as string;
        const mealRecords = want.parameters?.['mealRecords'] as string;
        const currentPage = want.parameters?.['currentPage'] as string;
        
        if (selectedDate) {
          // 保存恢复的数据到本地存储
          storageUtil.save('selectedDate', selectedDate);
          hilog.info(DOMAIN, 'testTag', 'Restored selectedDate: %{public}s', selectedDate);
        }
        
        if (mealRecords && selectedDate) {
          storageUtil.save(`mealRecords_${selectedDate}`, mealRecords);
          hilog.info(DOMAIN, 'testTag', 'Restored mealRecords: %{public}s', mealRecords.substring(0, 100));
        }
        
        // 标记流转恢复标志
        if (currentPage) {
          storageUtil.save('continueRestore', 'true');
          storageUtil.save('continuePage', currentPage);
        }
        
        // 恢复窗口阶段
        this.context.restoreWindowStage(new LocalStorage());
      } catch (error) {
        hilog.error(DOMAIN, 'testTag', 'Restore continue data failed: %{public}s', JSON.stringify(error));
      }
    }
  }
}
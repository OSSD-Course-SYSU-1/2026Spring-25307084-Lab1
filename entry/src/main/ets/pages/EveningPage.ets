// EveningPage.ets - 晚上页面
import router from '@ohos.router'
import { common } from '@kit.AbilityKit'
import storageUtil from '../common/utils/StorageUtil'
import { startReminderCheck } from '../common/utils/ReminderService'
import { 
  getDietRecommendation, 
  getCurrentSeason, 
  Season,
  NutritionType,
  DietRecommendation,
  Food
} from '../common/utils/DietUtil'

@Entry
@Component
struct EveningPage {
  @State alarmOn: boolean = false
  @State alarmHour: number = 18
  @State alarmMinute: number = 0
  @State dietRecommendation: DietRecommendation | null = null
  @State currentSeason: Season = Season.AUTUMN

  aboutToAppear() {
    const context = getContext(this) as common.UIAbilityContext
    storageUtil.init(context)
    
    // 加载闹钟设置
    this.alarmOn = storageUtil.loadBoolean('eveningAlarmOn', false)
    this.alarmHour = storageUtil.loadNumber('eveningAlarmHour', 18)
    this.alarmMinute = storageUtil.loadNumber('eveningAlarmMinute', 0)
    
    // 获取当前季节和饮食推荐
    this.currentSeason = getCurrentSeason()
    this.dietRecommendation = getDietRecommendation('evening')
    
    // 启动提醒检查
    startReminderCheck(false, 0, 0, false, 0, 0, this.alarmOn, this.alarmHour, this.alarmMinute)
  }

  build() {
    Column() {
      // 标题栏
      this.buildHeader()
      
      Scroll() {
        Column({ space: 16 }) {
          // 闹钟设置卡片
          this.buildAlarmCard()
          
          // 季节信息
          this.buildSeasonCard()
          
          // 饮食推荐卡片
          this.buildDietCard()
          
          // 健康提示卡片
          this.buildTipsCard()
        }
        .padding(16)
      }
      .layoutWeight(1)
      
      // 返回按钮
      this.buildBackButton()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }

  // 标题栏
  @Builder
  buildHeader(): void {
    Row() {
      Text('🌙')
        .fontSize(32)
      
      Column() {
        Text('晚上时光')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
        
        Text('轻松晚餐，安享夜晚')
          .fontSize(14)
          .fontColor('#666666')
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })
      .layoutWeight(1)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#9370DB')
    .alignItems(VerticalAlign.Center)
  }

  // 闹钟设置卡片
  @Builder
  buildAlarmCard(): void {
    Column() {
      Row() {
        Text('⏰ 晚餐提醒')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
        
        Toggle({ type: ToggleType.Switch, isOn: this.alarmOn })
          .onChange((isOn: boolean) => {
            this.alarmOn = isOn
            storageUtil.save('eveningAlarmOn', isOn)
          })
      }
      .width('100%')
      .margin({ bottom: 12 })
      
      Row() {
        Text('提醒时间:')
          .fontSize(16)
        
        Text(`${this.alarmHour.toString().padStart(2, '0')}:${this.alarmMinute.toString().padStart(2, '0')}`)
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .fontColor('#9C27B0')
          .margin({ left: 12 })
          .onClick(() => {
            router.pushUrl({
              url: 'pages/TimePickerPage',
              params: {
                hour: this.alarmHour,
                minute: this.alarmMinute,
                type: 'evening'
              }
            })
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .shadow({ radius: 8, color: '#00000022', offsetX: 0, offsetY: 4 })
  }

  // 季节信息卡片
  @Builder
  buildSeasonCard(): void {
    Row() {
      Text('🌿')
        .fontSize(24)
      
      Column() {
        Text(`当前季节：${this.currentSeason}`)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
        
        Text('晚餐推荐已根据季节调整')
          .fontSize(14)
          .fontColor('#666666')
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })
      .layoutWeight(1)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#F3E5F5')
    .borderRadius(16)
    .alignItems(VerticalAlign.Center)
  }

  // 饮食推荐卡片
  @Builder
  buildDietCard(): void {
    Column() {
      Row() {
        Text('🍲 晚餐推荐')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
        
        Text(`总热量: ${this.dietRecommendation?.totalCalories || 0} kcal`)
          .fontSize(14)
          .fontColor('#666666')
      }
      .width('100%')
      .margin({ bottom: 12 })
      
      if (this.dietRecommendation && this.dietRecommendation.foods.length > 0) {
        ForEach(this.dietRecommendation.foods, (food: Food, index: number) => {
          this.buildFoodItem(food, index)
        }, (food: Food) => food.name)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .shadow({ radius: 8, color: '#00000022', offsetX: 0, offsetY: 4 })
  }

  // 食物项
  @Builder
  buildFoodItem(food: Food, index: number): void {
    Row() {
      Column() {
        Text(food.name)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        
        Text(food.description)
          .fontSize(12)
          .fontColor('#666666')
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      
      Column() {
        Text(`${food.calories} kcal`)
          .fontSize(14)
          .fontColor('#9C27B0')
        
        Row({ space: 4 }) {
          ForEach(food.nutrition.slice(0, 2), (nutrition: NutritionType) => {
            Text(this.getNutritionEmoji(nutrition))
              .fontSize(16)
          }, (nutrition: NutritionType) => nutrition)
        }
        .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.End)
    }
    .width('100%')
    .padding(12)
    .backgroundColor(index % 2 === 0 ? '#F5F5F5' : '#FFFFFF')
    .borderRadius(8)
    .margin({ top: 8 })
  }

  // 健康提示卡片
  @Builder
  buildTipsCard(): void {
    Column() {
      Text('💡 晚餐小贴士')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .margin({ bottom: 12 })
      
      if (this.dietRecommendation && this.dietRecommendation.tips.length > 0) {
        ForEach(this.dietRecommendation.tips, (tip: string, index: number) => {
          Row() {
            Text(`${index + 1}.`)
              .fontSize(14)
              .fontColor('#9C27B0')
              .margin({ right: 8 })
            
            Text(tip)
              .fontSize(14)
              .layoutWeight(1)
          }
          .width('100%')
          .margin({ top: 8 })
        }, (tip: string) => tip)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FCE4EC')
    .borderRadius(16)
    .shadow({ radius: 8, color: '#00000022', offsetX: 0, offsetY: 4 })
  }

  // 返回按钮
  @Builder
  buildBackButton(): void {
    Column() {
      Text('返回主页')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
    }
    .width('80%')
    .padding(16)
    .backgroundColor('#9370DB')
    .borderRadius(16)
    .margin({ bottom: 16 })
    .onClick(() => {
      router.pushUrl({ url: 'pages/Index' })
    })
  }

  // 获取营养类型表情符号
  getNutritionEmoji(nutrition: string): string {
    switch (nutrition) {
      case NutritionType.PROTEIN:
        return '🥩'
      case NutritionType.CARBOHYDRATE:
        return '🌾'
      case NutritionType.VITAMIN:
        return '🍊'
      case NutritionType.MINERAL:
        return '💎'
      case NutritionType.FIBER:
        return '🥬'
      default:
        return '🍽️'
    }
  }
}

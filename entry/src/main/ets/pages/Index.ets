// Index.ets
import router from '@ohos.router'  // 导入路由功能
import { FlipNumber } from '../common/utils/FlipNumber'  // 翻页时钟

// 通知功能
import { requestNotificationPermission, publishSimpleNotification } from '../common/utils/NotificationUtil';
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct Index {
  @State hours: string = '00'
  @State minutes: string = '00'

  aboutToAppear() {
    this.updateTime()
    setInterval(() => {
      this.updateTime()
    }, 1000)
  }

  updateTime() {
    const now = new Date()
    this.hours = now.getHours().toString().padStart(2, '0')
    this.minutes = now.getMinutes().toString().padStart(2, '0')
  }

  build() {
    Column() {

      // ===== 时钟展示区域 =====
      Row() {
        FlipNumber({ value: this.hours })
        Text(':')
          .fontSize(48)
          .fontWeight(FontWeight.Bold)
          .padding({ left: 8, right: 8 })
        FlipNumber({ value: this.minutes })
      }
      .width('80%')
      .margin({ top: 60, bottom: 40 })
      .justifyContent(FlexAlign.Center)
      .padding(24)
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .shadow({ radius: 10, color: '#00000022', offsetX: 0, offsetY: 4 })

      // ===== 时段选择按钮 =====
      Column({ space: 16 }) {
        // 早晨按钮
        this.buildTimeButton('早晨', '🌅', '#FFE4B5', 'morning')
        
        // 中午按钮
        this.buildTimeButton('中午', '☀️', '#87CEEB', 'noon')
        
        // 晚上按钮
        this.buildTimeButton('晚上', '🌙', '#9370DB', 'evening')
      }
      .width('85%')
      .margin({ top: 20 })

    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#f2f2f2')
  }

  // 构建时段按钮
  @Builder
  buildTimeButton(title: string, icon: string, color: string, pageType: string): void {
    Column() {
      Row() {
        Text(icon)
          .fontSize(32)
        
        Column() {
          Text(title)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
          
          Text('闹钟 & 健康饮食推荐')
            .fontSize(13)
            .fontColor('#666666')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 16 })
        .layoutWeight(1)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding(20)
    .backgroundColor(color)
    .borderRadius(16)
    .shadow({ radius: 8, color: '#00000022', offsetX: 0, offsetY: 4 })
    .onClick(() => {
      const context = getContext(this) as common.UIAbilityContext
      requestNotificationPermission(context)
      router.pushUrl({ url: `pages/${pageType === 'morning' ? 'MorningPage' : pageType === 'noon' ? 'NoonPage' : 'EveningPage'}` })
    })
  }
}

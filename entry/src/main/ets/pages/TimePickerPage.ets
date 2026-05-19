// TimePickerPage.ets
import router from '@ohos.router'  // 导入路由功能
import { common } from '@kit.AbilityKit'
import storageUtil from '../common/utils/StorageUtil'

interface TimePickerType {
  hour: number
  minute: number
  type: string  // morning, noon, evening
}

@Entry
@Component
struct TimePickerPage {
  @State selectedTime: Date = new Date()
  private type: string = ''  // 用来保存 type
  private initialHour: number = 0
  private initialMinute: number = 0

  aboutToAppear() {
    const context = getContext(this) as common.UIAbilityContext
    storageUtil.init(context)
    
    const params = router.getParams() as TimePickerType
    if (params) {
      this.type = params.type ?? ''
      this.initialHour = params.hour ?? 0
      this.initialMinute = params.minute ?? 0
      
      // 设置初始时间
      const newTime = new Date()
      newTime.setHours(this.initialHour)
      newTime.setMinutes(this.initialMinute)
      this.selectedTime = newTime
    }
  }

  build() {
    // 整体页面布局
    Column(){
      // 标题
      Text(this.getPageTitle())
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 20 })
      
      // 时间选择器
      TimePicker({ selected: this.selectedTime })
        .onChange((value: TimePickerResult) => {
          const newTime = new Date()
          newTime.setHours(value.hour)
          newTime.setMinutes(value.minute)
          this.selectedTime = newTime
          console.log(`选择时间: ${value.hour}:${value.minute}`)
        })
        .width(250)
        .height(160)
        .backgroundColor('#ffedf5f5')
        .borderRadius(12)

      // 当前选中时间展示
      Text(`当前时间: ${this.selectedTime.getHours().toString().padStart(2, '0')} : ${this.selectedTime.getMinutes().toString().padStart(2, '0')}`)
        .fontSize(16)
        .margin({ top: 20 })

      // 确定按钮
      Button('确定')
        .margin({ top: 24 })
        .width(100)
        .height(40)
        .backgroundColor('#ffbadabb')
        .fontColor($r('sys.color.white'))
        .borderRadius(8)
        .onClick(() => {
          const hour = this.selectedTime.getHours()
          const minute = this.selectedTime.getMinutes()
          
          // 保存时间到对应的存储键
          this.saveTime(hour, minute)
          
          // 返回到对应的页面
          const targetPage = this.getTargetPage()
          router.replaceUrl({
            url: targetPage
          })
        })
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)     // 水平居中
    .justifyContent(FlexAlign.Center)       // 垂直居中
    .padding(20)
  }
  
  // 获取页面标题
  private getPageTitle(): string {
    switch (this.type) {
      case 'morning':
        return '🌅 设置早餐提醒时间'
      case 'noon':
        return '☀️ 设置午餐提醒时间'
      case 'evening':
        return '🌙 设置晚餐提醒时间'
      default:
        return '设置提醒时间'
    }
  }
  
  // 获取目标页面
  private getTargetPage(): string {
    switch (this.type) {
      case 'morning':
        return 'pages/MorningPage'
      case 'noon':
        return 'pages/NoonPage'
      case 'evening':
        return 'pages/EveningPage'
      default:
        return 'pages/Index'
    }
  }
  
  // 保存时间
  private saveTime(hour: number, minute: number): void {
    switch (this.type) {
      case 'morning':
        storageUtil.save('morningAlarmHour', hour)
        storageUtil.save('morningAlarmMinute', minute)
        break
      case 'noon':
        storageUtil.save('noonAlarmHour', hour)
        storageUtil.save('noonAlarmMinute', minute)
        break
      case 'evening':
        storageUtil.save('eveningAlarmHour', hour)
        storageUtil.save('eveningAlarmMinute', minute)
        break
    }
  }
}

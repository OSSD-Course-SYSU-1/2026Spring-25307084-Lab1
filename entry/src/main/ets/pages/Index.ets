// Index.ets - 响应式布局版本
import router from '@ohos.router'  // 导入路由功能
import { FlipNumber } from '../common/utils/FlipNumber'  // 翻页时钟
import { BreakpointValue, BreakpointConstants, BreakpointValueType } from '../common/utils/BreakpointType'

// 通知功能
import { requestNotificationPermission, publishSimpleNotification } from '../common/utils/NotificationUtil';
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct Index {
  @State hours: string = '00'
  @State minutes: string = '00'
  @StorageProp('currentBreakpoint') currentBreakpoint: BreakpointValueType = 'sm' // 默认为sm断点

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

  /**
   * 获取响应式字体大小
   */
  getResponsiveFontSize(baseSize: number): number {
    return new BreakpointValue<number>({
      xs: baseSize - 4,
      sm: baseSize,
      md: baseSize + 2,
      lg: baseSize + 4,
      xl: baseSize + 6
    }).getValueOrDefault(this.currentBreakpoint, baseSize);
  }

  /**
   * 获取响应式间距
   */
  getResponsiveMargin(baseMargin: number): number {
    return new BreakpointValue<number>({
      xs: baseMargin - 4,
      sm: baseMargin,
      md: baseMargin + 4,
      lg: baseMargin + 8,
      xl: baseMargin + 12
    }).getValueOrDefault(this.currentBreakpoint, baseMargin);
  }

  /**
   * 获取响应式内边距
   */
  getResponsivePadding(basePadding: number): number {
    return new BreakpointValue<number>({
      xs: basePadding - 4,
      sm: basePadding,
      md: basePadding + 4,
      lg: basePadding + 8,
      xl: basePadding + 12
    }).getValueOrDefault(this.currentBreakpoint, basePadding);
  }

  /**
   * 判断是否为大屏设备
   */
  isLargeScreen(): boolean {
    return this.currentBreakpoint === 'lg' || this.currentBreakpoint === 'xl';
  }

  build() {
    // 使用GridRow实现响应式布局
    GridRow({
      columns: {
        xs: 4,
        sm: 4,
        md: 8,
        lg: 12,
        xl: 12
      },
      gutter: {
        x: this.getResponsiveMargin(12),
        y: this.getResponsiveMargin(16)
      }
    }) {
      // 时钟展示区域 - 在大屏设备上居中显示
      GridCol({
        span: {
          xs: 4,
          sm: 4,
          md: 8,
          lg: 8,
          xl: 6
        },
        offset: {
          lg: 2,
          xl: 3
        }
      }) {
        Column() {
          // 时钟展示
          Row() {
            FlipNumber({ value: this.hours })
            Text(':')
              .fontSize(this.getResponsiveFontSize(48))
              .fontWeight(FontWeight.Bold)
              .padding({ left: 8, right: 8 })
            FlipNumber({ value: this.minutes })
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .padding(this.getResponsivePadding(24))
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .shadow({ radius: 10, color: '#00000022', offsetX: 0, offsetY: 4 })

          // 时段选择按钮
          Column({ space: this.getResponsiveMargin(16) }) {
            // 大屏设备：横向排列按钮
            if (this.isLargeScreen()) {
              Row({ space: this.getResponsiveMargin(16) }) {
                this.buildTimeButton('早晨', '🌅', '#FFE4B5', 'morning')
                this.buildTimeButton('中午', '☀️', '#87CEEB', 'noon')
                this.buildTimeButton('晚上', '🌙', '#9370DB', 'evening')
              }
              .width('100%')
            } else {
              // 小屏设备：纵向排列按钮
              this.buildTimeButton('早晨', '🌅', '#FFE4B5', 'morning')
              this.buildTimeButton('中午', '☀️', '#87CEEB', 'noon')
              this.buildTimeButton('晚上', '🌙', '#9370DB', 'evening')
            }
          }
          .width('100%')
          .margin({ top: this.getResponsiveMargin(20) })

          // 三餐打卡按钮
          this.buildMealCheckInButton()
        }
        .width('100%')
        .margin({ top: this.getResponsiveMargin(60) })
        .padding({
          left: this.getResponsivePadding(16),
          right: this.getResponsivePadding(16)
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f2f2f2')
  }

  // 构建时段按钮
  @Builder
  buildTimeButton(title: string, icon: string, color: string, pageType: string): void {
    Column() {
      Row() {
        Text(icon)
          .fontSize(this.getResponsiveFontSize(32))
        
        Column() {
          Text(title)
            .fontSize(this.getResponsiveFontSize(22))
            .fontWeight(FontWeight.Bold)
          
          Text('闹钟 & 健康饮食推荐')
            .fontSize(this.getResponsiveFontSize(13))
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
    .width(this.isLargeScreen() ? '100%' : '100%')
    .padding(this.getResponsivePadding(20))
    .backgroundColor(color)
    .borderRadius(16)
    .shadow({ radius: 8, color: '#00000022', offsetX: 0, offsetY: 4 })
    .onClick(() => {
      const context = getContext(this) as common.UIAbilityContext
      requestNotificationPermission(context)
      router.pushUrl({ url: `pages/${pageType === 'morning' ? 'MorningPage' : pageType === 'noon' ? 'NoonPage' : 'EveningPage'}` })
    })
  }

  // 构建三餐打卡按钮
  @Builder
  buildMealCheckInButton(): void {
    Column() {
      Row() {
        Text('📋')
          .fontSize(this.getResponsiveFontSize(32))
        
        Column() {
          Text('三餐打卡')
            .fontSize(this.getResponsiveFontSize(22))
            .fontWeight(FontWeight.Bold)
          
          Text('记录每日饮食健康情况')
            .fontSize(this.getResponsiveFontSize(13))
            .fontColor('#666666')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 16 })
        .layoutWeight(1)
        
        // 右箭头
        Text('›')
          .fontSize(this.getResponsiveFontSize(28))
          .fontColor('#999999')
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding(this.getResponsivePadding(20))
    .backgroundColor('#E8F5E9')
    .borderRadius(16)
    .shadow({ radius: 8, color: '#00000022', offsetX: 0, offsetY: 4 })
    .margin({ top: this.getResponsiveMargin(24) })
    .onClick(() => {
      router.pushUrl({ url: 'pages/MealCheckInPage' })
    })
  }
}

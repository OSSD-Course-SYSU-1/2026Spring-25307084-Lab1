// MealCheckInPage.ets - 三餐打卡页面
import router from '@ohos.router'
import { common } from '@kit.AbilityKit'
import storageUtil from '../common/utils/StorageUtil'
import { picker } from '@kit.CoreFileKit'
import { camera } from '@kit.CameraKit'
import { image } from '@kit.ImageKit'
import { hilog } from '@kit.PerformanceAnalysisKit'

// 健康等级
enum HealthLevel {
  NONE = 'none',      // 未打卡
  HEALTHY = 'healthy', // 健康（绿色）
  MODERATE = 'moderate', // 中等（黄色）
  UNHEALTHY = 'unhealthy' // 不健康（红色）
}

// 打卡记录
interface MealRecord {
  meal: string        // breakfast, lunch, dinner
  healthLevel: HealthLevel
  time: string        // 打卡时间
  foodImage?: string  // 食物图片路径（Base64或本地路径）
  foodText?: string   // 食物描述文字
}

// 统计信息
interface Statistics {
  checkedMeals: number
  healthyCount: number
  moderateCount: number
  unhealthyCount: number
}

// 月度统计信息
interface MonthStatistics {
  totalDays: number
  checkedDays: number
  healthyDays: number
  moderateDays: number
  unhealthyDays: number
}

@Entry
@Component
struct MealCheckInPage {
  @State todayRecords: MealRecord[] = []
  @State selectedDate: string = ''
  @State showHealthPicker: boolean = false
  @State currentMeal: string = ''
  @State showMonthView: boolean = false  // 是否显示月视图
  @State currentYear: number = 0  // 当前年份
  @State currentMonth: number = 0  // 当前月份
  @State foodImage: string = ''  // 当前选择的食物图片
  @State foodText: string = ''   // 当前输入的食物描述
  @State tempHealthLevel: HealthLevel = HealthLevel.NONE  // 临时选择的健康等级
  
  private meals: string[] = ['breakfast', 'lunch', 'dinner']
  private mealNames: Record<string, string> = {
    'breakfast': '早餐',
    'lunch': '午餐',
    'dinner': '晚餐'
  }
  private mealIcons: Record<string, string> = {
    'breakfast': '🌅',
    'lunch': '☀️',
    'dinner': '🌙'
  }
  private mealTimes: Record<string, string> = {
    'breakfast': '6:00 - 9:00',
    'lunch': '11:00 - 13:00',
    'dinner': '17:00 - 20:00'
  }
  private weekDays: string[] = ['日', '一', '二', '三', '四', '五', '六']
  
  aboutToAppear() {
    const context = getContext(this) as common.UIAbilityContext
    storageUtil.init(context)
    
    // 检查是否为流转恢复
    const isContinueRestore = storageUtil.loadString('continueRestore', 'false')
    if (isContinueRestore === 'true') {
      // 清除流转标志
      storageUtil.save('continueRestore', 'false')
      hilog.info(0x0000, 'MealCheckInPage', 'Continue restore detected')
    }
    
    // 获取今天的日期
    const now = new Date()
    this.currentYear = now.getFullYear()
    this.currentMonth = now.getMonth() + 1
    this.selectedDate = this.getTodayDate()
    
    // 加载今天的打卡记录
    this.loadTodayRecords()
  }
  
  // 获取今天的日期字符串
  private getTodayDate(): string {
    const now = new Date()
    const year = now.getFullYear()
    const month = (now.getMonth() + 1).toString().padStart(2, '0')
    const day = now.getDate().toString().padStart(2, '0')
    return `${year}-${month}-${day}`
  }
  
  // 获取当前时间字符串
  private getCurrentTime(): string {
    const now = new Date()
    const hours = now.getHours().toString().padStart(2, '0')
    const minutes = now.getMinutes().toString().padStart(2, '0')
    return `${hours}:${minutes}`
  }
  
  // 加载今天的打卡记录
  private loadTodayRecords(): void {
    const savedRecords = storageUtil.loadString(`mealRecords_${this.selectedDate}`, '[]')
    try {
      const records = JSON.parse(savedRecords) as MealRecord[]
      this.todayRecords = records
    } catch (e) {
      this.todayRecords = []
    }
  }
  
  // 保存打卡记录
  private saveRecords(): void {
    const recordsJson = JSON.stringify(this.todayRecords)
    storageUtil.save(`mealRecords_${this.selectedDate}`, recordsJson)
  }
  
  // 获取餐次记录
  private getMealRecord(meal: string): MealRecord | undefined {
    return this.todayRecords.find((record: MealRecord) => record.meal === meal)
  }
  
  // 打卡
  private checkIn(meal: string, healthLevel: HealthLevel): void {
    const existingIndex = this.todayRecords.findIndex((record: MealRecord) => record.meal === meal)
    const newRecord: MealRecord = {
      meal: meal,
      healthLevel: healthLevel,
      time: this.getCurrentTime(),
      foodImage: this.foodImage,
      foodText: this.foodText
    }
    
    if (existingIndex >= 0) {
      this.todayRecords[existingIndex] = newRecord
    } else {
      this.todayRecords.push(newRecord)
    }
    
    this.saveRecords()
    this.showHealthPicker = false
    // 清空临时数据
    this.foodImage = ''
    this.foodText = ''
    this.tempHealthLevel = HealthLevel.NONE
  }
  
  // 选择图片（从相册）
  private async selectImage(): Promise<void> {
    try {
      const photoSelectOptions = new picker.PhotoSelectOptions()
      photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE
      photoSelectOptions.maxSelectNumber = 1
      
      const photoPicker = new picker.PhotoViewPicker()
      const photoSelectResult = await photoPicker.select(photoSelectOptions)
      
      if (photoSelectResult.photoUris.length > 0) {
        this.foodImage = photoSelectResult.photoUris[0]
      }
    } catch (err) {
      console.error('选择图片失败')
    }
  }
  
  // 拍照（使用相机）
  private async takePhoto(): Promise<void> {
    try {
      // 使用 PhotoViewPicker 的相机功能
      const photoSelectOptions = new picker.PhotoSelectOptions()
      photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE
      photoSelectOptions.maxSelectNumber = 1
      
      const photoPicker = new picker.PhotoViewPicker()
      // 使用相机拍摄
      const photoSelectResult = await photoPicker.select(photoSelectOptions)
      
      if (photoSelectResult.photoUris.length > 0) {
        this.foodImage = photoSelectResult.photoUris[0]
      }
    } catch (err) {
      console.error('拍照失败')
    }
  }
  
  // 获取健康等级颜色
  private getHealthColor(level: HealthLevel): string {
    switch (level) {
      case HealthLevel.HEALTHY:
        return '#4CAF50'  // 绿色
      case HealthLevel.MODERATE:
        return '#FFC107'  // 黄色
      case HealthLevel.UNHEALTHY:
        return '#F44336'  // 红色
      default:
        return '#CCCCCC'  // 灰色（未打卡）
    }
  }
  
  // 获取健康等级文字
  private getHealthText(level: HealthLevel): string {
    switch (level) {
      case HealthLevel.HEALTHY:
        return '健康'
      case HealthLevel.MODERATE:
        return '中等'
      case HealthLevel.UNHEALTHY:
        return '不健康'
      default:
        return '未打卡'
    }
  }
  
  // 获取健康等级图标
  private getHealthIcon(level: HealthLevel): string {
    switch (level) {
      case HealthLevel.HEALTHY:
        return '✓'
      case HealthLevel.MODERATE:
        return '!'
      case HealthLevel.UNHEALTHY:
        return '✗'
      default:
        return '?'
    }
  }
  
  // 获取餐次的健康等级
  private getMealHealthLevel(meal: string): HealthLevel {
    const record = this.getMealRecord(meal)
    return record ? record.healthLevel : HealthLevel.NONE
  }
  
  // 获取餐次的打卡时间
  private getMealCheckInTime(meal: string): string {
    const record = this.getMealRecord(meal)
    return record ? record.time : ''
  }
  
  // 获取统计信息
  private getStatistics(): Statistics {
    const checkedMeals = this.todayRecords.length
    const healthyCount = this.todayRecords.filter((r: MealRecord) => r.healthLevel === HealthLevel.HEALTHY).length
    const moderateCount = this.todayRecords.filter((r: MealRecord) => r.healthLevel === HealthLevel.MODERATE).length
    const unhealthyCount = this.todayRecords.filter((r: MealRecord) => r.healthLevel === HealthLevel.UNHEALTHY).length
    const result: Statistics = { checkedMeals, healthyCount, moderateCount, unhealthyCount }
    return result
  }
  
  build() {
    Stack() {
      Column() {
        // ===== 顶部导航栏 =====
        Row() {
          Text('‹')
            .fontSize(32)
            .onClick(() => {
              router.back()
            })
          
          Text('📋 三餐打卡')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
          
          // 视图切换按钮
          Row({ space: 8 }) {
            // 月视图切换按钮
            Text(this.showMonthView ? '📅' : '📆')
              .fontSize(28)
              .onClick(() => {
                this.showMonthView = !this.showMonthView
              })
          }
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 10, bottom: 10 })
        
        // 根据视图状态显示不同内容
        if (this.showMonthView) {
          // ===== 月视图 =====
          this.buildMonthView()
        } else {
          // ===== 日视图 =====
          // ===== 日期显示 =====
          Column() {
            Text(this.selectedDate)
              .fontSize(18)
              .fontColor('#666666')
            
            Text('今日三餐打卡记录')
              .fontSize(14)
              .fontColor('#999999')
              .margin({ top: 4 })
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ top: 16, left: 16, right: 16 })
          
          // ===== 三餐打卡卡片 =====
          Column({ space: 16 }) {
            ForEach(this.meals, (meal: string) => {
              this.buildMealCard(meal)
            }, (meal: string) => meal)
          }
          .width('100%')
          .padding(16)
          
          // ===== 统计信息 =====
          this.buildStatistics()
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#f2f2f2')
      
      // ===== 健康等级选择弹窗 =====
      if (this.showHealthPicker) {
        this.buildHealthPicker()
      }
    }
    .width('100%')
    .height('100%')
  }
  
  // 获取餐次的食物图片
  private getMealFoodImage(meal: string): string {
    const record = this.getMealRecord(meal)
    return record && record.foodImage ? record.foodImage : ''
  }
  
  // 获取餐次的食物描述
  private getMealFoodText(meal: string): string {
    const record = this.getMealRecord(meal)
    return record && record.foodText ? record.foodText : ''
  }
  
  // 构建餐次卡片
  @Builder
  buildMealCard(meal: string): void {
    Column() {
      Row() {
        // 餐次图标和名称
        Text(this.mealIcons[meal])
          .fontSize(36)
        
        Column() {
          Text(this.mealNames[meal])
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
          
          Text(this.mealTimes[meal])
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 12 })
        .layoutWeight(1)
        
        // 打卡状态
        Column() {
          if (this.getMealHealthLevel(meal) !== HealthLevel.NONE) {
            // 已打卡
            Row() {
              Text(this.getHealthIcon(this.getMealHealthLevel(meal)))
                .fontSize(20)
                .fontColor('#FFFFFF')
            }
            .width(40)
            .height(40)
            .backgroundColor(this.getHealthColor(this.getMealHealthLevel(meal)))
            .borderRadius(20)
            .justifyContent(FlexAlign.Center)
            
            Text(this.getHealthText(this.getMealHealthLevel(meal)))
              .fontSize(12)
              .fontColor(this.getHealthColor(this.getMealHealthLevel(meal)))
              .margin({ top: 4 })
            
            Text(this.getMealCheckInTime(meal))
              .fontSize(10)
              .fontColor('#999999')
              .margin({ top: 2 })
          } else {
            // 未打卡
            Row() {
              Text('+')
                .fontSize(24)
                .fontColor('#4CAF50')
            }
            .width(40)
            .height(40)
            .backgroundColor('#E8F5E9')
            .borderRadius(20)
            .justifyContent(FlexAlign.Center)
            
            Text('点击打卡')
              .fontSize(12)
              .fontColor('#4CAF50')
              .margin({ top: 4 })
          }
        }
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      
      // ===== 显示食物图片和描述 =====
      if (this.getMealHealthLevel(meal) !== HealthLevel.NONE) {
        if (this.getMealFoodImage(meal) || this.getMealFoodText(meal)) {
          Column() {
            // 显示食物图片
            if (this.getMealFoodImage(meal)) {
              Image(this.getMealFoodImage(meal))
                .width('100%')
                .height(120)
                .objectFit(ImageFit.Cover)
                .borderRadius(8)
                .margin({ top: 12 })
            }
            
            // 显示食物描述
            if (this.getMealFoodText(meal)) {
              Text(this.getMealFoodText(meal))
                .fontSize(14)
                .fontColor('#666666')
                .margin({ top: 8 })
                .width('100%')
                .maxLines(3)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }
      }
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .shadow({ radius: 6, color: '#00000011', offsetX: 0, offsetY: 2 })
    .onClick(() => {
      this.currentMeal = meal
      this.showHealthPicker = true
    })
  }
  
  // 构建统计信息
  @Builder
  buildStatistics(): void {
    Column() {
      Text('📊 今日统计')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 12 })
      
      Row({ space: 16 }) {
        // 打卡进度
        Column() {
          Text(`${this.getStatistics().checkedMeals}/${this.meals.length}`)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#2196F3')
          
          Text('已打卡')
            .fontSize(12)
            .fontColor('#666666')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .padding(12)
        .backgroundColor('#E3F2FD')
        .borderRadius(8)
        
        // 健康餐数
        Column() {
          Text(`${this.getStatistics().healthyCount}`)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#4CAF50')
          
          Text('健康餐')
            .fontSize(12)
            .fontColor('#666666')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .padding(12)
        .backgroundColor('#E8F5E9')
        .borderRadius(8)
        
        // 不健康餐数
        Column() {
          Text(`${this.getStatistics().unhealthyCount}`)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#F44336')
          
          Text('不健康餐')
            .fontSize(12)
            .fontColor('#666666')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .padding(12)
        .backgroundColor('#FFEBEE')
        .borderRadius(8)
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .margin({ left: 16, right: 16, bottom: 16 })
    .shadow({ radius: 6, color: '#00000011', offsetX: 0, offsetY: 2 })
  }
  
  // 构建健康等级选择弹窗
  @Builder
  buildHealthPicker(): void {
    Column() {
      Column() {
        Text(`${this.mealIcons[this.currentMeal]} ${this.mealNames[this.currentMeal]}打卡`)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 16 })
        
        // ===== 食物图片选择区域 =====
        Column() {
          if (this.foodImage) {
            // 显示已选择的图片
            Stack() {
              Image(this.foodImage)
                .width('100%')
                .height(150)
                .objectFit(ImageFit.Cover)
                .borderRadius(8)
              
              // 删除图片按钮
              Row() {
                Text('×')
                  .fontSize(20)
                  .fontColor('#FFFFFF')
              }
              .width(30)
              .height(30)
              .backgroundColor('#00000088')
              .borderRadius(15)
              .justifyContent(FlexAlign.Center)
              .position({ x: '100%', y: 0 })
              .translate({ x: -35, y: 5 })
              .onClick(() => {
                this.foodImage = ''
              })
            }
            .width('100%')
            .height(150)
          } else {
            // 图片选择按钮
            Row({ space: 20 }) {
              Column() {
                Text('📷')
                  .fontSize(32)
                Text('拍照')
                  .fontSize(12)
                  .fontColor('#666666')
                  .margin({ top: 4 })
              }
              .layoutWeight(1)
              .padding(20)
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
              .onClick(() => {
                this.takePhoto()
              })
              
              Column() {
                Text('🖼️')
                  .fontSize(32)
                Text('相册')
                  .fontSize(12)
                  .fontColor('#666666')
                  .margin({ top: 4 })
              }
              .layoutWeight(1)
              .padding(20)
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
              .onClick(() => {
                this.selectImage()
              })
            }
            .width('100%')
          }
        }
        .width('100%')
        .margin({ bottom: 16 })
        
        // ===== 食物描述输入区域 =====
        Column() {
          Text('食物描述')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ bottom: 8 })
          
          TextArea({ placeholder: '记录今天吃了什么...', text: this.foodText })
            .width('100%')
            .height(80)
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .onChange((value: string) => {
              this.foodText = value
            })
        }
        .width('100%')
        .margin({ bottom: 16 })
        
        // ===== 健康等级选择 =====
        Text('健康评估')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 12 })
        
        Row({ space: 12 }) {
          // 健康（绿色）
          Column() {
            Row() {
              Text('✓')
                .fontSize(28)
                .fontColor('#FFFFFF')
            }
            .width(50)
            .height(50)
            .backgroundColor(this.tempHealthLevel === HealthLevel.HEALTHY ? '#4CAF50' : '#A5D6A7')
            .borderRadius(25)
            .justifyContent(FlexAlign.Center)
            
            Text('健康')
              .fontSize(12)
              .fontColor('#4CAF50')
              .margin({ top: 6 })
          }
          .layoutWeight(1)
          .padding(10)
          .backgroundColor(this.tempHealthLevel === HealthLevel.HEALTHY ? '#E8F5E9' : '#FFFFFF')
          .borderRadius(12)
          .border({ width: this.tempHealthLevel === HealthLevel.HEALTHY ? 2 : 1, color: '#4CAF50' })
          .onClick(() => {
            this.tempHealthLevel = HealthLevel.HEALTHY
          })
          
          // 中等（黄色）
          Column() {
            Row() {
              Text('!')
                .fontSize(28)
                .fontColor('#FFFFFF')
            }
            .width(50)
            .height(50)
            .backgroundColor(this.tempHealthLevel === HealthLevel.MODERATE ? '#FFC107' : '#FFE082')
            .borderRadius(25)
            .justifyContent(FlexAlign.Center)
            
            Text('中等')
              .fontSize(12)
              .fontColor('#FFC107')
              .margin({ top: 6 })
          }
          .layoutWeight(1)
          .padding(10)
          .backgroundColor(this.tempHealthLevel === HealthLevel.MODERATE ? '#FFF8E1' : '#FFFFFF')
          .borderRadius(12)
          .border({ width: this.tempHealthLevel === HealthLevel.MODERATE ? 2 : 1, color: '#FFC107' })
          .onClick(() => {
            this.tempHealthLevel = HealthLevel.MODERATE
          })
          
          // 不健康（红色）
          Column() {
            Row() {
              Text('✗')
                .fontSize(28)
                .fontColor('#FFFFFF')
            }
            .width(50)
            .height(50)
            .backgroundColor(this.tempHealthLevel === HealthLevel.UNHEALTHY ? '#F44336' : '#EF9A9A')
            .borderRadius(25)
            .justifyContent(FlexAlign.Center)
            
            Text('不健康')
              .fontSize(12)
              .fontColor('#F44336')
              .margin({ top: 6 })
          }
          .layoutWeight(1)
          .padding(10)
          .backgroundColor(this.tempHealthLevel === HealthLevel.UNHEALTHY ? '#FFEBEE' : '#FFFFFF')
          .borderRadius(12)
          .border({ width: this.tempHealthLevel === HealthLevel.UNHEALTHY ? 2 : 1, color: '#F44336' })
          .onClick(() => {
            this.tempHealthLevel = HealthLevel.UNHEALTHY
          })
        }
        .width('100%')
        
        // ===== 操作按钮 =====
        Row({ space: 12 }) {
          Button('取消')
            .layoutWeight(1)
            .backgroundColor('#F5F5F5')
            .fontColor('#666666')
            .onClick(() => {
              this.showHealthPicker = false
              this.foodImage = ''
              this.foodText = ''
              this.tempHealthLevel = HealthLevel.NONE
            })
          
          Button('完成打卡')
            .layoutWeight(1)
            .backgroundColor(this.tempHealthLevel === HealthLevel.NONE ? '#CCCCCC' : '#4CAF50')
            .fontColor('#FFFFFF')
            .enabled(this.tempHealthLevel !== HealthLevel.NONE)
            .onClick(() => {
              if (this.tempHealthLevel !== HealthLevel.NONE) {
                this.checkIn(this.currentMeal, this.tempHealthLevel)
              }
            })
        }
        .width('100%')
        .margin({ top: 20 })
      }
      .width('90%')
      .padding(20)
      .backgroundColor('#FFFFFF')
      .borderRadius(20)
      .shadow({ radius: 20, color: '#00000033', offsetX: 0, offsetY: 10 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#00000066')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      // 点击背景关闭弹窗
      this.showHealthPicker = false
      this.foodImage = ''
      this.foodText = ''
      this.tempHealthLevel = HealthLevel.NONE
    })
  }
  
  // ===== 月视图相关方法 =====
  
  // 获取月份天数
  private getDaysInMonth(year: number, month: number): number {
    return new Date(year, month, 0).getDate()
  }
  
  // 获取月份第一天是星期几
  private getFirstDayOfMonth(year: number, month: number): number {
    return new Date(year, month - 1, 1).getDay()
  }
  
  // 获取指定日期的打卡记录
  private getDayRecords(dateStr: string): MealRecord[] {
    const savedRecords = storageUtil.loadString(`mealRecords_${dateStr}`, '[]')
    try {
      const records = JSON.parse(savedRecords) as MealRecord[]
      return records
    } catch (e) {
      return []
    }
  }
  
  // 获取日期的健康状态（综合三餐）
  // 判断规则：
  // 1. 一餐不健康则整体不健康（红色）
  // 2. 三餐都没有不健康，且有一餐健康则为健康（绿色）
  // 3. 其它情况为中等（黄色）
  private getDayHealthStatus(dateStr: string): string {
    const records = this.getDayRecords(dateStr)
    if (records.length === 0) {
      return 'none'  // 未打卡
    }
    
    const healthyCount = records.filter((r: MealRecord) => r.healthLevel === HealthLevel.HEALTHY).length
    const unhealthyCount = records.filter((r: MealRecord) => r.healthLevel === HealthLevel.UNHEALTHY).length
    
    // 规则1：一餐不健康则整体不健康
    if (unhealthyCount > 0) {
      return 'unhealthy'
    }
    // 规则2：三餐都没有不健康，且有一餐健康则为健康
    if (healthyCount > 0) {
      return 'healthy'
    }
    // 规则3：其它情况为中等（全部中等）
    return 'moderate'
  }
  
  // 获取月份统计
  private getMonthStatistics(): MonthStatistics {
    const daysInMonth = this.getDaysInMonth(this.currentYear, this.currentMonth)
    let checkedDays = 0
    let healthyDays = 0
    let moderateDays = 0
    let unhealthyDays = 0
    
    for (let day = 1; day <= daysInMonth; day++) {
      const dateStr = `${this.currentYear}-${this.currentMonth.toString().padStart(2, '0')}-${day.toString().padStart(2, '0')}`
      const status = this.getDayHealthStatus(dateStr)
      
      if (status !== 'none') {
        checkedDays++
        if (status === 'healthy') healthyDays++
        else if (status === 'moderate') moderateDays++
        else if (status === 'unhealthy') unhealthyDays++
      }
    }
    
    const result: MonthStatistics = { totalDays: daysInMonth, checkedDays, healthyDays, moderateDays, unhealthyDays }
    return result
  }
  
  // 切换到上个月
  private prevMonth(): void {
    if (this.currentMonth === 1) {
      this.currentYear--
      this.currentMonth = 12
    } else {
      this.currentMonth--
    }
  }
  
  // 切换到下个月
  private nextMonth(): void {
    if (this.currentMonth === 12) {
      this.currentYear++
      this.currentMonth = 1
    } else {
      this.currentMonth++
    }
  }
  
  // 构建月视图
  @Builder
  buildMonthView(): void {
    Column() {
      // ===== 月份选择器 =====
      Row() {
        Text('‹')
          .fontSize(28)
          .fontColor('#2196F3')
          .onClick(() => {
            this.prevMonth()
          })
        
        Text(`${this.currentYear}年${this.currentMonth}月`)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        Text('›')
          .fontSize(28)
          .fontColor('#2196F3')
          .onClick(() => {
            this.nextMonth()
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .margin({ top: 16, left: 16, right: 16 })
      
      // ===== 星期标题 =====
      Row() {
        ForEach(this.weekDays, (day: string) => {
          Text(day)
            .fontSize(14)
            .fontColor('#999999')
            .width('14.28%')
            .textAlign(TextAlign.Center)
        }, (day: string) => day)
      }
      .width('100%')
      .padding({ top: 8, bottom: 8 })
      .margin({ left: 16, right: 16 })
      
      // ===== 日历网格 =====
      this.buildCalendarGrid()
      
      // ===== 月度统计 =====
      this.buildMonthStatistics()
    }
    .width('100%')
    .height('100%')
  }
  
  // 构建日历网格
  @Builder
  buildCalendarGrid(): void {
    Column() {
      // 生成日历行
      ForEach(this.getCalendarWeeks(), (weekIndex: number) => {
        Row() {
          ForEach(this.getWeekDaysArray(), (dayIndex: number) => {
            if (this.getDayNumber(weekIndex, dayIndex) < 1 || this.getDayNumber(weekIndex, dayIndex) > this.getDaysInMonth(this.currentYear, this.currentMonth)) {
              // 空白格子
              Text('')
                .width('14.28%')
                .height(40)
            } else {
              // 日期格子
              Column() {
                Text(this.getDayNumber(weekIndex, dayIndex).toString())
                  .fontSize(14)
                  .fontWeight(this.isToday(this.getDayNumber(weekIndex, dayIndex)) ? FontWeight.Bold : FontWeight.Normal)
                  .fontColor(this.isToday(this.getDayNumber(weekIndex, dayIndex)) ? '#2196F3' : '#333333')
                
                // 健康状态指示点
                if (this.getDayHealthStatus(this.getDateString(this.getDayNumber(weekIndex, dayIndex))) !== 'none') {
                  Row()
                    .width(6)
                    .height(6)
                    .backgroundColor(this.getDayHealthStatus(this.getDateString(this.getDayNumber(weekIndex, dayIndex))) === 'healthy' ? '#4CAF50' : this.getDayHealthStatus(this.getDateString(this.getDayNumber(weekIndex, dayIndex))) === 'moderate' ? '#FFC107' : '#F44336')
                    .borderRadius(3)
                    .margin({ top: 2 })
                }
              }
              .width('14.28%')
              .height(40)
              .justifyContent(FlexAlign.Center)
              .backgroundColor(this.isToday(this.getDayNumber(weekIndex, dayIndex)) ? '#E3F2FD' : '#FFFFFF')
              .borderRadius(8)
            }
          }, (dayIndex: number): string => dayIndex.toString())
        }
        .width('100%')
        .margin({ left: 16, right: 16 })
      }, (weekIndex: number): string => weekIndex.toString())
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ left: 16, right: 16, top: 8 })
    .padding(8)
  }
  
  // 获取日历格子对应的日期数字
  private getDayNumber(weekIndex: number, dayIndex: number): number {
    const firstDay = this.getFirstDayOfMonth(this.currentYear, this.currentMonth)
    return weekIndex * 7 + dayIndex - firstDay + 1
  }
  
  // 获取日期字符串
  private getDateString(day: number): string {
    return `${this.currentYear}-${this.currentMonth.toString().padStart(2, '0')}-${day.toString().padStart(2, '0')}`
  }
  
  // 判断是否是今天
  private isToday(day: number): boolean {
    return this.getDateString(day) === this.getTodayDate()
  }
  
  // 获取日历周数数组
  private getCalendarWeeks(): number[] {
    const weeks = Math.ceil((this.getFirstDayOfMonth(this.currentYear, this.currentMonth) + this.getDaysInMonth(this.currentYear, this.currentMonth)) / 7)
    return Array.from({ length: weeks }, (_: Object, i: number): number => i)
  }
  
  // 获取星期数组
  private getWeekDaysArray(): number[] {
    return Array.from({ length: 7 }, (_: Object, i: number): number => i)
  }
  
  // 构建月度统计
  @Builder
  buildMonthStatistics(): void {
    Column() {
      Text('📊 本月统计')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 12 })
      
      Row({ space: 12 }) {
        // 打卡天数
        Column() {
          Text(`${this.getMonthStatistics().checkedDays}/${this.getMonthStatistics().totalDays}`)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#2196F3')
          
          Text('打卡天数')
            .fontSize(12)
            .fontColor('#666666')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .padding(10)
        .backgroundColor('#E3F2FD')
        .borderRadius(8)
        
        // 健康天数
        Column() {
          Text(`${this.getMonthStatistics().healthyDays}`)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#4CAF50')
          
          Text('健康天数')
            .fontSize(12)
            .fontColor('#666666')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .padding(10)
        .backgroundColor('#E8F5E9')
        .borderRadius(8)
        
        // 中等天数
        Column() {
          Text(`${this.getMonthStatistics().moderateDays}`)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFC107')
          
          Text('中等天数')
            .fontSize(12)
            .fontColor('#666666')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .padding(10)
        .backgroundColor('#FFF8E1')
        .borderRadius(8)
        
        // 不健康天数
        Column() {
          Text(`${this.getMonthStatistics().unhealthyDays}`)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#F44336')
          
          Text('不健康天数')
            .fontSize(12)
            .fontColor('#666666')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .padding(10)
        .backgroundColor('#FFEBEE')
        .borderRadius(8)
      }
      .width('100%')
      
      // 健康率
      if (this.getMonthStatistics().checkedDays > 0) {
        Row() {
          Text('健康率：')
            .fontSize(14)
            .fontColor('#666666')
          
          Text(`${Math.round(this.getMonthStatistics().healthyDays / this.getMonthStatistics().checkedDays * 100)}%`)
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor('#4CAF50')
        }
        .margin({ top: 12 })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .margin({ left: 16, right: 16, top: 16, bottom: 16 })
    .shadow({ radius: 6, color: '#00000011', offsetX: 0, offsetY: 2 })
  }
}

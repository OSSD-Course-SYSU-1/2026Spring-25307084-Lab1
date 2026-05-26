# HarmonyOS 饭点提醒应用

## 📋 项目概述

**项目名称**: HarmonyOS Clock Demo (饭点提醒应用)  
**包名**: com.example.harmonyos_clock_demo  
**版本**: 1.0.0 (versionCode: 1000000)  
**开发语言**: ArkTS (HarmonyOS声明式UI开发语言)  
**目标平台**: HarmonyOS  
**支持设备**: Phone, Tablet, 2in1设备

## 🎯 项目功能

本项目是一个基于HarmonyOS的饭点提醒应用，主要功能包括：

1. **实时时钟展示** - 翻页风格的时钟显示
2. **提醒设置** - 支持早餐、午餐、晚餐三种提醒
3. **时间修改** - 可自定义每种提醒的时间
4. **系统通知** - 到达设定时间时发送系统通知提醒
5. **数据持久化** - 保存用户的提醒设置

## 🆕 新增功能亮点

### 1. 🍽️ 智能饮食推荐系统

**新增文件**: `DietUtil.ets`

**核心功能**:
- **季节感知**: 自动识别当前季节，提供应季食物推荐
- **营养分析**: 包含蛋白质、碳水化合物、维生素、矿物质、膳食纤维五大营养类型
- **食物数据库**: 内置30+种常见食物，包含热量、营养、描述等详细信息
- **智能推荐**: 根据时段（早/中/晚）和季节推荐合适的食物组合
- **健康提示**: 为每个时段提供季节化的健康饮食建议

**数据结构**:
```typescript
// 营养类型枚举
enum NutritionType {
  PROTEIN = '蛋白质',
  CARBOHYDRATE = '碳水化合物',
  VITAMIN = '维生素',
  MINERAL = '矿物质',
  FIBER = '膳食纤维'
}

// 季节枚举
enum Season {
  SPRING = '春季',
  SUMMER = '夏季',
  AUTUMN = '秋季',
  WINTER = '冬季'
}
```

**推荐逻辑**:
- **早餐**: 注重蛋白质和碳水化合物，提供充足能量
- **午餐**: 均衡营养，荤素搭配
- **晚餐**: 清淡为主，低热量高纤维

### 2. 🌅 时段专属页面

**新增文件**: `MorningPage.ets`, `NoonPage.ets`, `EveningPage.ets`

**功能特点**:
- **个性化界面**: 每个时段拥有独特的主题色彩和图标
  - 早晨: 🌅 暖橙色调，充满活力
  - 中午: ☀️ 明亮黄色调，精力充沛
  - 晚上: 🌙 柔和紫色调，温馨舒适

- **集成功能**:
  - 时段闹钟设置与开关
  - 当前季节信息展示
  - 智能饮食推荐列表（含热量和营养标签）
  - 时段专属健康小贴士

**UI设计**:
- 卡片式布局，圆角阴影效果
- 食物项展示：名称、描述、热量、营养标签
- 健康提示：编号列表，易于阅读

### 3. ✅ 三餐打卡系统

**新增文件**: `MealCheckInPage.ets`

**核心功能**:

#### 健康等级评估
- **健康（绿色）**: 营养均衡，符合推荐
- **中等（黄色）**: 尚可改进，部分达标
- **不健康（红色）**: 需要改善，偏离推荐

#### 日视图功能
- 显示当日三餐打卡状态
- 每餐独立打卡，记录时间和健康等级
- 实时统计：已打卡数、健康餐数、不健康餐数
- 打卡时间范围提示：
  - 早餐: 6:00 - 9:00
  - 午餐: 11:00 - 13:00
  - 晚餐: 17:00 - 20:00

#### 月视图功能
- 日历网格展示整月打卡情况
- 健康状态指示点（绿/黄/红）
- 月份切换（上一月/下一月）
- 月度统计：
  - 总天数
  - 打卡天数
  - 健康天数
  - 中等天数
  - 不健康天数

#### 数据持久化
- 按日期存储打卡记录
- 支持历史数据查看
- 自动保存打卡状态

**交互设计**:
- 点击餐卡弹出健康等级选择器
- 顶部按钮切换日/月视图
- 流畅的动画过渡效果

## 📁 项目结构

```
HarmonyOs-Clock-Demo-main/
├── AppScope/                          # 应用全局配置
│   └── app.json5                      # 应用配置文件
├── entry/                             # 主入口模块
│   ├── src/
│   │   ├── main/
│   │   │   ├── ets/                   # ArkTS源代码
│   │   │   │   ├── common/
│   │   │   │   │   └── utils/         # 工具类目录
│   │   │   │   │       ├── DietUtil.ets              # 🆕 饮食推荐工具类
│   │   │   │   │       ├── FlipNumber.ets            # 翻页时钟组件
│   │   │   │   │       ├── NotificationUtil.ets      # 通知工具类
│   │   │   │   │       ├── ReminderService.ets       # 提醒服务
│   │   │   │   │       └── StorageUtil.ets           # 数据存储工具
│   │   │   │   ├── entryability/
│   │   │   │   │   └── EntryAbility.ets              # 应用入口能力
│   │   │   │   ├── entrybackupability/
│   │   │   │   │   └── EntryBackupAbility.ets        # 备份能力
│   │   │   │   └── pages/             # 页面目录
│   │   │   │       ├── Index.ets                      # 首页(时钟展示)
│   │   │   │       ├── MorningPage.ets                # 🆕 早晨页面
│   │   │   │       ├── NoonPage.ets                   # 🆕 中午页面
│   │   │   │       ├── EveningPage.ets                # 🆕 晚上页面
│   │   │   │       ├── MealCheckInPage.ets            # 🆕 三餐打卡页面
│   │   │   │       ├── ReminderSettings.ets           # 提醒设置页
│   │   │   │       └── TimePickerPage.ets             # 时间选择页
│   │   │   ├── resources/             # 资源文件
│   │   │   │   └── base/
│   │   │   │       └── profile/
│   │   │   │           └── main_pages.json           # 页面路由配置
│   │   │   └── module.json5           # 模块配置文件
│   │   ├── mock/                      # 模拟数据
│   │   └── ohosTest/                  # 测试代码
│   ├── build-profile.json5            # 构建配置
│   ├── hvigorfile.ts                  # Hvigor构建脚本
│   └── oh-package.json5               # 依赖配置
├── hvigor/                            # Hvigor构建系统
│   └── hvigor-config.json5            # Hvigor配置
├── pngs/                              # 截图资源
└── README.md                          # 项目说明文档
```

## 🔧 核心文件详解

### 新增工具类

#### DietUtil.ets - 饮食推荐工具类

**主要功能**:
- `getCurrentSeason()`: 获取当前季节
- `getDietRecommendation(timeOfDay)`: 根据时段获取饮食推荐
- `getNutritionAdvice()`: 获取营养建议

**食物数据库示例**:
```typescript
{
  name: '鸡蛋',
  nutrition: [NutritionType.PROTEIN],
  calories: 78,
  description: '优质蛋白，易于消化',
  season: [Season.SPRING, Season.SUMMER, Season.AUTUMN, Season.WINTER]
}
```

**季节化提示**:
- 春季: 易困倦，多吃富含维生素B的食物
- 夏季: 出汗多，补充水分和矿物质
- 秋季: 干燥，多吃润肺食物
- 冬季: 寒冷，适当增加热量摄入

### 新增页面

#### MorningPage.ets / NoonPage.ets / EveningPage.ets

**页面结构**:
1. **标题栏**: 时段图标 + 标题 + 副标题
2. **闹钟设置卡片**: 开关 + 时间设置
3. **季节信息卡片**: 当前季节 + 提示
4. **饮食推荐卡片**: 推荐食物列表 + 总热量
5. **健康提示卡片**: 编号列表的健康建议
6. **返回按钮**: 返回主页

**数据流**:
```
页面加载
  ↓
初始化存储工具
  ↓
加载闹钟设置
  ↓
获取当前季节
  ↓
获取饮食推荐
  ↓
启动提醒检查
```

#### MealCheckInPage.ets - 三餐打卡页面

**状态管理**:
```typescript
@State todayRecords: MealRecord[]        // 今日打卡记录
@State selectedDate: string              // 选中日期
@State showHealthPicker: boolean         // 健康等级选择器显示状态
@State currentMeal: string               // 当前选择的餐次
@State showMonthView: boolean            // 月视图显示状态
@State currentYear: number               // 当前年份
@State currentMonth: number              // 当前月份
```

**核心方法**:
- `checkIn(meal, healthLevel)`: 打卡并保存记录
- `getStatistics()`: 获取今日统计信息
- `getMonthStatistics()`: 获取月度统计信息
- `getDayHealthStatus(dateStr)`: 获取指定日期的健康状态

**UI组件**:
- `buildMealCard(meal)`: 构建餐次卡片
- `buildStatistics()`: 构建统计信息
- `buildHealthPicker()`: 构建健康等级选择弹窗
- `buildMonthView()`: 构建月视图
- `buildCalendarGrid()`: 构建日历网格

## 🔄 数据流与状态管理

### 新增数据流

#### 饮食推荐数据流
```
时段页面加载
  ↓
调用 getCurrentSeason()
  ↓
调用 getDietRecommendation(timeOfDay)
  ↓
过滤季节性食物
  ↓
根据时段推荐策略选择食物
  ↓
计算总热量
  ↓
生成健康提示
  ↓
渲染UI
```

#### 打卡数据流
```
用户点击餐卡
  ↓
弹出健康等级选择器
  ↓
选择健康等级
  ↓
记录打卡时间和等级
  ↓
保存到 StorageUtil
  ↓
更新UI状态
  ↓
刷新统计信息
```

## 🎨 UI设计特点

### 新增设计元素

#### 时段主题色彩
- **早晨**: `#FFE4B5` (暖橙色) - 温暖活力
- **中午**: `#FFF9C4` (明亮黄) - 精力充沛
- **晚上**: `#E1BEE7` (柔和紫) - 温馨舒适

#### 健康等级色彩
- **健康**: `#4CAF50` (绿色) - 营养均衡
- **中等**: `#FFC107` (黄色) - 尚可改进
- **不健康**: `#F44336` (红色) - 需要改善
- **未打卡**: `#CCCCCC` (灰色) - 待评估

#### 卡片设计
- 圆角: 16px
- 阴影: radius 8, color #00000022, offsetY 4
- 内边距: 16px
- 间距: 16px

#### 营养标签图标
- 🥩 蛋白质
- 🌾 碳水化合物
- 🍊 维生素
- 💎 矿物质
- 🥬 膳食纤维

## 🔌 使用的HarmonyOS API

### 新增API使用

#### StorageUtil 扩展
- 新增 `loadString()` 方法支持字符串存储
- 用于保存打卡记录的JSON数据

#### 路由参数传递
```typescript
router.pushUrl({
  url: 'pages/MorningPage',
  params: { /* 参数 */ }
})
```

## 📊 项目统计

### 新增统计
- **新增页面**: 4个 (MorningPage, NoonPage, EveningPage, MealCheckInPage)
- **新增工具类**: 1个 (DietUtil)
- **食物数据**: 30+ 种
- **营养类型**: 5 种
- **季节支持**: 4 季
- **健康等级**: 4 级 (健康/中等/不健康/未打卡)

### 总体统计
- **总文件数**: 约100个文件（含Git对象）
- **源代码文件**: 15个 .ets 文件
- **配置文件**: 10个 .json5 文件
- **页面数量**: 7个主要页面
- **工具类数量**: 5个工具类
- **代码行数**: 约1200行（不含注释和空行）

## 🚀 功能使用指南

### 饮食推荐使用

1. 在主页点击时段按钮（早晨/中午/晚上）
2. 进入对应时段页面
3. 查看：
   - 当前季节信息
   - 推荐食物列表（含热量和营养标签）
   - 健康小贴士

### 三餐打卡使用

1. 在主页点击"三餐打卡"按钮
2. **日视图**:
   - 点击早餐/午餐/晚餐卡片
   - 选择健康等级（健康/中等/不健康）
   - 查看今日统计
3. **月视图**:
   - 点击右上角日历图标切换
   - 查看整月打卡情况
   - 切换月份查看历史记录

## 🎯 未来扩展方向

### 已实现功能 ✅
- ✅ 智能饮食推荐
- ✅ 季节化建议
- ✅ 三餐打卡系统
- ✅ 健康等级评估
- ✅ 月度统计

### 待扩展功能 🔄
- 🔄 贪睡/延迟提醒功能
- 🔄 自定义提醒项
- 🔄 重复周期设置
- 🔄 深色模式支持
- 🔄 多终端适配优化
- 🔄 饮食数据分析图表
- 🔄 健康趋势报告
- 🔄 食物营养详情页
- 🔄 用户偏好学习

## 📝 更新日志

### v1.1.0 (2026-05-19)
**新增功能**:
- ➕ 智能饮食推荐系统 (DietUtil.ets)
- ➕ 时段专属页面 (MorningPage, NoonPage, EveningPage)
- ➕ 三餐打卡系统 (MealCheckInPage)
- ➕ 季节感知功能
- ➕ 健康等级评估
- ➕ 月度统计视图

**功能优化**:
- 🎨 优化UI设计，增加主题色彩
- 🎨 新增营养标签图标
- 🎨 改进卡片布局和阴影效果
- 🔧 扩展StorageUtil支持字符串存储

---

**文档更新时间**: 2026-05-26  
**项目版本**: 1.1.0  
**文档作者**: HarmonyOS Development Assistant

# HarmonyOS 饭点提醒应用 - 工程文件描述

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
│   │   │   │   │       ├── FlipNumber.ets           # 翻页时钟组件
│   │   │   │   │       ├── NotificationUtil.ets     # 通知工具类
│   │   │   │   │       ├── ReminderService.ets      # 提醒服务
│   │   │   │   │       └── StorageUtil.ets          # 数据存储工具
│   │   │   │   ├── entryability/
│   │   │   │   │   └── EntryAbility.ets             # 应用入口能力
│   │   │   │   ├── entrybackupability/
│   │   │   │   │   └── EntryBackupAbility.ets       # 备份能力
│   │   │   │   └── pages/             # 页面目录
│   │   │   │       ├── Index.ets                     # 首页(时钟展示)
│   │   │   │       ├── ReminderSettings.ets          # 提醒设置页
│   │   │   │       └── TimePickerPage.ets            # 时间选择页
│   │   │   ├── resources/             # 资源文件
│   │   │   │   └── base/
│   │   │   │       └── profile/
│   │   │   │           └── main_pages.json          # 页面路由配置
│   │   │   └── module.json5           # 模块配置文件
│   │   ├── mock/                      # 模拟数据
│   │   └── ohosTest/                  # 测试代码
│   ├── build-profile.json5            # 构建配置
│   ├── hvigorfile.ts                  # Hvigor构建脚本
│   └── oh-package.json5               # 依赖配置
├── hvigor/                            # Hvigor构建系统
│   └── hvigor-config.json5            # Hvigor配置
├── pngs/                              # 截图资源
├── README.md                          # 项目说明文档
└── 工程文件描述.md                     # 本文档
```

## 🔧 核心文件详解

### 1. 配置文件

#### app.json5 - 应用全局配置
```json5
{
  "app": {
    "bundleName": "com.example.harmonyos_clock_demo",  // 应用包名
    "vendor": "example",                                // 开发者
    "versionCode": 1000000,                            // 版本号
    "versionName": "1.0.0",                            // 版本名称
    "icon": "$media:app_icon",                         // 应用图标
    "label": "$string:app_name"                        // 应用名称
  }
}
```

#### module.json5 - 模块配置
- **模块类型**: entry (入口模块)
- **支持设备**: phone, tablet, 2in1
- **主能力**: EntryAbility
- **扩展能力**: EntryBackupAbility (备份)
- **页面路由**: 通过 main_pages.json 配置

#### main_pages.json - 页面路由配置
```json
{
  "src": [
    "pages/Index",              // 首页
    "pages/ReminderSettings",   // 提醒设置页
    "pages/TimePickerPage"      // 时间选择页
  ]
}
```

### 2. 页面文件

#### Index.ets - 首页
**功能**: 展示翻页时钟，提供跳转到提醒设置的入口

**核心实现**:
- 使用 `@State` 管理小时和分钟状态
- 通过 `setInterval` 每秒更新时间
- 集成 `FlipNumber` 组件实现翻页效果
- 点击跳转时请求通知权限

**关键代码片段**:
```typescript
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
```

#### ReminderSettings.ets - 提醒设置页
**功能**: 管理三种饭点提醒的开关和时间设置

**核心实现**:
- 使用 `@State` 管理三种提醒的状态（开关、小时、分钟）
- 通过 `StorageUtil` 持久化保存设置
- 使用 `@Builder` 构建可复用的提醒卡片组件
- 启动 `ReminderService` 定时检查提醒

**数据流**:
1. 页面加载时从存储读取设置
2. 接收 TimePickerPage 返回的时间参数
3. 开关状态变化时保存到存储
4. 启动定时提醒检查服务

#### TimePickerPage.ets - 时间选择页
**功能**: 提供时间选择器，修改提醒时间

**核心实现**:
- 使用系统 `TimePicker` 组件
- 接收路由参数中的提醒类型 (morning/noon/evening)
- 选择完成后通过 `router.replaceUrl` 返回并传递新时间

### 3. 工具类文件

#### FlipNumber.ets - 翻页时钟组件
**功能**: 显示单个数字的翻页效果

**实现**:
- 使用 `@Prop` 接收外部传入的值
- 使用 `@State` 管理显示值
- 在 `aboutToUpdate` 生命周期中更新显示

#### NotificationUtil.ets - 通知工具类
**功能**: 封装系统通知相关操作

**主要方法**:
- `requestNotificationPermission()`: 请求通知权限
- `publishSimpleNotification()`: 发布简单文本通知

**实现细节**:
- 使用 `notificationManager` API
- 添加 `SOCIAL_COMMUNICATION` 类型通知槽
- 支持高优先级通知显示

#### ReminderService.ets - 提醒服务
**功能**: 定时检查当前时间并触发提醒

**实现逻辑**:
- 接收三种提醒的配置参数
- 使用 `setInterval` 每分钟检查一次
- 当前时间匹配时发布对应通知
- 使用时间戳作为通知ID确保唯一性

#### StorageUtil.ets - 数据存储工具
**功能**: 封装首选项数据存储操作

**主要方法**:
- `init()`: 初始化 Preferences 实例
- `save()`: 保存数据（支持 number 和 boolean）
- `loadNumber()`: 读取数字类型数据
- `loadBoolean()`: 读取布尔类型数据

**实现细节**:
- 使用 `preferences` API
- 存储文件名: 'reminder_settings'
- 同步操作确保数据一致性

#### EntryAbility.ets - 应用入口
**功能**: 应用生命周期管理

**主要生命周期**:
- `onCreate`: 应用创建时设置颜色模式
- `onWindowStageCreate`: 加载主页面 'pages/Index'
- `onDestroy`: 应用销毁
- `onForeground/onBackground`: 前后台切换

## 🔄 数据流与状态管理

### 状态管理架构
```
┌─────────────────────────────────────────┐
│           Index Page                     │
│  @State: hours, minutes                  │
│  ↓ 定时更新 (1秒/次)                      │
└─────────────────────────────────────────┘
                    ↓ 跳转
┌─────────────────────────────────────────┐
│       ReminderSettings Page              │
│  @State: morningOn/Hour/Minute           │
│  @State: noonOn/Hour/Minute              │
│  @State: eveningOn/Hour/Minute           │
│  ↓ StorageUtil 持久化                     │
│  ↓ ReminderService 定时检查               │
└─────────────────────────────────────────┘
                    ↓ 跳转
┌─────────────────────────────────────────┐
│       TimePickerPage                     │
│  @State: selectedTime                    │
│  ↓ 返回新时间                             │
└─────────────────────────────────────────┘
```

### 数据持久化流程
1. 用户修改设置 → 触发状态更新
2. 调用 `storageUtil.save()` → 保存到 Preferences
3. 页面重新加载 → `aboutToAppear()` 读取存储
4. 恢复用户设置 → 更新 UI 状态

## 🎨 UI设计特点

### 设计风格
- **卡片式布局**: 使用圆角卡片和阴影效果
- **翻页时钟**: 模拟翻页效果的数字显示
- **Material Design**: 借鉴现代设计语言
- **交互反馈**: Toast提示和状态变化动画

### 颜色方案
- 主背景: `#f2f2f2` / `#f5f5f5` (浅灰)
- 卡片背景: `#FFFFFF` (白色)
- 强调色: `#ffbadabb` (粉紫色)
- 文字颜色: `#666666` / `#888888` (灰色系)

## 🔌 使用的HarmonyOS API

### 核心Kit
1. **@kit.AbilityKit**
   - `UIAbility`: 应用能力基类
   - `router`: 页面路由
   - `common.UIAbilityContext`: 应用上下文

2. **@kit.NotificationKit**
   - `notificationManager`: 通知管理
   - 通知权限请求
   - 通知发布

3. **@kit.ArkData**
   - `preferences`: 首选项数据存储

4. **@kit.ArkUI**
   - `window`: 窗口管理
   - UI组件和装饰器

5. **@kit.PerformanceAnalysisKit**
   - `hilog`: 日志输出

### 组件使用
- `@Entry`: 页面入口装饰器
- `@Component`: 组件装饰器
- `@State`: 状态变量装饰器
- `@Prop`: 属性传递装饰器
- `@Builder`: 构建器装饰器
- `Column`, `Row`: 布局容器
- `Text`, `Button`, `Toggle`: 基础组件
- `TimePicker`: 时间选择器

## 🚀 构建与运行

### 构建配置
- **构建工具**: Hvigor
- **API类型**: stageMode
- **混淆配置**: Release模式下可启用代码混淆

### 运行要求
- DevEco Studio
- HarmonyOS SDK (建议最新版本)
- 目标设备: Phone/Tablet/2in1

## 📈 性能优化建议

1. **定时器管理**
   - 建议在页面销毁时清理定时器
   - 考虑使用后台任务进行提醒检查

2. **状态更新**
   - 避免频繁的状态更新导致UI重绘
   - 可考虑使用 `@Watch` 装饰器优化

3. **数据存储**
   - 批量保存减少IO操作
   - 考虑异步操作提升响应速度

## 🔐 权限说明

### 已申请权限
- **通知权限**: 用于发送饭点提醒通知
  - 在用户点击"提醒设置"时动态申请
  - 使用 `requestEnableNotification()` API

### 权限处理流程
1. 用户进入提醒设置页
2. 自动请求通知权限
3. 用户授权后可正常接收提醒
4. 未授权时提醒功能受限

## 📝 代码规范

### 命名规范
- **文件名**: PascalCase (如 `FlipNumber.ets`)
- **组件名**: PascalCase (如 `Index`, `ReminderSettings`)
- **方法名**: camelCase (如 `updateTime`, `buildReminderCard`)
- **变量名**: camelCase (如 `morningOn`, `selectedTime`)

### 注释规范
- 文件顶部添加功能说明注释
- 复杂逻辑添加行内注释
- 公共方法添加文档注释

### 代码组织
- 按功能模块划分目录
- 工具类统一放置在 `common/utils`
- 页面文件统一放置在 `pages`

## 🎯 未来扩展方向

根据 README.md 中的规划，未来可扩展：

1. **贪睡/延迟提醒功能**
   - 添加延迟按钮
   - 实现多次提醒机制

2. **自定义提醒项**
   - 支持动态添加提醒
   - 不再限制三餐

3. **重复周期设置**
   - 每天/工作日/周末
   - 自定义星期几

4. **UI美化**
   - 深色模式支持
   - 更多主题选择
   - 动画效果增强

5. **多终端适配**
   - 平板布局优化
   - 折叠屏适配
   - 响应式设计

## 📊 项目统计

- **总文件数**: 约100个文件（含Git对象）
- **源代码文件**: 9个 .ets 文件
- **配置文件**: 10个 .json5 文件
- **页面数量**: 3个主要页面
- **工具类数量**: 4个工具类
- **代码行数**: 约500行（不含注释和空行）

## 🔗 依赖关系

```
Index.ets
  ├── FlipNumber.ets
  └── NotificationUtil.ets

ReminderSettings.ets
  ├── StorageUtil.ets
  ├── ReminderService.ets
  │   └── NotificationUtil.ets
  └── TimePickerPage.ets

EntryAbility.ets
  └── Index.ets (页面加载)
```

## 📌 注意事项

1. **生命周期管理**
   - 定时器需要在适当时机清理
   - 页面切换时保存状态

2. **权限处理**
   - 通知权限需要用户授权
   - 建议添加权限拒绝的引导

3. **数据存储**
   - StorageUtil 需要先初始化
   - 存储操作建议使用异步方式

4. **通知ID**
   - 使用时间戳确保唯一性
   - 避免通知覆盖

---

**文档生成时间**: 2026-05-19  
**项目版本**: 1.0.0  
**文档作者**: HarmonyOS Development Assistant

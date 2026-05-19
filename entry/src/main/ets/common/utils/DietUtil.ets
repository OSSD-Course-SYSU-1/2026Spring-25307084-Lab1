// DietUtil.ets - 健康饮食推荐工具类

// 营养类型枚举
export enum NutritionType {
  PROTEIN = '蛋白质',
  CARBOHYDRATE = '碳水化合物',
  VITAMIN = '维生素',
  MINERAL = '矿物质',
  FIBER = '膳食纤维'
}

// 季节枚举
export enum Season {
  SPRING = '春季',
  SUMMER = '夏季',
  AUTUMN = '秋季',
  WINTER = '冬季'
}

// 食物接口
export interface Food {
  name: string
  nutrition: NutritionType[]
  calories: number
  description: string
  season: Season[]
}

// 饮食推荐接口
export interface DietRecommendation {
  foods: Food[]
  tips: string[]
  totalCalories: number
}

// 获取当前季节
export function getCurrentSeason(): Season {
  const month = new Date().getMonth() + 1
  
  if (month >= 3 && month <= 5) {
    return Season.SPRING
  } else if (month >= 6 && month <= 8) {
    return Season.SUMMER
  } else if (month >= 9 && month <= 11) {
    return Season.AUTUMN
  } else {
    return Season.WINTER
  }
}

// 食物数据库
const foodDatabase: Food[] = [
  // 蛋白质类
  { name: '鸡蛋', nutrition: [NutritionType.PROTEIN], calories: 78, description: '优质蛋白，易于消化', season: [Season.SPRING, Season.SUMMER, Season.AUTUMN, Season.WINTER] },
  { name: '牛奶', nutrition: [NutritionType.PROTEIN, NutritionType.MINERAL], calories: 120, description: '富含钙质，强健骨骼', season: [Season.SPRING, Season.SUMMER, Season.AUTUMN, Season.WINTER] },
  { name: '豆浆', nutrition: [NutritionType.PROTEIN], calories: 80, description: '植物蛋白，降低胆固醇', season: [Season.SPRING, Season.SUMMER, Season.AUTUMN, Season.WINTER] },
  { name: '鱼肉', nutrition: [NutritionType.PROTEIN, NutritionType.MINERAL], calories: 150, description: '富含DHA，有益大脑', season: [Season.SPRING, Season.SUMMER, Season.AUTUMN, Season.WINTER] },
  { name: '鸡肉', nutrition: [NutritionType.PROTEIN], calories: 165, description: '低脂高蛋白', season: [Season.SPRING, Season.SUMMER, Season.AUTUMN, Season.WINTER] },
  
  // 碳水化合物类
  { name: '燕麦', nutrition: [NutritionType.CARBOHYDRATE, NutritionType.FIBER], calories: 150, description: '低GI，稳定血糖', season: [Season.SPRING, Season.SUMMER, Season.AUTUMN, Season.WINTER] },
  { name: '全麦面包', nutrition: [NutritionType.CARBOHYDRATE, NutritionType.FIBER], calories: 120, description: '富含膳食纤维', season: [Season.SPRING, Season.SUMMER, Season.AUTUMN, Season.WINTER] },
  { name: '小米粥', nutrition: [NutritionType.CARBOHYDRATE], calories: 90, description: '养胃护胃', season: [Season.SPRING, Season.AUTUMN, Season.WINTER] },
  { name: '红薯', nutrition: [NutritionType.CARBOHYDRATE, NutritionType.FIBER], calories: 130, description: '富含β-胡萝卜素', season: [Season.AUTUMN, Season.WINTER] },
  
  // 维生素类
  { name: '菠菜', nutrition: [NutritionType.VITAMIN, NutritionType.MINERAL], calories: 23, description: '富含铁和叶酸', season: [Season.SPRING] },
  { name: '西兰花', nutrition: [NutritionType.VITAMIN, NutritionType.FIBER], calories: 55, description: '抗氧化，增强免疫', season: [Season.SPRING, Season.AUTUMN, Season.WINTER] },
  { name: '胡萝卜', nutrition: [NutritionType.VITAMIN], calories: 41, description: '保护视力', season: [Season.AUTUMN, Season.WINTER] },
  { name: '番茄', nutrition: [NutritionType.VITAMIN], calories: 18, description: '富含番茄红素', season: [Season.SUMMER, Season.AUTUMN] },
  { name: '黄瓜', nutrition: [NutritionType.VITAMIN, NutritionType.FIBER], calories: 16, description: '清热解暑', season: [Season.SUMMER] },
  { name: '苦瓜', nutrition: [NutritionType.VITAMIN], calories: 19, description: '降血糖', season: [Season.SUMMER] },
  
  // 水果类
  { name: '苹果', nutrition: [NutritionType.VITAMIN, NutritionType.FIBER], calories: 95, description: '膳食纤维丰富', season: [Season.AUTUMN, Season.WINTER] },
  { name: '香蕉', nutrition: [NutritionType.CARBOHYDRATE, NutritionType.MINERAL], calories: 105, description: '补充钾元素', season: [Season.SUMMER] },
  { name: '橙子', nutrition: [NutritionType.VITAMIN], calories: 62, description: '维生素C丰富', season: [Season.WINTER, Season.SPRING] },
  { name: '葡萄', nutrition: [NutritionType.VITAMIN], calories: 104, description: '抗氧化', season: [Season.SUMMER, Season.AUTUMN] },
  { name: '草莓', nutrition: [NutritionType.VITAMIN], calories: 49, description: '美容养颜', season: [Season.SPRING] },
  
  // 坚果类
  { name: '核桃', nutrition: [NutritionType.PROTEIN, NutritionType.MINERAL], calories: 185, description: '补脑益智', season: [Season.AUTUMN, Season.WINTER] },
  { name: '杏仁', nutrition: [NutritionType.PROTEIN, NutritionType.VITAMIN], calories: 164, description: '润肺止咳', season: [Season.AUTUMN, Season.WINTER] }
]

// 根据时段和季节获取饮食推荐
export function getDietRecommendation(timeOfDay: 'morning' | 'noon' | 'evening'): DietRecommendation {
  const season = getCurrentSeason()
  const seasonalFoods = foodDatabase.filter(food => food.season.includes(season))
  
  let recommendedFoods: Food[] = []
  let tips: string[] = []
  
  if (timeOfDay === 'morning') {
    // 早晨：注重蛋白质和碳水化合物
    recommendedFoods = seasonalFoods.filter(food => 
      food.nutrition.includes(NutritionType.PROTEIN) || 
      food.nutrition.includes(NutritionType.CARBOHYDRATE)
    ).slice(0, 5)
    
    tips = getMorningTips(season)
  } else if (timeOfDay === 'noon') {
    // 中午：均衡营养
    recommendedFoods = seasonalFoods.slice(0, 6)
    tips = getNoonTips(season)
  } else {
    // 晚上：清淡为主
    recommendedFoods = seasonalFoods.filter(food => 
      food.calories < 150 && 
      (food.nutrition.includes(NutritionType.VITAMIN) || 
       food.nutrition.includes(NutritionType.FIBER))
    ).slice(0, 5)
    
    tips = getEveningTips(season)
  }
  
  const totalCalories = recommendedFoods.reduce((sum, food) => sum + food.calories, 0)
  
  return {
    foods: recommendedFoods,
    tips: tips,
    totalCalories: totalCalories
  }
}

// 早晨健康提示
function getMorningTips(season: Season): string[] {
  const baseTips = [
    '早餐要吃好，一天精神好',
    '建议摄入优质蛋白质',
    '搭配适量碳水化合物',
    '可以适当补充水果'
  ]
  
  const seasonTips: Record<Season, string> = {
    [Season.SPRING]: '春季易困倦，建议多吃富含维生素B的食物',
    [Season.SUMMER]: '夏季出汗多，注意补充水分和矿物质',
    [Season.AUTUMN]: '秋季干燥，多吃润肺食物',
    [Season.WINTER]: '冬季寒冷，适当增加热量摄入'
  }
  
  return [...baseTips, seasonTips[season]]
}

// 中午健康提示
function getNoonTips(season: Season): string[] {
  const baseTips = [
    '午餐要吃饱，营养要均衡',
    '建议荤素搭配',
    '注意补充蔬菜水果',
    '避免暴饮暴食'
  ]
  
  const seasonTips: Record<Season, string> = {
    [Season.SPRING]: '春困时节，午餐后可适当休息',
    [Season.SUMMER]: '炎热夏季，选择清淡易消化食物',
    [Season.AUTUMN]: '秋季进补，适当增加营养',
    [Season.WINTER]: '冬季午餐可适当增加热量'
  }
  
  return [...baseTips, seasonTips[season]]
}

// 晚上健康提示
function getEveningTips(season: Season): string[] {
  const baseTips = [
    '晚餐要吃少，七分饱最好',
    '选择清淡易消化食物',
    '避免高脂肪高热量',
    '睡前2小时不宜进食'
  ]
  
  const seasonTips: Record<Season, string> = {
    [Season.SPRING]: '春季晚餐宜清淡，有助于睡眠',
    [Season.SUMMER]: '夏季晚餐可选择凉拌菜',
    [Season.AUTUMN]: '秋季晚餐可适当喝粥养胃',
    [Season.WINTER]: '冬季晚餐可喝热汤暖身'
  }
  
  return [...baseTips, seasonTips[season]]
}

// 获取营养建议
export function getNutritionAdvice(): string[] {
  return [
    '蛋白质：每日摄入量约0.8-1.2g/kg体重',
    '碳水化合物：占总热量50-65%',
    '脂肪：占总热量20-30%',
    '膳食纤维：每日25-30g',
    '维生素：多吃新鲜蔬果',
    '矿物质：注意钙、铁、锌的补充'
  ]
}

// DistributedDataManager.ets - 分布式数据对象管理器
import distributedDataObject from '@ohos.data.distributedDataObject'
import { common } from '@kit.AbilityKit'

// 三餐打卡流转数据接口
export interface MealContinueData {
  selectedDate: string
  mealRecords: string
  lastSyncTime: number
}

// 分布式数据管理器
export class DistributedDataManager {
  private static instance: DistributedDataManager
  private distributedObject: distributedDataObject.DistributedObject | undefined = undefined
  private context: common.UIAbilityContext | undefined = undefined
  private sessionId: string = ''
  
  private constructor() {}
  
  // 获取单例
  public static getInstance(): DistributedDataManager {
    if (!DistributedDataManager.instance) {
      DistributedDataManager.instance = new DistributedDataManager()
    }
    return DistributedDataManager.instance
  }
  
  // 初始化分布式数据对象
  init(context: common.UIAbilityContext): void {
    this.context = context
  }
  
  // 创建分布式数据对象
  createDistributedObject(data: MealContinueData): distributedDataObject.DistributedObject | undefined {
    if (!this.context) {
      console.error('Context not initialized')
      return undefined
    }
    
    try {
      // 生成会话ID
      this.sessionId = distributedDataObject.genSessionId()
      
      // 创建分布式数据对象
      this.distributedObject = distributedDataObject.create(this.context, data)
      
      // 设置会话ID
      this.distributedObject.setSessionId(this.sessionId)
      
      console.info(`Distributed object created with sessionId: ${this.sessionId}`)
      return this.distributedObject
    } catch (error) {
      console.error(`Failed to create distributed object: ${JSON.stringify(error)}`)
      return undefined
    }
  }
  
  // 更新分布式数据
  updateData(data: MealContinueData): void {
    if (!this.distributedObject) {
      console.error('Distributed object not created')
      return
    }
    
    try {
      this.distributedObject['selectedDate'] = data.selectedDate
      this.distributedObject['mealRecords'] = data.mealRecords
      this.distributedObject['lastSyncTime'] = data.lastSyncTime
      
      console.info('Distributed data updated')
    } catch (error) {
      console.error(`Failed to update data: ${JSON.stringify(error)}`)
    }
  }
  
  // 保存数据到目标设备
  async saveToDevice(deviceId: string): Promise<boolean> {
    if (!this.distributedObject) {
      console.error('Distributed object not created')
      return false
    }
    
    try {
      await this.distributedObject.save(deviceId)
      console.info(`Data saved to device: ${deviceId}`)
      return true
    } catch (error) {
      console.error(`Failed to save data: ${JSON.stringify(error)}`)
      return false
    }
  }
  
  // 监听数据变化
  onDataChange(callback: (data: MealContinueData) => void): void {
    if (!this.distributedObject) {
      console.error('Distributed object not created')
      return
    }
    
    this.distributedObject.on('change', (sessionId: string, fields: string[]) => {
      console.info(`Data changed, sessionId: ${sessionId}, fields: ${fields.join(',')}`)
      
      if (this.distributedObject) {
        const data: MealContinueData = {
          selectedDate: this.distributedObject['selectedDate'] as string,
          mealRecords: this.distributedObject['mealRecords'] as string,
          lastSyncTime: this.distributedObject['lastSyncTime'] as number
        }
        callback(data)
      }
    })
  }
  
  // 监听状态变化
  onStatusChange(callback: (sessionId: string, networkId: string, status: string) => void): void {
    if (!this.distributedObject) {
      console.error('Distributed object not created')
      return
    }
    
    this.distributedObject.on('status', (sessionId: string, networkId: string, status: string) => {
      console.info(`Status changed: ${status}`)
      callback(sessionId, networkId, status)
    })
  }
  
  // 获取当前会话ID
  getSessionId(): string {
    return this.sessionId
  }
  
  // 设置会话ID（用于恢复）
  setSessionId(sessionId: string): void {
    if (!this.distributedObject) {
      console.error('Distributed object not created')
      return
    }
    
    this.sessionId = sessionId
    this.distributedObject.setSessionId(sessionId)
  }
  
  // 销毁分布式数据对象
  destroy(): void {
    if (this.distributedObject) {
      try {
        this.distributedObject.off('change')
        this.distributedObject.off('status')
        console.info('Distributed object destroyed')
      } catch (error) {
        console.error(`Failed to destroy: ${JSON.stringify(error)}`)
      }
      this.distributedObject = undefined
    }
  }
}

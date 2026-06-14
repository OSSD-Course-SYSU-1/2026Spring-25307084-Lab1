// ContinueManager.ets - 设备迁移管理器
import distributedDeviceManager from '@ohos.distributedDeviceManager'
import { common } from '@kit.AbilityKit'

// 设备信息
export interface DeviceInfo {
  deviceId: string
  deviceName: string
  deviceType: string
  networkId: string
}

// 迁移状态
export enum ContinueState {
  IDLE = 'idle',           // 空闲
  CONTINUING = 'continuing', // 迁移中
  SUCCESS = 'success',     // 成功
  FAILED = 'failed'        // 失败
}

// 迁移管理器
export class ContinueManager {
  private deviceManager: distributedDeviceManager.DeviceManager | undefined = undefined
  private context: common.UIAbilityContext | undefined = undefined
  private continueState: ContinueState = ContinueState.IDLE
  private onStateChange: ((state: ContinueState) => void) | undefined = undefined
  
  // 初始化设备管理器
  async init(context: common.UIAbilityContext): Promise<void> {
    this.context = context
    
    try {
      // 创建设备管理器
      this.deviceManager = distributedDeviceManager.createDeviceManager(context.applicationInfo.name)
      
      console.info('设备管理器初始化成功')
    } catch (err) {
      console.error('设备管理器初始化失败')
    }
  }
  
  // 设置状态变化监听器
  setStateChangeListener(listener: (state: ContinueState) => void): void {
    this.onStateChange = listener
  }
  
  // 更新迁移状态
  private updateState(state: ContinueState): void {
    this.continueState = state
    if (this.onStateChange) {
      this.onStateChange(state)
    }
  }
  
  // 获取可用设备列表
  getAvailableDevices(): DeviceInfo[] {
    if (!this.deviceManager) {
      console.error('设备管理器未初始化')
      return []
    }
    
    try {
      const deviceInfos = this.deviceManager.getAvailableDeviceListSync()
      const devices: DeviceInfo[] = []
      
      for (const info of deviceInfos) {
        devices.push({
          deviceId: info.deviceId,
          deviceName: info.deviceName,
          deviceType: info.deviceType,
          networkId: info.networkId
        })
      }
      
      return devices
    } catch (err) {
      console.error('获取设备列表失败')
      return []
    }
  }
  
  // 发起迁移
  async continueToDevice(deviceId: string): Promise<void> {
    if (!this.context || !this.deviceManager) {
      console.error('未初始化')
      this.updateState(ContinueState.FAILED)
      return
    }
    
    this.updateState(ContinueState.CONTINUING)
    
    try {
      // 使用设备ID发起迁移
      // 注意：实际的迁移由系统Dock栏触发，这里只是准备状态
      console.info('准备迁移到设备:', deviceId)
      this.updateState(ContinueState.SUCCESS)
    } catch (err) {
      console.error('迁移失败')
      this.updateState(ContinueState.FAILED)
    }
  }
  
  // 获取当前迁移状态
  getState(): ContinueState {
    return this.continueState
  }
  
  // 订阅设备状态变化
  subscribeDeviceState(callback: (device: DeviceInfo, state: string) => void): void {
    if (!this.deviceManager) {
      console.error('设备管理器未初始化')
      return
    }
    
    try {
      this.deviceManager.on('deviceStateChange', (data) => {
        console.info('设备状态变化')
        const device: DeviceInfo = {
          deviceId: data.device.deviceId,
          deviceName: data.device.deviceName,
          deviceType: data.device.deviceType,
          networkId: data.device.networkId
        }
        // 根据action判断状态
        const stateStr = data.action === distributedDeviceManager.DeviceStateChange.DEVICE_ONLINE ? 'online' : 'offline'
        callback(device, stateStr)
      })
      console.info('设备状态订阅成功')
    } catch (err) {
      console.error('设备状态订阅失败')
    }
  }
  
  // 取消设备状态订阅
  unsubscribeDeviceState(): void {
    if (!this.deviceManager) {
      return
    }
    
    try {
      this.deviceManager.off('deviceStateChange')
      console.info('取消设备状态订阅')
    } catch (err) {
      console.error('取消订阅失败')
    }
  }
  
  // 销毁管理器
  destroy(): void {
    this.unsubscribeDeviceState()
    if (this.deviceManager) {
      try {
        distributedDeviceManager.releaseDeviceManager(this.deviceManager)
        console.info('设备管理器已销毁')
      } catch (err) {
        console.error('销毁失败')
      }
    }
  }
}

// 全局单例
let continueManager: ContinueManager | undefined = undefined

export function getContinueManager(): ContinueManager {
  if (!continueManager) {
    continueManager = new ContinueManager()
  }
  return continueManager
}

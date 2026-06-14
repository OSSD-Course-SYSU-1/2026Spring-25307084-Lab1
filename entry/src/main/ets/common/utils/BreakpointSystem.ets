/**
 * 断点系统工具类
 * 用于监听窗口尺寸变化，实现响应式布局
 */
import { mediaquery } from '@kit.ArkUI';

export type BreakpointType = 'xs' | 'sm' | 'md' | 'lg' | 'xl';

export interface Breakpoint {
  name: BreakpointType;
  size: number;
  mediaQueryListener?: mediaquery.MediaQueryListener;
}

/**
 * 断点系统
 * 根据窗口宽度划分不同断点区间：
 * - xs: [0, 320vp) - 智能穿戴
 * - sm: [320vp, 600vp) - 手机竖屏
 * - md: [600vp, 840vp) - 折叠屏/小平板
 * - lg: [840vp, 1440vp) - 平板/PC
 * - xl: [1440vp, +∞) - 大屏设备
 */
export class BreakpointSystem {
  private static instance: BreakpointSystem;
  
  // 断点配置
  private readonly breakpoints: Breakpoint[] = [
    { name: 'xs', size: 0 },
    { name: 'sm', size: 320 },
    { name: 'md', size: 600 },
    { name: 'lg', size: 840 },
    { name: 'xl', size: 1440 }
  ];
  
  private states: Set<BreakpointState<Object>> = new Set();
  
  private constructor() {}
  
  /**
   * 获取单例实例
   */
  public static getInstance(): BreakpointSystem {
    if (!BreakpointSystem.instance) {
      BreakpointSystem.instance = new BreakpointSystem();
    }
    return BreakpointSystem.instance;
  }
  
  /**
   * 注册断点监听
   */
  public register(): void {
    this.breakpoints.forEach((breakpoint: Breakpoint, index: number) => {
      let condition: string;
      
      if (index === this.breakpoints.length - 1) {
        // 最后一个断点：大于等于该尺寸
        condition = `(${breakpoint.size}vp<=width)`;
      } else {
        // 中间断点：在该尺寸范围内
        condition = `(${breakpoint.size}vp<=width<${this.breakpoints[index + 1].size}vp)`;
      }
      
      // 创建媒体查询监听器
      breakpoint.mediaQueryListener = mediaquery.matchMediaSync(condition);
      
      // 如果当前匹配，立即更新状态
      if (breakpoint.mediaQueryListener.matches) {
        this.updateAllState(breakpoint.name);
      }
      
      // 监听变化
      breakpoint.mediaQueryListener.on('change', (mediaQueryResult: mediaquery.MediaQueryResult) => {
        if (mediaQueryResult.matches) {
          this.updateAllState(breakpoint.name);
        }
      });
    });
  }
  
  /**
   * 注销断点监听
   */
  public unregister(): void {
    this.breakpoints.forEach((breakpoint: Breakpoint) => {
      if (breakpoint.mediaQueryListener) {
        breakpoint.mediaQueryListener.off('change');
      }
    });
    this.states.clear();
  }
  
  /**
   * 附加状态对象
   */
  public attach(state: BreakpointState<Object>): void {
    this.states.add(state);
  }
  
  /**
   * 分离状态对象
   */
  public detach(state: BreakpointState<Object>): void {
    this.states.delete(state);
  }
  
  /**
   * 更新所有状态
   */
  private updateAllState(type: BreakpointType): void {
    // 更新全局存储
    AppStorage.setOrCreate<string>('currentBreakpoint', type);
    
    // 更新所有附加的状态对象
    this.states.forEach(state => state.update(type));
  }
}

/**
 * 断点状态接口
 */
export interface BreakpointOptions<T> {
  xs?: T;
  sm?: T;
  md?: T;
  lg?: T;
  xl?: T;
}

/**
 * 断点状态类
 * 用于根据当前断点返回不同的值
 */
export class BreakpointState<T extends Object> {
  public value: T | undefined = undefined;
  private options: BreakpointOptions<T>;
  
  constructor(options: BreakpointOptions<T>) {
    this.options = options;
  }
  
  /**
   * 创建断点状态实例
   */
  static of<T extends Object>(options: BreakpointOptions<T>): BreakpointState<T> {
    return new BreakpointState(options);
  }
  
  /**
   * 更新当前断点的值
   */
  public update(type: BreakpointType): void {
    switch (type) {
      case 'xs':
        this.value = this.options.xs;
        break;
      case 'sm':
        this.value = this.options.sm;
        break;
      case 'md':
        this.value = this.options.md;
        break;
      case 'lg':
        this.value = this.options.lg;
        break;
      case 'xl':
        this.value = this.options.xl;
        break;
      default:
        this.value = undefined;
        break;
    }
  }
}

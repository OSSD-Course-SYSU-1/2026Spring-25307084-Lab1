if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface Countdown_Params {
    hours?: number;
    minutes?: number;
    seconds?: number;
    remainingSeconds?: number;
    isRunning?: boolean;
    isPaused?: boolean;
    intervalId?: number;
}
import router from "@ohos:router";
class Countdown extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__hours = new ObservedPropertySimplePU(0, this, "hours");
        this.__minutes = new ObservedPropertySimplePU(5, this, "minutes");
        this.__seconds = new ObservedPropertySimplePU(0, this, "seconds");
        this.__remainingSeconds = new ObservedPropertySimplePU(0, this, "remainingSeconds");
        this.__isRunning = new ObservedPropertySimplePU(false, this, "isRunning");
        this.__isPaused = new ObservedPropertySimplePU(false, this, "isPaused");
        this.intervalId = 0;
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: Countdown_Params) {
        if (params.hours !== undefined) {
            this.hours = params.hours;
        }
        if (params.minutes !== undefined) {
            this.minutes = params.minutes;
        }
        if (params.seconds !== undefined) {
            this.seconds = params.seconds;
        }
        if (params.remainingSeconds !== undefined) {
            this.remainingSeconds = params.remainingSeconds;
        }
        if (params.isRunning !== undefined) {
            this.isRunning = params.isRunning;
        }
        if (params.isPaused !== undefined) {
            this.isPaused = params.isPaused;
        }
        if (params.intervalId !== undefined) {
            this.intervalId = params.intervalId;
        }
    }
    updateStateVars(params: Countdown_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__hours.purgeDependencyOnElmtId(rmElmtId);
        this.__minutes.purgeDependencyOnElmtId(rmElmtId);
        this.__seconds.purgeDependencyOnElmtId(rmElmtId);
        this.__remainingSeconds.purgeDependencyOnElmtId(rmElmtId);
        this.__isRunning.purgeDependencyOnElmtId(rmElmtId);
        this.__isPaused.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__hours.aboutToBeDeleted();
        this.__minutes.aboutToBeDeleted();
        this.__seconds.aboutToBeDeleted();
        this.__remainingSeconds.aboutToBeDeleted();
        this.__isRunning.aboutToBeDeleted();
        this.__isPaused.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __hours: ObservedPropertySimplePU<number>;
    get hours() {
        return this.__hours.get();
    }
    set hours(newValue: number) {
        this.__hours.set(newValue);
    }
    private __minutes: ObservedPropertySimplePU<number>;
    get minutes() {
        return this.__minutes.get();
    }
    set minutes(newValue: number) {
        this.__minutes.set(newValue);
    }
    private __seconds: ObservedPropertySimplePU<number>;
    get seconds() {
        return this.__seconds.get();
    }
    set seconds(newValue: number) {
        this.__seconds.set(newValue);
    }
    private __remainingSeconds: ObservedPropertySimplePU<number>;
    get remainingSeconds() {
        return this.__remainingSeconds.get();
    }
    set remainingSeconds(newValue: number) {
        this.__remainingSeconds.set(newValue);
    }
    private __isRunning: ObservedPropertySimplePU<boolean>;
    get isRunning() {
        return this.__isRunning.get();
    }
    set isRunning(newValue: boolean) {
        this.__isRunning.set(newValue);
    }
    private __isPaused: ObservedPropertySimplePU<boolean>;
    get isPaused() {
        return this.__isPaused.get();
    }
    set isPaused(newValue: boolean) {
        this.__isPaused.set(newValue);
    }
    private intervalId: number;
    aboutToDisappear() {
        if (this.intervalId) {
            clearInterval(this.intervalId);
        }
    }
    // 格式化时间显示
    formatTime(num: number): string {
        return num < 10 ? `0${num}` : `${num}`;
    }
    // 计算总秒数
    getTotalSeconds(): number {
        return this.hours * 3600 + this.minutes * 60 + this.seconds;
    }
    // 开始倒计时
    startCountdown() {
        if (this.isPaused) {
            // 继续暂停的倒计时
            this.isPaused = false;
            this.isRunning = true;
        }
        else {
            // 开始新的倒计时
            this.remainingSeconds = this.getTotalSeconds();
            if (this.remainingSeconds <= 0) {
                return;
            }
            this.isRunning = true;
        }
        this.intervalId = setInterval(() => {
            if (this.remainingSeconds > 0) {
                this.remainingSeconds--;
            }
            else {
                this.stopCountdown();
                // 倒计时结束，可以添加提示
            }
        }, 1000);
    }
    // 暂停倒计时
    pauseCountdown() {
        if (this.intervalId) {
            clearInterval(this.intervalId);
        }
        this.isPaused = true;
        this.isRunning = false;
    }
    // 停止倒计时
    stopCountdown() {
        if (this.intervalId) {
            clearInterval(this.intervalId);
        }
        this.isRunning = false;
        this.isPaused = false;
        this.remainingSeconds = 0;
    }
    // 重置倒计时
    resetCountdown() {
        this.stopCountdown();
        this.hours = 0;
        this.minutes = 5;
        this.seconds = 0;
    }
    // 获取显示的小时
    getDisplayHours(): number {
        return Math.floor(this.remainingSeconds / 3600);
    }
    // 获取显示的分钟
    getDisplayMinutes(): number {
        return Math.floor((this.remainingSeconds % 3600) / 60);
    }
    // 获取显示的秒数
    getDisplaySeconds(): number {
        return this.remainingSeconds % 60;
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.height('100%');
            Column.backgroundColor('#F5F5F5');
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 顶部导航栏
            Row.create();
            // 顶部导航栏
            Row.width('100%');
            // 顶部导航栏
            Row.padding({ left: 20, right: 20, top: 15, bottom: 15 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithChild({ type: ButtonType.Circle });
            Button.width(40);
            Button.height(40);
            Button.backgroundColor('#1976D2');
            Button.onClick(() => {
                router.back();
            });
        }, Button);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('<');
            Text.fontSize(24);
            Text.fontColor(Color.White);
        }, Text);
        Text.pop();
        Button.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('倒计时');
            Text.fontSize(24);
            Text.fontWeight(FontWeight.Bold);
            Text.fontColor('#333333');
            Text.margin({ left: 20 });
        }, Text);
        Text.pop();
        // 顶部导航栏
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 倒计时显示区域
            Column.create();
            // 倒计时显示区域
            Column.width('100%');
            // 倒计时显示区域
            Column.height(300);
            // 倒计时显示区域
            Column.justifyContent(FlexAlign.Center);
            // 倒计时显示区域
            Column.margin({ top: 40 });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.isRunning || this.isPaused) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        // 显示倒计时
                        Text.create(`${this.formatTime(this.getDisplayHours())}:${this.formatTime(this.getDisplayMinutes())}:${this.formatTime(this.getDisplaySeconds())}`);
                        // 显示倒计时
                        Text.fontSize(72);
                        // 显示倒计时
                        Text.fontWeight(FontWeight.Bold);
                        // 显示倒计时
                        Text.fontColor(this.isPaused ? '#999999' : '#1976D2');
                    }, Text);
                    // 显示倒计时
                    Text.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        // 设置时间
                        Row.create();
                        // 设置时间
                        Row.width('100%');
                    }, Row);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        // 小时选择器
                        Column.create();
                        // 小时选择器
                        Column.layoutWeight(1);
                    }, Column);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('时');
                        Text.fontSize(16);
                        Text.fontColor('#666666');
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(this.formatTime(this.hours));
                        Text.fontSize(48);
                        Text.fontWeight(FontWeight.Bold);
                        Text.fontColor('#1976D2');
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Row.create();
                    }, Row);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Button.createWithLabel('-');
                        Button.fontSize(20);
                        Button.width(40);
                        Button.height(40);
                        Button.onClick(() => {
                            if (this.hours > 0)
                                this.hours--;
                        });
                    }, Button);
                    Button.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Button.createWithLabel('+');
                        Button.fontSize(20);
                        Button.width(40);
                        Button.height(40);
                        Button.onClick(() => {
                            if (this.hours < 23)
                                this.hours++;
                        });
                    }, Button);
                    Button.pop();
                    Row.pop();
                    // 小时选择器
                    Column.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(':');
                        Text.fontSize(48);
                        Text.fontWeight(FontWeight.Bold);
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        // 分钟选择器
                        Column.create();
                        // 分钟选择器
                        Column.layoutWeight(1);
                    }, Column);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('分');
                        Text.fontSize(16);
                        Text.fontColor('#666666');
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(this.formatTime(this.minutes));
                        Text.fontSize(48);
                        Text.fontWeight(FontWeight.Bold);
                        Text.fontColor('#1976D2');
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Row.create();
                    }, Row);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Button.createWithLabel('-');
                        Button.fontSize(20);
                        Button.width(40);
                        Button.height(40);
                        Button.onClick(() => {
                            if (this.minutes > 0)
                                this.minutes--;
                        });
                    }, Button);
                    Button.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Button.createWithLabel('+');
                        Button.fontSize(20);
                        Button.width(40);
                        Button.height(40);
                        Button.onClick(() => {
                            if (this.minutes < 59)
                                this.minutes++;
                        });
                    }, Button);
                    Button.pop();
                    Row.pop();
                    // 分钟选择器
                    Column.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(':');
                        Text.fontSize(48);
                        Text.fontWeight(FontWeight.Bold);
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        // 秒选择器
                        Column.create();
                        // 秒选择器
                        Column.layoutWeight(1);
                    }, Column);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('秒');
                        Text.fontSize(16);
                        Text.fontColor('#666666');
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(this.formatTime(this.seconds));
                        Text.fontSize(48);
                        Text.fontWeight(FontWeight.Bold);
                        Text.fontColor('#1976D2');
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Row.create();
                    }, Row);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Button.createWithLabel('-');
                        Button.fontSize(20);
                        Button.width(40);
                        Button.height(40);
                        Button.onClick(() => {
                            if (this.seconds > 0)
                                this.seconds--;
                        });
                    }, Button);
                    Button.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Button.createWithLabel('+');
                        Button.fontSize(20);
                        Button.width(40);
                        Button.height(40);
                        Button.onClick(() => {
                            if (this.seconds < 59)
                                this.seconds++;
                        });
                    }, Button);
                    Button.pop();
                    Row.pop();
                    // 秒选择器
                    Column.pop();
                    // 设置时间
                    Row.pop();
                });
            }
        }, If);
        If.pop();
        // 倒计时显示区域
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 控制按钮
            Row.create();
            // 控制按钮
            Row.width('100%');
            // 控制按钮
            Row.justifyContent(FlexAlign.Center);
            // 控制按钮
            Row.margin({ top: 40 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (!this.isRunning && !this.isPaused) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        // 开始按钮
                        Button.createWithLabel('开始');
                        // 开始按钮
                        Button.fontSize(20);
                        // 开始按钮
                        Button.width(120);
                        // 开始按钮
                        Button.height(50);
                        // 开始按钮
                        Button.backgroundColor('#1976D2');
                        // 开始按钮
                        Button.onClick(() => {
                            this.startCountdown();
                        });
                    }, Button);
                    // 开始按钮
                    Button.pop();
                });
            }
            else if (this.isRunning) {
                this.ifElseBranchUpdateFunction(1, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        // 暂停和停止按钮
                        Button.createWithLabel('暂停');
                        // 暂停和停止按钮
                        Button.fontSize(20);
                        // 暂停和停止按钮
                        Button.width(100);
                        // 暂停和停止按钮
                        Button.height(50);
                        // 暂停和停止按钮
                        Button.backgroundColor('#FF9800');
                        // 暂停和停止按钮
                        Button.onClick(() => {
                            this.pauseCountdown();
                        });
                    }, Button);
                    // 暂停和停止按钮
                    Button.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Button.createWithLabel('停止');
                        Button.fontSize(20);
                        Button.width(100);
                        Button.height(50);
                        Button.backgroundColor('#F44336');
                        Button.margin({ left: 20 });
                        Button.onClick(() => {
                            this.stopCountdown();
                        });
                    }, Button);
                    Button.pop();
                });
            }
            else if (this.isPaused) {
                this.ifElseBranchUpdateFunction(2, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        // 继续、停止和重置按钮
                        Button.createWithLabel('继续');
                        // 继续、停止和重置按钮
                        Button.fontSize(20);
                        // 继续、停止和重置按钮
                        Button.width(100);
                        // 继续、停止和重置按钮
                        Button.height(50);
                        // 继续、停止和重置按钮
                        Button.backgroundColor('#4CAF50');
                        // 继续、停止和重置按钮
                        Button.onClick(() => {
                            this.startCountdown();
                        });
                    }, Button);
                    // 继续、停止和重置按钮
                    Button.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Button.createWithLabel('停止');
                        Button.fontSize(20);
                        Button.width(100);
                        Button.height(50);
                        Button.backgroundColor('#F44336');
                        Button.margin({ left: 20 });
                        Button.onClick(() => {
                            this.stopCountdown();
                        });
                    }, Button);
                    Button.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(3, () => {
                });
            }
        }, If);
        If.pop();
        // 控制按钮
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            // 重置按钮
            if (!this.isRunning) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Button.createWithLabel('重置');
                        Button.fontSize(18);
                        Button.width(100);
                        Button.height(45);
                        Button.backgroundColor('#9E9E9E');
                        Button.margin({ top: 20 });
                        Button.onClick(() => {
                            this.resetCountdown();
                        });
                    }, Button);
                    Button.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        Column.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
    static getEntryName(): string {
        return "Countdown";
    }
}
registerNamedRoute(() => new Countdown(undefined, {}), "", { bundleName: "ohos.samples.etsclock", moduleName: "entry", pagePath: "pages/Countdown", pageFullPath: "entry/src/main/ets/pages/Countdown", integratedHsp: "false", moduleType: "followWithHap" });

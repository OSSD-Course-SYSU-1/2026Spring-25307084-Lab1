if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface Clock_Params {
    canvasWidth?: number;
    settings?: RenderingContextSettings;
    context?: CanvasRenderingContext2D;
    radius?: number;
    intervalId?: number;
    drawClock?: DrawClock;
    updateTime?;
}
import display from "@ohos:display";
import hilog from "@ohos:hilog";
import router from "@ohos:router";
import Logger from "@bundle:ohos.samples.etsclock/entry/ets/utils/Logger";
import DrawClock from "@bundle:ohos.samples.etsclock/entry/ets/utils/DrawClock";
import CommonConstants from "@bundle:ohos.samples.etsclock/entry/ets/common/CommonConstants";
const HEIGHT_ADD: number = CommonConstants.HEIGHT_ADD; // The time needs to be drawn below the dial. The canvas height is the width plus 150
const TAG: string = 'Index';
class Clock extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__canvasWidth = new ObservedPropertySimplePU(CommonConstants.DEFAULT_WATCH_SIZE, this, "canvasWidth");
        this.settings = new RenderingContextSettings(true);
        this.context = new CanvasRenderingContext2D(this.settings);
        this.radius = CommonConstants.DEFAULT_WATCH_RADIUS;
        this.intervalId = 0;
        this.drawClock = new DrawClock();
        this.updateTime = () => {
            this.context.clearRect(0, 0, this.canvasWidth, this.canvasWidth + HEIGHT_ADD);
            let nowTime = new Date();
            let hour = nowTime.getHours();
            let minute = nowTime.getMinutes();
            let second = nowTime.getSeconds();
            let time = `${this.fillTime(hour)}:${this.fillTime(minute)}:${this.fillTime(second)}`;
            this.drawClock.drawClock(this.context, this.radius, this.canvasWidth, hour, minute, second, time);
            this.context.translate(-this.radius, -this.radius);
        };
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: Clock_Params) {
        if (params.canvasWidth !== undefined) {
            this.canvasWidth = params.canvasWidth;
        }
        if (params.settings !== undefined) {
            this.settings = params.settings;
        }
        if (params.context !== undefined) {
            this.context = params.context;
        }
        if (params.radius !== undefined) {
            this.radius = params.radius;
        }
        if (params.intervalId !== undefined) {
            this.intervalId = params.intervalId;
        }
        if (params.drawClock !== undefined) {
            this.drawClock = params.drawClock;
        }
        if (params.updateTime !== undefined) {
            this.updateTime = params.updateTime;
        }
    }
    updateStateVars(params: Clock_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__canvasWidth.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__canvasWidth.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __canvasWidth: ObservedPropertySimplePU<number>; // 300 is the size of the dial
    get canvasWidth() {
        return this.__canvasWidth.get();
    }
    set canvasWidth(newValue: number) {
        this.__canvasWidth.set(newValue);
    }
    private settings: RenderingContextSettings;
    private context: CanvasRenderingContext2D;
    private radius: number; // Default dial radius
    private intervalId: number;
    private drawClock: DrawClock;
    private updateTime;
    fillTime(time: number) {
        return time < CommonConstants.NUMBER_TEN ? `0${time}` : `${time}`;
    }
    onPageShow(): void {
        this.updateTime();
        this.intervalId = setInterval(this.updateTime, CommonConstants.INTERVAL_TIME);
    }
    onPageHide() {
        clearInterval(this.intervalId);
    }
    aboutToAppear() {
        this.getSize();
    }
    // Get the width and height of the device to calculate the dial size
    async getSize() {
        try {
            let mDisplay = display.getDefaultDisplaySync();
            Logger.info(TAG, `getDefaultDisplay mDisplay = ${JSON.stringify(mDisplay)}`);
            this.canvasWidth = this.getUIContext().px2vp(mDisplay.width > mDisplay.height ? mDisplay.height * CommonConstants.CONVERSION_RATE :
                mDisplay.width * CommonConstants.CONVERSION_RATE);
            this.radius = this.canvasWidth / CommonConstants.NUMBER_TWO;
        }
        catch (error) {
            hilog.error(0x0000, TAG, `getSize catch error, code: ${error.code}, message: ${error.message}`);
        }
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width(CommonConstants.FULL_PERCENTAGE);
            Column.height(CommonConstants.FULL_PERCENTAGE);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 时钟显示区域
            Stack.create({ alignContent: Alignment.Center });
            // 时钟显示区域
            Stack.width(CommonConstants.FULL_PERCENTAGE);
            // 时钟显示区域
            Stack.layoutWeight(1);
        }, Stack);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Canvas.create(this.context);
            Canvas.padding({ top: { "id": 16777222, "type": 10002, params: [], "bundleName": "ohos.samples.etsclock", "moduleName": "entry" } });
            Canvas.width(this.canvasWidth);
            Canvas.height(this.canvasWidth + HEIGHT_ADD);
            Canvas.onReady(() => {
                this.updateTime();
                this.intervalId = setInterval(this.updateTime, CommonConstants.INTERVAL_TIME);
            });
        }, Canvas);
        Canvas.pop();
        // 时钟显示区域
        Stack.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 底部倒计时导航按钮
            Button.createWithLabel('倒计时');
            // 底部倒计时导航按钮
            Button.fontSize(18);
            // 底部倒计时导航按钮
            Button.fontColor(Color.White);
            // 底部倒计时导航按钮
            Button.backgroundColor('#1976D2');
            // 底部倒计时导航按钮
            Button.borderRadius(25);
            // 底部倒计时导航按钮
            Button.width(120);
            // 底部倒计时导航按钮
            Button.height(50);
            // 底部倒计时导航按钮
            Button.margin({ bottom: 30 });
            // 底部倒计时导航按钮
            Button.onClick(() => {
                router.pushUrl({ url: 'pages/Countdown' });
            });
        }, Button);
        // 底部倒计时导航按钮
        Button.pop();
        Column.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
    static getEntryName(): string {
        return "Clock";
    }
}
registerNamedRoute(() => new Clock(undefined, {}), "", { bundleName: "ohos.samples.etsclock", moduleName: "entry", pagePath: "pages/Index", pageFullPath: "entry/src/main/ets/pages/Index", integratedHsp: "false", moduleType: "followWithHap" });

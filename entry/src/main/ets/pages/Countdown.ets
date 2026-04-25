/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import router from '@ohos.router';
import CommonConstants from '../common/CommonConstants';

@Entry
@Component
struct Countdown {
  @State hours: number = 0;
  @State minutes: number = 5;
  @State seconds: number = 0;
  @State remainingSeconds: number = 0;
  @State isRunning: boolean = false;
  @State isPaused: boolean = false;
  private intervalId: number = 0;

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
    } else {
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
      } else {
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

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button({ type: ButtonType.Circle }) {
          Text('<')
            .fontSize(24)
            .fontColor(Color.White)
        }
        .width(40)
        .height(40)
        .backgroundColor('#1976D2')
        .onClick(() => {
          router.back();
        })

        Text('倒计时')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ left: 20 })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 15, bottom: 15 })

      // 倒计时显示区域
      Column() {
        if (this.isRunning || this.isPaused) {
          // 显示倒计时
          Text(`${this.formatTime(this.getDisplayHours())}:${this.formatTime(this.getDisplayMinutes())}:${this.formatTime(this.getDisplaySeconds())}`)
            .fontSize(72)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.isPaused ? '#999999' : '#1976D2')
        } else {
          // 设置时间
          Row() {
            // 小时选择器
            Column() {
              Text('时')
                .fontSize(16)
                .fontColor('#666666')
              Text(this.formatTime(this.hours))
                .fontSize(48)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1976D2')
              Row() {
                Button('-')
                  .fontSize(20)
                  .width(40)
                  .height(40)
                  .onClick(() => {
                    if (this.hours > 0) this.hours--;
                  })
                Button('+')
                  .fontSize(20)
                  .width(40)
                  .height(40)
                  .onClick(() => {
                    if (this.hours < 23) this.hours++;
                  })
              }
            }
            .layoutWeight(1)

            Text(':')
              .fontSize(48)
              .fontWeight(FontWeight.Bold)

            // 分钟选择器
            Column() {
              Text('分')
                .fontSize(16)
                .fontColor('#666666')
              Text(this.formatTime(this.minutes))
                .fontSize(48)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1976D2')
              Row() {
                Button('-')
                  .fontSize(20)
                  .width(40)
                  .height(40)
                  .onClick(() => {
                    if (this.minutes > 0) this.minutes--;
                  })
                Button('+')
                  .fontSize(20)
                  .width(40)
                  .height(40)
                  .onClick(() => {
                    if (this.minutes < 59) this.minutes++;
                  })
              }
            }
            .layoutWeight(1)

            Text(':')
              .fontSize(48)
              .fontWeight(FontWeight.Bold)

            // 秒选择器
            Column() {
              Text('秒')
                .fontSize(16)
                .fontColor('#666666')
              Text(this.formatTime(this.seconds))
                .fontSize(48)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1976D2')
              Row() {
                Button('-')
                  .fontSize(20)
                  .width(40)
                  .height(40)
                  .onClick(() => {
                    if (this.seconds > 0) this.seconds--;
                  })
                Button('+')
                  .fontSize(20)
                  .width(40)
                  .height(40)
                  .onClick(() => {
                    if (this.seconds < 59) this.seconds++;
                  })
              }
            }
            .layoutWeight(1)
          }
          .width('100%')
        }
      }
      .width('100%')
      .height(300)
      .justifyContent(FlexAlign.Center)
      .margin({ top: 40 })

      // 控制按钮
      Row() {
        if (!this.isRunning && !this.isPaused) {
          // 开始按钮
          Button('开始')
            .fontSize(20)
            .width(120)
            .height(50)
            .backgroundColor('#1976D2')
            .onClick(() => {
              this.startCountdown();
            })
        } else if (this.isRunning) {
          // 暂停和停止按钮
          Button('暂停')
            .fontSize(20)
            .width(100)
            .height(50)
            .backgroundColor('#FF9800')
            .onClick(() => {
              this.pauseCountdown();
            })

          Button('停止')
            .fontSize(20)
            .width(100)
            .height(50)
            .backgroundColor('#F44336')
            .margin({ left: 20 })
            .onClick(() => {
              this.stopCountdown();
            })
        } else if (this.isPaused) {
          // 继续、停止和重置按钮
          Button('继续')
            .fontSize(20)
            .width(100)
            .height(50)
            .backgroundColor('#4CAF50')
            .onClick(() => {
              this.startCountdown();
            })

          Button('停止')
            .fontSize(20)
            .width(100)
            .height(50)
            .backgroundColor('#F44336')
            .margin({ left: 20 })
            .onClick(() => {
              this.stopCountdown();
            })
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ top: 40 })

      // 重置按钮
      if (!this.isRunning) {
        Button('重置')
          .fontSize(18)
          .width(100)
          .height(45)
          .backgroundColor('#9E9E9E')
          .margin({ top: 20 })
          .onClick(() => {
            this.resetCountdown();
          })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}

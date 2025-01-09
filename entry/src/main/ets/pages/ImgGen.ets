/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

import CommonConstants from '../common/constants/CommonConstants'

import { router } from '@kit.ArkUI'
import WindowManager from '../utils/WindowManager';
import http from '@ohos.net.http';
import hilog from '@ohos.hilog';
import taskpool from '@ohos.taskpool';
/**
 * Setting tab content
 */

// 定义 output 部分的接口
interface Output {
  task_status: string;
  task_id: string;
}

// 定义整个 JSON 对应的接口
interface Response {
  output: Output;
  request_id: string;
}

// 定义 task_metrics 部分的接口
interface TaskMetrics {
  TOTAL: number;
  SUCCEEDED: number;
  FAILED: number;
}

// 定义 output 部分的接口
interface AskOutput {
  task_id: string;
  task_status: string;
  submit_time: string;
  scheduled_time: string;
  task_metrics: TaskMetrics;
}

// 定义整个 JSON 对应的接口
interface AskResponse {
  request_id: string;
  output: AskOutput;
}


// 定义 results 数组中单个元素的接口
interface Result {
  url: string;
}

// 定义 task_metrics 部分的接口
interface SucTaskMetrics {
  TOTAL: number;
  SUCCEEDED: number;
  FAILED: number;
}

// 定义 output 部分的接口
interface SucOutput {
  task_id: string;
  task_status: string;
  results: Result[];
  task_metrics: SucTaskMetrics;
}

// 定义 usage 部分的接口
interface Usage {
  image_count: number;
}

// 定义整个 JSON 对应的接口
interface SucResponse {
  request_id: string;
  output: SucOutput;
  usage: Usage;
}




@Entry
@Component
export default struct ImgGen {
  @State text:string = ""
  private controller: TextAreaController = new TextAreaController()
  @State imgUrl: string= ""
  @State textAreaEnabled:boolean = true

  ask(task_id:string){
    let askHttpRequest = http.createHttp();
    askHttpRequest.request(
      "https://dashscope.aliyuncs.com/api/v1/tasks/" + task_id,
      {
        method: http.RequestMethod.GET,
        header: {
          // 这里的Authorization 就是刚才工作台查看的 API-KEY
          "Authorization": "sk-d3af13a4247e4082b8db7818e8c1e9b8",// 脱敏处理
        }
      }, async (err, data: http.HttpResponse) => {
      if (err) {
        hilog.error(0x0000, 'testTag', 'Failed to request ALiYun. Cause: %{public}s', JSON.stringify(err) ?? '');
        askHttpRequest.destroy();
      } else {
        hilog.error(0x0000, 'testTag', 'ask ALiYun success. data: %{public}s', JSON.stringify(data.result));
        let resp: AskResponse = JSON.parse(data.result.toString())
        if (resp.output.task_status == "SUCCEEDED"){
          hilog.error(0x0000, 'testTag', 'SUCCEEDED');
          let resp: SucResponse = JSON.parse(data.result.toString())
          let url = resp.output.results[0].url
          this.imgUrl = url
          this.textAreaEnabled = true
          this.text = ""
        }else{
          setTimeout(()=>{
            this.ask(task_id)
          }, 1000)
        }
        askHttpRequest.destroy()
      }
    })
    // hilog.error(0x0000, 'testTag', 'Timer is end');
    // console.log('Timer is end')
    // askHttpRequest.destroy()
  }

  sendTextMsg(){
    this.textAreaEnabled = false

    let httpRequest = http.createHttp();
    let url = "https://dashscope.aliyuncs.com/api/v1/services/aigc/text2image/image-synthesis"
    httpRequest.request(
      // 请求地址
      url,
      // 请求options: HttpRequestOptions
      {
        // 请求方式
        method: http.RequestMethod.POST,
        // 请求头
        header: {
          "Content-Type": "application/json",
          // 这里的Authorization 就是刚才工作台查看的 API-KEY
          "Authorization": "sk-d3af13a4247e4082b8db7818e8c1e9b8",// 脱敏处理
          "X-DashScope-Async": "enable"
        },
        // 请求体
        extraData: {
          "model": "wanx-v1",
          "input": {
            "prompt": this.text
          }
        }
      }, async (err, data: http.HttpResponse) => {
      if (err) {
        hilog.error(0x0000, 'testTag', 'Failed to request ALiYun. Cause: %{public}s', JSON.stringify(err) ?? '');
        httpRequest.destroy();
      } else {
        hilog.error(0x0000, 'testTag', 'Request ALiYun success. data: %{public}s', JSON.stringify(data.result));
        httpRequest.destroy();
        let resp: Response = JSON.parse(data.result.toString())
        let task_id = resp.output.task_id
        this.ask(task_id)


      }
    })
    this.text = "生成图片中，请等待..."
  }


  build() {
    Column() {
      Row(){
        Image(this.imgUrl)
          .height("90%")
          .width("100%")
      }



      Row() {

        if (1) {
          // Image($r("app.media.ic_use_voice"))
          //   .width(33)
          //   .height(33)
          //   .borderRadius(4)
          //   .margin({ left: 15, right: 15 })
          //   .objectFit(ImageFit.Cover)
          //   .onClick(async () => {
          //     const result = await PermissionUtils.request(["ohos.permission.MICROPHONE"])
          //     if (!result) {
          //       ToastUtils.show("请先授权麦克风权限")
          //     }
          //     this.inputType = WXInputType.voice
          //     this.showFuncBarWithAnim(false)
          //   })

          TextArea({ text: $$this.text, placeholder: '请输入文本', controller: this.controller })
            .placeholderFont({ size: 20, weight: 400 })
            .caretColor(Color.Green)
            .placeholderColor(Color.Grey)
            .layoutWeight(1)
            .padding({ left: 8, right: 8 })
            .fontSize(20)
            .fontColor(Color.Black)
            .focusable(this.textAreaEnabled)
            .borderRadius(8)// 设置stateStyles，解决点击编辑框会变色的问题
            .stateStyles({
              normal: {.backgroundColor(Color.White)
              },
              pressed: {.backgroundColor(Color.White)
              },
              clicked: {.backgroundColor(Color.White)
              },
              focused: {.backgroundColor(Color.White)
              }
            })
          // .onSubmit(() => {
          //   prompt.showToast({ message: this.chatText })
          // })
        }



        Text("发送")
          .fontColor(Color.White)
          .width(65)
          .textAlign(TextAlign.Center)
          .height(36)
          .backgroundColor("#58BE6A")
          .fontSize(18)
          .visibility(this.text.length == 0 ? Visibility.None : Visibility.Visible)
          .borderRadius(6)
          .margin({ left: 10, right: 10 })
          .onClick(async () => {
            if (this.textAreaEnabled)
              this.sendTextMsg()
          })

        // Image($r("app.media.ic_add"))
        //   .width(33)
        //   .height(33)
        //   .borderRadius(4)
        //   .visibility(this.chatText.length == 0 ? Visibility.Visible : Visibility.None)
        //   .margin({ left: 15, right: 8 })
        //   .objectFit(ImageFit.Cover)
        //   .onClick(() => {
        //     if (!this.showFuncBar) {
        //       this.inputType = WXInputType.keyboard
        //     }
        //     this.showFuncBarWithAnim(!this.showFuncBar)
        //   })

      }
      .padding({ top: 10, bottom: 10 })
      .alignItems(VerticalAlign.Bottom)
      .backgroundColor("#f9f9f9")
      .height("10%")

      Divider()
        .vertical(false)
        .color("#f0f0f0")
        .strokeWidth(1)
        .lineCap(LineCapStyle.Round)

      // ChatFunctionBar()
      //   .height(this.funcBarHeight)

    }
    .width("100%")
    .height("100%")
    .backgroundColor("#f1f1f1")
    .padding({ bottom: WindowManager.navBarHeight })
    // .alignItems(VerticalAlign.Bottom)
  }

}
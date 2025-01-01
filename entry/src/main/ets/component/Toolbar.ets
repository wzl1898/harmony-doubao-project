import router from '@ohos.router'
import WindowManager from '../utils/WindowManager'
import { ToastUtils } from '../utils/ToastUtils'

@Preview
@Component
export default struct Toolbar {
  private title: string = "发现"
  private backSrc: string | PixelMap | Resource = $r("app.media.ic_back_black")
  private subTitle: string = "更多"
  private subIconSrc: string | PixelMap | Resource = $r("app.media.ic_toolbar_more")

  u_id:number = 0
  u_name:string = ''
  c_id:number = 0
  c_name:string = ''
  c_des:string = ''

  build() {
    Column() {
      Row() {
        Image(this.backSrc)
          .width(22)
          .height(22)
          .margin({ left: 15 })
          .onClick(() => {
            //AlertDialog.show({ message: 'tool bar userid: ' + this.u_id +',  name:'+ this.u_name})

            // router.back()
            router.pushUrl({
              url: 'pages/Index',
              params: {
                u_id: this.u_id,
                u_name: this.u_name,
                c_id: this.c_id,
                c_name: this.c_name,
                c_des: this.c_des
              }
            })
          })

        Text(this.title)
          .fontColor(Color.Black)
          .fontSize(19)
          .fontWeight(500)

        if (this.subIconSrc === null) {
          Text("")
            .fontColor(Color.Black)
            .fontSize(16)
            .margin({ right: 15 })
            .fontWeight(400)
            // .onClick(unDevTip)
        } else {
          Text("")
            .fontColor(Color.Black)
            .fontSize(16)
            .margin({ right: 15 })
            .fontWeight(400)
            // .onClick(unDevTip)
        }

      }
      .height(53)
      .width("100%")
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .expandSafeArea([SafeAreaType.KEYBOARD])
    .backgroundColor("#f1f1f1")
    .zIndex(999)
    .padding({ top: WindowManager.statusBarHeight })
  }
}

const unDevTip = () => {
  ToastUtils.show("功能正在开发中...")
}
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

  userId:number = 0
  userName:string = ''
  c_id:number = 0
  name:string = ''
  des:string = ''

  build() {
    Column() {
      Row() {
        Image(this.backSrc)
          .width(22)
          .height(22)
          .margin({ left: 15 })
          .onClick(() => {
            // router.back()
            router.pushUrl({
              url: 'pages/Index',
              params: {}
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
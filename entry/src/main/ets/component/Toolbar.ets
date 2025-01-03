import router from '@ohos.router'
import WindowManager from '../utils/WindowManager'
import { ToastUtils } from '../utils/ToastUtils'
import promptAction from '@ohos.promptAction';

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
  @Link c_name:string
  @Link c_des:string
  @Link m_id:number

  modelIndex:string[] =[
    '通义千问',
    '质谱清言'
  ]

  build() {
    Column() {
      Row() {
        Image(this.backSrc)
          .width(22)
          .height(22)
          .margin({ left: 15 })
          .onClick(() => {
            //AlertDialog.show({ message: 'tool bar userid: ' + this.u_id +',  name:'+ this.u_name})
            // AlertDialog.show({ message: 'tool bar c_name: ' + this.c_name +',  c_des:'+ this.c_des})

            // router.back()
            router.pushUrl({
              url: 'pages/Index',
              params: {
                u_id: this.u_id,
                u_name: this.u_name,
                c_id: this.c_id,
                c_name: this.c_name,
                c_des: this.c_des,
                m_id: this.m_id
              }
            })
          })

        //Text((this.c_name == '')? '新会话':this.c_name)
        Text('当前模型：'+this.modelIndex[this.m_id])
          .fontColor(Color.Black)
          .fontSize(19)
          .fontWeight(500)

        Button('切换模型',{type:ButtonType.Capsule})
          .fontColor(Color.Black)
          .fontSize(15)
          .backgroundColor(Color.Transparent)
          .fontWeight(500)
          .onClick(() => {
            promptAction.showActionMenu({
              title: "选择模型",
              buttons: [
                {
                  text: this.modelIndex[0],
                  color: "#000"
                },
                {
                  text: this.modelIndex[1],
                  color: "#000"
                }
              ]
            })
              .then(data => {
                AlertDialog.show({ message: "已为您切换为：" + this.modelIndex[data.index]});
                this.m_id=data.index
              }).catch((err: Error) => {
              AlertDialog.show({ message: '取消切换'});
            })
          })


        // if (this.subIconSrc === null) {
        //   Text("")
        //     .fontColor(Color.Black)
        //     .fontSize(16)
        //     .margin({ right: 15 })
        //     .fontWeight(400)
        //     // .onClick(unDevTip)
        // } else {
        //   Text("")
        //     .fontColor(Color.Black)
        //     .fontSize(16)
        //     .margin({ right: 15 })
        //     .fontWeight(400)
        //     // .onClick(unDevTip)
        // }

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
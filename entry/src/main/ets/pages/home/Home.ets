import router from '@ohos.router'
import WechatToolbar from '../../component/WechatToolbar'

import { relationalStore, ValuesBucket } from '@kit.ArkData'
import ListRecordItem from '../../component/ListRecordList'

interface Recording extends ValuesBucket {
  id: number | null // 新增时设置 id 为空值 null，用于自增 id
  u_id: number
  //m_id: number
  name: string
  des: string
  time: string
  //url: Resource
}

@Preview
@Component
export default struct Home {
  aboutToAppear(): void {
    //TODO: go through all ChatMsg From database and create all ChatWindow(ChatItemData)
  }
  // @State chatList: ChatItemData[] = [
  //   {
  //     headSrc: $r("app.media.ic_user_head2"),
  //     nickname: "老婆",
  //     content: "今晚给你做了好吃的，早点下班哦😊",
  //     time: "17:21"
  //   },
  //   {
  //     headSrc: $r("app.media.ic_user_head3"),
  //     nickname: "游戏好友",
  //     content: "我今天又拿了五杀，牛逼不？",
  //     time: "15:38"
  //   },
  //   {
  //     headSrc: $r("app.media.ic_user_head4"),
  //     nickname: "同事小李",
  //     content: "领导，报给写好了，请过目",
  //     time: "14:12"
  //   }
  // ]
  @State recodeList: Recording[] = [
    {
      id: 1,
      u_id: 1,
      name: 'test',
      des: 'string',
      time: '现在'
    }
  ]

  build() {
    Column() {
      WechatToolbar({ title: "豆包" })

      List() {
        ForEach(this.recodeList, (item: Recording, index: number) => {
          ListItem() {
            ListRecordItem({ data: item })
          }
          .onClick(() => {
            router.pushUrl({
              url: 'pages/chat/ChatPage',
              params: { c_id: item.id }
            })
          })
        })
        ListItem() {
          Divider().color('#0000').strokeWidth(0)
        }
      }
      .divider({
        strokeWidth: 0.8,
        color: '#f0f0f0',
        startMargin: 90,
        endMargin: 0
      }) // 每行之间的分界线
      .backgroundColor(Color.White)
      .width("100%")
      .height("100%")

      // Button('Ok', { type: ButtonType.Normal, stateEffect: true })
      //   .height('20%')
      //   .width('40%')
      //   .onClick(() => {
      //     // this.test_api("hello?")
      //   })
    }
    .width("100%")
    .height("100%")
    .backgroundColor("#f0f0f0")
  }


}
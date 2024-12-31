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

    }
    .width("100%")
    .height("100%")
    .backgroundColor("#f0f0f0")
  }


}
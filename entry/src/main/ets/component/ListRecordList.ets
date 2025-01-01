@Preview
@Component
export default struct ListRecordItem {
  data: Chat = {
    id: 0,
    u_id: 0,
    //m_id: number,
    name: "",
    des: "",
    time: 0,
    //url: string,
  }

  build() {
    Row() {
      Column() {
        Text(this.data.name)
          .fontColor(Color.Black)
          .fontSize(19)
          .fontWeight(500)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width("100%")

        Text(this.data.des)
          .fontColor(Color.Gray)
          .fontSize(15)
          .width("100%")
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 7 })

        Button("删除", { type: ButtonType.Capsule })
          .width("20vp")
          .height("20vp")
          .fontSize($r('app.float.normal_text_size'))
          .fontColor($r('app.color.setting_button_font'))
          .fontWeight(FontWeight.Medium)
          .backgroundColor($r('app.color.setting_button_background'))
          .margin({ bottom: $r('app.float.setting_button_bottom')})
          .onClick(() => {
            //TODO: delete conversation
          })
      }.layoutWeight(1)
      .margin({ right: 30 })
      .alignItems(HorizontalAlign.Start)

      Text(this.data.time?.toString())
        .fontColor(Color.Gray)
        .fontSize(14)
        .alignSelf(ItemAlign.Start)
        .margin({ top: 15, right: 6 })
    }
    .width("100%")
    .height(80)
    .backgroundColor(Color.White)
    .padding({ left: 15, right: 15 })
  }
}
interface Chat {
  id?: number | null
  u_id?: number
  //m_id?: number
  name?: string
  des?: string
  time?: number
  //url?: Resource
}

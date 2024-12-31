@Preview
@Component
export default struct ListRecordItem {
  data: Recording = {
    id: 0,
    u_id: 0,
    //m_id: number,
    name: "",
    des: "",
    time: "",
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
      }.layoutWeight(1)
      .margin({ right: 30 })
      .alignItems(HorizontalAlign.Start)

      Text(this.data.time)
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
interface Recording {
  id?: number | null
  u_id?: number
  //m_id?: number
  name?: string
  des?: string
  time?: string
  //url?: Resource
}

import { relationalStore, ValuesBucket } from '@kit.ArkData'
import { router } from '@kit.ArkUI'

interface item extends ValuesBucket {
  id: number | null
}

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
  tableName: string = 'chat'
  sqlCreate: string = `CREATE TABLE IF NOT EXISTS ${this.tableName} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        u_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        des TEXT,
        time INTEGER NOT NULL
      )`
  // 操作数据库的管理对象
  store: relationalStore.RdbStore | null = null

  async getStoreInstance() {
    // 如果已经存在，直接返回
    if (this.store) {
      return this.store
    }
    // 获取操作数据库的管理对象(如果数据库文件不存在，会自动创建数据库文件)
    this.store = await relationalStore.getRdbStore(getContext(), {
      name: 'final.db', // 数据库文件名
      securityLevel: relationalStore.SecurityLevel.S1, // 数据库安全级别
    })
    // 执行创建表的语句 execute 执行
    this.store.executeSql(this.sqlCreate)
    // 返回 store 对象
    return this.store
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
          .onClick(async () => {
            //TODO: delete conversation
            // 获取操作数据库对象
            const store = await this.getStoreInstance()
            const predicates = new relationalStore.RdbPredicates(this.tableName)
            predicates.equalTo('id', this.data.id)
            const affectedRows = await store.delete(predicates)
            if (affectedRows > 0) AlertDialog.show({ message: '删除成功' })
            // 能删除 但是ui不能马上更新
          })
      }.layoutWeight(1)
      .margin({ right: 30 })
      .alignItems(HorizontalAlign.Start)

      Text(new Date(this.data.time).toString())
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

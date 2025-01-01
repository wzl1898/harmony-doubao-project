import router from '@ohos.router'
import WechatToolbar from '../../component/WechatToolbar'

import { relationalStore, ValuesBucket } from '@kit.ArkData'
import ListRecordItem from '../../component/ListRecordList'

interface Chat extends ValuesBucket {
  id: number | null // 新增时设置 id 为空值 null，用于自增 id
  u_id: number
  //m_id: number
  name: string
  des: string
  time: number
  //url: Resource
}

@Preview
@Component
export default struct Home {
  u_id :number = 0
  u_name :string = ''

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

  async aboutToAppear(): Promise<void> {
    //TODO: go through all ChatMsg From database and create all ChatWindow(ChatItemData)
    const store = await this.getStoreInstance()
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    // predicates.orderByDesc('id') // 倒序(由大到小，常用于排序)
    predicates.orderByAsc('id')   // 正序(小到大，常用于排序)
    // predicates.equalTo('id', 1)    // 等于(常用于详情页)
    // predicates.in('id', [1, 3, 5]) // 查找多项(常用批量删除)
    // predicates.like('title', '%哈%') //  模糊匹配(常用于搜索)
    // 还有很多...
    // predicates.greaterThan('id', 3)
    // resultSet 结果集
    const resultSet = await store.query(predicates)
    // 准备一个数组，用于存储数据库提取的数据
    const list: Chat [] = []
    // resultSet.goToNextRow()   指针移动到下一行
    while (resultSet.goToNextRow()) {
      // 移动指针的时候提取数据，按列下标提取数据
      list.push({
        // resultSet.getColumnIndex()        根据列名称获取下标(索引)
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        u_id: resultSet.getLong(resultSet.getColumnIndex('u_id')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        des: resultSet.getString(resultSet.getColumnIndex('des')),
        time: resultSet.getLong(resultSet.getColumnIndex('time')),
      })
    }
    list.forEach(element => {
      this.chatList.push({
        id: element.id,
        u_id: element.u_id,
        name: element.name,
        des: element.des,
        time: element.time
      })
    });
  }

  @State chatList: Chat[] = [
    {
      id: 1,
      u_id: 1,
      name: 'test',
      des: 'string',
      time: 0
    }
  ]

  build() {
    Column() {
      WechatToolbar({ title: "豆包" })

      List() {
        ForEach(this.chatList, (item: Chat, index: number) => {
          ListItem() {
            ListRecordItem({ data: item })
          }
          .onClick(() => {
            //AlertDialog.show({ message: 'home userid: ' + this.u_id +',  name:'+ this.u_name})

            router.pushUrl({
              url: 'pages/chat/ChatPage',
              params: {
                c_id: item.id,
                u_id: this.u_id,
                u_name: this.u_name
              }
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
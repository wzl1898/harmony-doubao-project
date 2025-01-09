import { relationalStore, ValuesBucket } from '@kit.ArkData'
import router from '@ohos.router'
import WindowManager from '../../utils/WindowManager'


interface Prompt extends ValuesBucket {
  id: number | null // 新增时设置 id 为空值 null，用于自增 id
  u_id: number
  text: string
}

@Entry
@Component
struct PromptPage {
  private backSrc: string | PixelMap | Resource = $r("app.media.ic_back_black")
  u_id = (router.getParams() as Record<string, number>)['u_id']
  u_name = (router.getParams() as Record<string, string>)['u_name']
  c_id = (router.getParams() as Record<string, number>)['c_id']
  m_id = (router.getParams() as Record<string, number>)['m_id']
  c_name = (router.getParams() as Record<string, string>)['c_name']
  c_des = (router.getParams() as Record<string, string>)['c_des']
  @State
  promptList: Prompt[] = []

  tableName: string = 'prompt'
  sqlCreate: string = `CREATE TABLE IF NOT EXISTS ${this.tableName} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        u_id INTEGER NOT NULL,
        text TEXT NOT NULL
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

  async addNew() {
    // 获取操作数据库的对象
    const store = await this.getStoreInstance()

    // 添加一条数据
    const id = await store.insert(this.tableName, {
      id: null, // 新增时设置 id 为空值 null，用于自增 id
      u_id: this.u_id,
      text: this.answer
    } as Prompt)
    // AlertDialog.show({message: this.answer})

    this.promptList.push({
      id: id,
      u_id: this.u_id,
      text: this.answer
    })
  }

  async aboutToAppear(): Promise<void> {
    const store = await this.getStoreInstance()
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    // predicates.orderByDesc('id') // 倒序(由大到小，常用于排序)
    predicates.orderByAsc('id')   // 正序(小到大，常用于排序)
    predicates.equalTo('u_id', this.u_id)    // 等于(常用于详情页)
    // predicates.in('id', [1, 3, 5]) // 查找多项(常用批量删除)
    // predicates.like('title', '%哈%') //  模糊匹配(常用于搜索)
    // 还有很多...
    // predicates.greaterThan('id', 3)
    // resultSet 结果集
    const resultSet = await store.query(predicates)
    // 准备一个数组，用于存储数据库提取的数据
    const list: Prompt [] = []
    // resultSet.goToNextRow()   指针移动到下一行
    while (resultSet.goToNextRow()) {
      // 移动指针的时候提取数据，按列下标提取数据
      list.push({
        // resultSet.getColumnIndex()        根据列名称获取下标(索引)
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        u_id: resultSet.getLong(resultSet.getColumnIndex('u_id')),
        text: resultSet.getString(resultSet.getColumnIndex('text'))
      })
    }
    list.forEach(element => {
      this.promptList.push({
        id: element.id,
        u_id: element.u_id,
        text: element.text
      })
      // AlertDialog.show({message: element.text})
    });
    // AlertDialog.show({message: JSON.stringify(list, null, 2)})
  }

  answer: string = '?'
  controller: CustomDialogController = new CustomDialogController({
    builder: TextInputDialog({
      confirm: (value) => {
        this.answer = value;
        this.addNew()
      }
    }),
    alignment: DialogAlignment.Bottom,
    offset: { dx: 0, dy: -30 }
  })

  @Builder DeleteButton(id: number, index:number){
    Button('删除',{ type: ButtonType.Normal}).onClick(async () => {
      const store = await this.getStoreInstance()
      const predicates = new relationalStore.RdbPredicates(this.tableName)
      predicates.equalTo('id', id)
      const affectedRows = await store.delete(predicates)
      this.promptList.splice(index, 1)
    })
      .width(80)
      .backgroundColor(Color.Red)
      .borderRadius(0)
      .height("100%")
  }

  build() {
    Column(){
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
                params: {
                  u_id: this.u_id,
                  u_name: this.u_name,
                  c_id: 0,
                  c_des: '',
                  c_name: '',
                }
              })
            })
            // .alignSelf(ItemAlign.Start)


          Text('提示词管理')
            .fontColor(Color.Black)
            .fontSize(19)
            .fontWeight(500)
            // .alignSelf(ItemAlign.Center)
            // .textAlign(TextAlign.Center)
          Text('')
            .fontColor(Color.Black)
            .fontSize(19)
            .fontWeight(500)
            .alignSelf(ItemAlign.Center)
        }
        .height(53)
        .width("100%")
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .expandSafeArea([SafeAreaType.KEYBOARD])
      .backgroundColor("#f1f1f1")
      .zIndex(999)
      .padding({ top: WindowManager.statusBarHeight })

      Button('新建').onClick(() => {
        // todo 新建太快了
        this.controller.open()
        // this.addNew()
      })
        .margin(10)
        .width("30%")
        .fontSize(25)
      // List(){
      //   ListItem(){
      //     Text("this.promptList[0].text")
      //       .fontColor(Color.Black)
      //       .fontSize(19)
      //       .fontWeight(500)
      //   }
      // }
      List() {
        ForEach(this.promptList, (item: Prompt, index: number) => {
          ListItem(){
            Row(){
              Text(item.text)
                .fontColor(Color.Black)
                .fontSize(19)
                .fontWeight(500)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .width("100%")
                .padding(10)



            }.height(60)
          }
          .swipeAction({ end: this.DeleteButton(item.id, index) })
          .backgroundColor("#fffafafa")
        })
      }
        .divider({
          strokeWidth: 0.8,
          color: '#f0f0f0',
          startMargin: 90,
          endMargin: 0
        }) // 每行之间的分界线
    }
  }
}



@CustomDialog
struct TextInputDialog {
  controller: CustomDialogController = new CustomDialogController({ builder: TextInputDialog() })
  confirm?: (value: string) => void;
  value: string = '';

  build() {
    Column({ space: 20 }) {
      Text('请输入你的提示词')
      TextInput({ placeholder: '请输入提示词' })
        .onChange((value) => {
          this.value = value;
        })
      Row({ space: 50 }) {
        Button('取消')
          .onClick(() => {
            this.controller.close();
          })
        Button('确认').onClick(() => {
          if (this.confirm) this.confirm(this.value);
          this.controller.close();
        })
      }
    }.padding(20)
  }
}
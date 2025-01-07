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

  onPageShow(): void {
    AlertDialog.show({ message: '1'})
  }

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
              params: {
              }
            })
          })

        Text('提示词管理')
          .fontColor(Color.Black)
          .fontSize(19)
          .fontWeight(500)
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
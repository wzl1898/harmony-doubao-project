import router from '@ohos.router'
import WindowManager from '../utils/WindowManager'
import { ToastUtils } from '../utils/ToastUtils'
import promptAction from '@ohos.promptAction';
import hilog from '@ohos.hilog';
import { beforeEach } from '@ohos/hypium';
import { JSON } from '@kit.ArkTS';
import { relationalStore, ValuesBucket} from '@kit.ArkData'
interface aiModel {
  url: string
  model: string
  auth: string
  // data: object
}
interface btn{
  text: string
  color: string
}

@Preview
@Component
export default struct Toolbar {
  private title: string = "发现"
  private backSrc: string | PixelMap | Resource = $r("app.media.ic_back_black")
  private subTitle: string = "更多"
  private subIconSrc: string | PixelMap | Resource = $r("app.media.ic_toolbar_more")
  store1: relationalStore.RdbStore | null = null
  u_id:number = 0
  u_name:string = ''
  c_id:number = 0
  @Link c_name:string
  @Link c_des:string
  @Link m_id:number
  // u_name = (router.getParams() as Record<string, string>)['u_name']
  ais :aiModel[] = (router.getParams() as Record<string, aiModel[]>)['ais']
  store: relationalStore.RdbStore | null = null
  @State modelIndex:string[] =[
    '通义千问',
    '质谱清言',
    '百度千帆',
    "Kimi"
  ]
  tableName1: string = 'BigModel'
  sqlCreate: string = `CREATE TABLE IF NOT EXISTS ${this.tableName1} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        u_id INTEGER NOT NULL,
        url TEXT NOT NULL,
        modelname TEXT NOT NULL,
        auth TEXT NOT NULL
      )`
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
  async aboutToAppear() {
    // AlertDialog.show({message: JSON.stringify(this.ais)})
    // this.ais.forEach(element=>{
    //   this.modelIndex.push(element.model)
    // })
    const store = await this.getStoreInstance()
    const predicates1 = new relationalStore.RdbPredicates(this.tableName1)
    // predicates.orderByDesc('id') // 倒序(由大到小，常用于排序)
    predicates1.orderByAsc('id')   // 正序(小到大，常用于排序)
    predicates1.equalTo('u_id', this.u_id)    // 等于(常用于详情页)
    // predicates.in('id', [1, 3, 5]) // 查找多项(常用批量删除)
    // predicates.like('title', '%哈%') //  模糊匹配(常用于搜索)
    // 还有很多...
    // predicates.greaterThan('id', 3)
    // resultSet 结果集
    const resultSet1 = await store.query(predicates1)
    // 准备一个数组，用于存储数据库提取的数据
    const list1: aiModel [] = []
    // hilog.error(0x0000, 'testTag', '4');
    // resultSet.goToNextRow()   指针移动到下一行
    while (resultSet1.goToNextRow()) {
      // 移动指针的时候提取数据，按列下标提取数据
      list1.push({
        // resultSet.getColumnIndex()        根据列名称获取下标(索引)
        // id: resultSet1.getLong(resultSet1.getColumnIndex('id')),
        // u_id: resultSet1.getLong(resultSet1.getColumnIndex('u_id')),
        url: resultSet1.getString(resultSet1.getColumnIndex('url')),
        model: resultSet1.getString(resultSet1.getColumnIndex('modelname')),
        auth: resultSet1.getString(resultSet1.getColumnIndex('auth'))
      })
    }
    // hilog.error(0x0000, 'testTag', '5');
    list1.forEach(element => {
      this.ais.push({
        url: element.url,
        model: element.model,
        auth: element.auth
      })
      // AlertDialog.show({message: element.text})
    });
    hilog.error(0x0000, 'testTag', '  1        list1.length: %{public}s', this.ais.length.toString());
  }
  btns: ButtonType[] = []

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
            // this.ais.forEach(element=>{
            //   // this.btns.push({
            //   //   text: element.model,
            //   //   color: "#000"
            //   // })
            //   // (Button)this.btns[0]
            // })
            promptAction.showActionMenu({
              title: "选择模型",
              buttons:
              [
                {
                  text: this.modelIndex[0],
                  color: "#000"
                },
                {
                  text: this.modelIndex[1],
                  color: "#000"
                },
                {
                  text: this.modelIndex[2],
                  color: "#000"
                },
                {
                  text: this.modelIndex[3],
                  color: "#000"
                },
                // {
                //   text: this.modelIndex[4],
                //   color: "#000"
                // },
                // {
                //   text: 4 < this.modelIndex.length ? this.modelIndex[4] : "",
                //   color: "#000"
                // },
                // {
                //   text: 5 < this.modelIndex.length ? this.modelIndex[5] : "",
                //   color: "#000"
                // },
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
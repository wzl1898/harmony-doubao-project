import home from './home/Home'
import router from '@ohos.router'
import contact from './contact/Contact'
import discovery from './discovery/Discovery'
import Setting from './mine/Setting'
import WindowManager from '../utils/WindowManager'

import { relationalStore, ValuesBucket } from '@kit.ArkData'

interface Chat extends ValuesBucket {
  id: number | null // 新增时设置 id 为空值 null，用于自增 id
  u_id: number
  //m_id: number
  name: string
  des: string
  time: number
  //url: Resource
}

@Entry
@Component
struct Index {
  @State private currentIndex: number = 0
  private tabController: TabsController = new TabsController()
  private tabTitles: string[] = ['主页','新建对话', '我的']
  private tabTextColors: string[] = ["#040404", "#57be6a"]
  private tabTipCounts: number[] = [0]

  @State userId: number = 0

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

  async addNewChat() {
    // 获取操作数据库的对象
    const store = await this.getStoreInstance()
    // 添加一条数据
    const id = await store.insert(this.tableName, {
      id: null, // 新增时设置 id 为空值 null，用于自增 id
      u_id: 1,
      name: '新会话',
      des: '',
      time: Date.now()
    } as Chat)
    AlertDialog.show({ message: '新增数组成功，数据的id为：' + id })
  }

  build() {
    Column() {
      Tabs({ barPosition: BarPosition.End, controller: this.tabController }) {
        // 微信（首页）
        TabContent() {
          home()
        }
        .tabBar(this.createTabMenu(0))

        // // 通讯录
        TabContent() {
          // contact()
        }
        .tabBar(this.createTabMenu(1))
        //
        // 发现
        // TabContent() {
        //   discovery()
        // }
        // .tabBar(this.createTabMenu(2))

        // 我的
        TabContent() {
          Setting()
        }
        .tabBar(this.createTabMenu(2))
      }
      .width("100%")
      .height("100%")
      .barHeight(85)
      .backgroundColor("#f4f4f4")
      .vertical(false)
      .layoutWeight(1)
      .padding({ bottom: WindowManager.navBarHeight })
      .onChange((index: number) => {
        if (index == 1) {
          router.pushUrl({
            url: 'pages/chat/ChatPage',
            params: {}
          })
        }
        this.currentIndex = index

      })

    }
    .width('100%')
    .height('100%')
    //   Button("新建对话")
    //     .onClick(()=>{
    //
    //       // console.log("1")
    //     })
    }

  @Builder
  createTabMenu(index: number) {

    Stack({ alignContent: Alignment.Center }) {

      // 数字右标
      Badge({
        count: this.tabTipCounts[index],
        maxCount: 99,
        position: BadgePosition.RightTop,
        style: {
          color: 0xFFFFFF,
          fontSize: 13,
          badgeSize: 30,
          badgeColor: Color.Red
        }
      }) {
        Column() {
          /**
           * Contain  图片按比例缩放以适应容器边界，可能会出现空白区域
           Cover  图片按比例缩放以填充容器，可能会被裁剪
           Auto  默认值，图片大小保持原始大小
           Fill  图片拉伸以填充容器，可能会出现失真
           ScaleDown  图片按比例缩小以适应容器边界，但是不会放大图片
           None  不进行任何缩放操作，即使图片溢出容器也不会被裁剪或缩放
           */
          // icon图标
          Image(this.currentIndex === index ? `/images/main_page_index${index}_pre.png` :
            `/images/main_page_index${index}_nor.png`)
            .width(29.714)
            .height(26)
            .objectFit(ImageFit.Fill)
            .margin({ bottom: 3 })
            .onClick(async ()=>{
              //TODO: create and save a init ChatContentItemData, and pushurl to the chatpage
              let url_str = ''
              if (this.currentIndex == 1){
                //this.addNewChat()
                url_str = 'pages/chat/ChatPage'
              }else if (this.currentIndex == 0){
                url_str = 'pages/Index'
              }else if (this.currentIndex == 2){
                url_str = 'pages/Mine'
              }

            })
          // 文本
          Text(this.tabTitles[index])
            .fontColor("#ff2922c1")
            .fontSize(10)
            .onClick(()=>{
              //TODO: create and save a init ChatContentItemData, and pushurl to the chatpage
              let url_str = ''
              if (this.currentIndex == 1){
                //this.addNewChat()
                url_str = 'pages/chat/ChatPage'
              }else if (this.currentIndex == 0){
                url_str = 'pages/Index'
              }else if (this.currentIndex == 2){
                url_str = 'pages/Mine'
              }
              if (this.currentIndex == 1) {
                router.pushUrl({
                  url: url_str,
                  params: {}
                })
              }
            })
        }
        .backgroundColor(Color.Transparent)
        .justifyContent(FlexAlign.Center)
      }
      // .width(42)
      .width(42)
      // .height(40)
      .height(30)
    }
    .width("100%")
    .height("100%")
  }
}
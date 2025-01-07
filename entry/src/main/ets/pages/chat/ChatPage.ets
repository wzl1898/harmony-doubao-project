import router from '@ohos.router';
import Toolbar from '../../component/Toolbar';
import ListChatContentLeftItem from '../../component/ListChatContentLeftItem';
import ListChatContentRightItem from '../../component/ListChatContentRightItem';
import window from '@ohos.window';
import WindowManager from '../../utils/WindowManager';
import ChatFunctionBar from './ChatFuntionBar';
import { ChatContentItemData } from './ChatContentItemData';
import ChatPageParam from './ChatPageParam';
import { ToastUtils } from '../../utils/ToastUtils';
import SpeechRecognizerManager from '../../utils/SpeechRecognizerManager';
import { AudioCaptureManager, RecordFile } from '../../utils/AudioCapturerManager';
import { componentUtils } from '@kit.ArkUI';
import { vibrator } from '@kit.SensorServiceKit';
import { PermissionUtils } from '../../utils/PermissionUtils';
import http from '@ohos.net.http';
import hilog from '@ohos.hilog';
// import { JSON } from '@kit.ArkTS';
import ALiYunResponse from "../../utils/ALiYunResponse"
import { relationalStore, ValuesBucket} from '@kit.ArkData'
import { it } from '@ohos/hypium';

enum WXInputType {
  /**
   * 语音输入
   */
  voice = 0,
  /**
   * 文本输入
   */
  keyboard = 1
}

enum MessageType {
  /**
   * 声音
   */
  voice = 0,
  /**
   * 文本
   */
  text = 1
}

// 消息
class ChatMessage {
  /**
   * 消息类型：【录音、文本】
   */
  type: MessageType
  /**
   * 内容 [录音-文件路径，文本-内容]
   */
  content: string
  /**
   * 消息时间
   */
  time: string
  /**
   * 声音的持续时间 单位毫秒
   */
  duration?: number
  /**
   * 录音转的文字
   */
  translateText?: string
  /**
   * 是否显示转好的文字
   */
  isShowTranslateText: boolean = false

  constructor(type: MessageType, content: string, duration?: number, translateText?: string) {
    this.type = type
    this.content = content
    const date = new Date()
    this.time = `${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`
    this.duration = duration
    this.translateText = translateText
  }
}

enum PressCancelVoicePostText {
  // 没有长按
  none = 0,
  //   长按 没有选中“取消发送”或者"转语音"
  pressing = 1,
  //   取消发送
  cancelVoice = 2,
  //   转文字
  postText = 3
}


interface ChatContent extends ValuesBucket {
  id: number | null // 新增时设置 id 为空值 null，用于自增 id
  c_id: number
  msg: string
  self: number
}

/**
 * 长按时，手指的坐标
 */
interface ScreenOffset {
  x: number
  y: number
  width: number
  height: number
}

@Entry
@Component
export default struct ChatPage {
  private name?: string = "微信"
  private controller: TextAreaController = new TextAreaController()
  private scroller: Scroller = new Scroller()
  @State private chatText: string = ''
  private keyboardHeight: number = 0
  @State private funcBarHeight: number = 0;
  @State private showFuncBar: boolean = false;
  @State chatType: string = ''

  tableName: string = 'chat_content'
  sqlCreate: string = `CREATE TABLE IF NOT EXISTS ${this.tableName} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        c_id INTEAGE NOT NULL,
        msg TEXT NOT NULL,
        self INTEGAER
      )`
  // 操作数据库的管理对象
  store: relationalStore.RdbStore | null = null

  @State c_name:string = ''
  @State c_des:string = ''

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

  @State private dataList: ChatContentItemData[] = [ ]
  // 输入框内容
  @State
  textValue: string = ""
  // 输入状态 语音或者文字
  @State
  inputType: WXInputType = WXInputType.keyboard
  // 语音识别的文字
  @State
  voiceToText: string = ""
  // 消息
  @State
  chatList: ChatMessage[] = []
  // 按住说话 录音模态
  @State
  showTalkContainer: boolean = false
  // 长按状态
  @State
  pressCancelVoicePostText: PressCancelVoicePostText = PressCancelVoicePostText.none
  //用来配置 CanvasRenderingContext2D 对象的参数，包括是否开启抗锯齿，true表明开启抗锯齿。
  settings: RenderingContextSettings = new RenderingContextSettings(true)
  //用来创建CanvasRenderingContext2D对象，通过在canvas中调用CanvasRenderingContext2D对象来绘制。
  context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  // 声明波纹定时器id
  voiceTimeId: number = -1
  // 底部录音气泡的坐标
  bubbleScreenOffset: ScreenOffset = {
    x: 0,
    y: 0,
    width: 0,
    height: 0
  }
  // 录音文件名称
  recordFileName: string = ""
  // 发送文本消息

  // 按住说话 持续触发
  onPressTalk = async (event: TouchEvent) => {
    if (event.type === TouchType.Down) {
      // 手指按下时触发
      this.pressCancelVoicePostText = PressCancelVoicePostText.pressing
      // 按下
      this.showTalkContainer = true
      // 震动反馈
      this.startVibration()

      //  开始录音
      this.onStartRecord()

      // 实时语音识别
      this.onStartSpeechRecognize()

    } else if (event.type === TouchType.Move) {
      // 手指移动时持续触发
      this.pressCancelVoicePostText = PressCancelVoicePostText.pressing
      // 获取当前手指的坐标
      const x = event.touches[0].displayX
      const y = event.touches[0].displayY
      // 判断是否碰到了 “X”
      let isTouchX = x <= this.bubbleScreenOffset.width / 2 && y < this.bubbleScreenOffset.y
      // 判断是否碰到了 "文"
      let isTouchText = x > this.bubbleScreenOffset.width / 2 && y < this.bubbleScreenOffset.y
      if (isTouchX) {
        // 取消发送
        this.pressCancelVoicePostText = PressCancelVoicePostText.cancelVoice
      } else if (isTouchText) {
        // 转换文字
        this.pressCancelVoicePostText = PressCancelVoicePostText.postText
      }
    } else if (event.type === TouchType.Up) {
      // 松开手
      this.showTalkContainer = false
      // 停止录音 res 为录音文件信息，包括录音路径、时长等信息
      const res = await this.stopRecord()
      // 结束AI语音识别
      SpeechRecognizerManager.release()

      if (this.pressCancelVoicePostText === PressCancelVoicePostText.postText) {
        // 转换文字
        this.postText()
      } else if (this.pressCancelVoicePostText === PressCancelVoicePostText.cancelVoice) {
        // 取消发送
        this.voiceToText = ''
      } else {
        // 发送录音
        this.postVoice(res)
      }
    }
  }

  @State c_id: number = (router.getParams() as Record<string,number>) ['c_id'];
  @State u_id: number = (router.getParams() as Record<string,number>) ['u_id'];
  @State m_id: number = (router.getParams() as Record<string,number>) ['m_id'];
  @State u_name: string = (router.getParams() as Record<string,string>) ['u_name'];
  async aboutToAppear() {
    //AlertDialog.show({ message: 'chat page userid: ' + this.u_id +',  name:'+ this.u_name})

    // this.name = (router.getParams() as ChatPageParam).name
    this.name = "豆包"
    await window.getLastWindow(getContext(this)).then(currentWindow => {
      currentWindow.on('keyboardHeightChange', (height) => {
        this.keyboardHeight = height;
      })
    })
    //TODO: load all history chat message to datalist from database
    const store = await this.getStoreInstance()
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    // predicates.orderByDesc('id') // 倒序(由大到小，常用于排序)
    predicates.orderByAsc('id')   // 正序(小到大，常用于排序)
    predicates.equalTo('c_id', this.c_id)    // 等于(常用于详情页)
    // predicates.in('id', [1, 3, 5]) // 查找多项(常用批量删除)
    // predicates.like('title', '%哈%') //  模糊匹配(常用于搜索)
    // 还有很多...
    // predicates.greaterThan('id', 3)
    // resultSet 结果集
    const resultSet = await store.query(predicates)
    // 准备一个数组，用于存储数据库提取的数据
    const list: ChatContent [] = []
    // resultSet.goToNextRow()   指针移动到下一行
    while (resultSet.goToNextRow()) {
      // 移动指针的时候提取数据，按列下标提取数据
      list.push({
        // resultSet.getColumnIndex()        根据列名称获取下标(索引)
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        c_id: resultSet.getLong(resultSet.getColumnIndex('c_id')),
        msg: resultSet.getString(resultSet.getColumnIndex('msg')),
        self: resultSet.getLong(resultSet.getColumnIndex('self')),
      })
    }
    list.forEach(element => {
      this.dataList.push({
        name: "鲁班",
        msgType: 0,
        self: (element.self == 1),
        msg: element.msg,
      })
    },
    );

    this.c_name=(this.dataList.length > 0 ) ? this.dataList[0].msg:''
    this.c_des= (this.dataList.length > 0 ) ? this.dataList[1].msg:''
    this.scroller.scrollToIndex(this.dataList.length)
  }

  onBackPress() {
    return this.keyboardHeight > 0
  }

  // 开始录音
  onStartRecord = () => {
    // 文件名  唯一
    this.recordFileName = Date.now().toString()
    AudioCaptureManager.startRecord(this.recordFileName)
  }
  // 结束录音
  stopRecord = async () => {
    // res 记录录音文件的路径、时长等信息  这里返回是为了实现 发送录音消息
    const res = await AudioCaptureManager.stopRecord()
    return res
  }
  // 生成声音消息
  postVoice = (res: RecordFile) => {
    // 录音时长  录音结束时间-开始录音时间
    const duration = Math.ceil((res.endRecordTime - res.startRecordTime) / 1000)
    //   生成消息文件
    const voiceChat = new ChatMessage(MessageType.voice, res.recordFilePath, duration)
    //   插入到消息数组中
    this.chatList.push(voiceChat)
    this.dataList.push({
      name: "鲁班",
      headSrc: $r("app.media.ic_user_head2"),
      msgType: 2,
      voicePath: res.recordFilePath,
      self: true,
      msg: `${duration}"`,
      img: $r("app.media.ic_voice_msg_right")
    })
    this.scroller.scrollToIndex(this.dataList.length)
  }
  // 开启ai实时转换声音
  onStartSpeechRecognize = () => {
    // 如果你是完整的一句话，我把它拼接到 this.voiceToText 如果不是，实时显示
    // 缓存一段句子的变量
    let sentence = ""
    SpeechRecognizerManager.init((res) => {
      // console.log("res", JSON.stringify(res))
      //   isFinal  这一句话 你结束了没有
      //   isLast 这一段语音你结束了没有
      // this.voiceToText = res.result
      if (res.isFinal) {
        sentence += res.result
        this.voiceToText = sentence
      } else {
        this.voiceToText = sentence + res.result
      }

    })
  }
  // 生成文字消息
  postText = () => {
    //   生成消息文件
    const TextChat = new ChatMessage(MessageType.text, this.voiceToText)
    //   插入到消息数组中
    this.chatList.push(TextChat)
  }

  build() {
    Column() {
      Toolbar({ title: this.name,
        u_id: this.u_id,
        c_id: this.c_id,
        u_name: this.u_name,
        c_name: $c_name,
        c_des: $c_des,
        m_id: $m_id,
      })
      List({ space: 20, initialIndex: this.dataList.length - 1, scroller: this.scroller }) {
        ForEach(this.dataList, (item: ChatContentItemData) => {
          ListItem() {
            if (item.self) {
              ListChatContentRightItem({ data: item })
            } else {
              ListChatContentLeftItem({ data: item })
            }
          }
        })
        ListItem() {
          Row().height(px2vp(20))
        }
      }
      .width("100%")
      .height(0)
      // .divider({ strokeWidth: 0.8, color: '#f0f0f0', startMargin: 90, endMargin: 0 }) // 每行之间的分界线
      .layoutWeight(1)

      Row(){
        Text('如果对回答不满意，可点击')
          .fontSize(12)
          .fontColor(Color.Gray)
        Button('重新发送')
          .enabled(this.dataList.length > 0)
          .fontSize(12)
          .backgroundColor(Color.Transparent)
          .fontColor(Color.Blue)
          .onClick(() => {
            this.chatText = '请重新回答:' + this.dataList[this.dataList.length - 2].msg
            this.sendTextMsg(1)
          })
      }
      Row() {

        if (this.inputType == WXInputType.keyboard) {
          // Image($r("app.media.ic_use_voice"))
          //   .width(33)
          //   .height(33)
          //   .borderRadius(4)
          //   .margin({ left: 15, right: 15 })
          //   .objectFit(ImageFit.Cover)
          //   .onClick(async () => {
          //     const result = await PermissionUtils.request(["ohos.permission.MICROPHONE"])
          //     if (!result) {
          //       ToastUtils.show("请先授权麦克风权限")
          //     }
          //     this.inputType = WXInputType.voice
          //     this.showFuncBarWithAnim(false)
          //   })

          TextArea({ text: $$this.chatText, placeholder: '', controller: this.controller })
            .placeholderFont({ size: 20, weight: 400 })
            .caretColor(Color.Green)
            .placeholderColor(Color.Grey)
            .layoutWeight(1)
            .padding({ left: 8, right: 8 })
            .fontSize(20)
            .fontColor(Color.Black)
            .borderRadius(8)// 设置stateStyles，解决点击编辑框会变色的问题
            .stateStyles({
              normal: {.backgroundColor(Color.White)
              },
              pressed: {.backgroundColor(Color.White)
              },
              clicked: {.backgroundColor(Color.White)
              },
              focused: {.backgroundColor(Color.White)
              }
            })
          // .onSubmit(() => {
          //   prompt.showToast({ message: this.chatText })
          // })
        }
        else {
          Image($r("app.media.ic_use_keyboard"))
            .width(33)
            .height(33)
            .borderRadius(4)
            .margin({ left: 15, right: 15 })
            .objectFit(ImageFit.Cover)
            .onClick(() => {
              this.inputType = WXInputType.keyboard
            })

          Button("按住 说话")
            .fontColor(Color.Black)
            .layoutWeight(1)
            .type(ButtonType.Normal)
            .borderRadius(8)
            .backgroundColor(Color.White)
            .fontSize(18)
            .bindContentCover($$this.showTalkContainer, this.buildRecordVoiceView,
              { modalTransition: ModalTransition.NONE })
            .onTouch(this.onPressTalk)
        }


        // Image($r("app.media.ic_emoji_pack"))
        //   .width(33)
        //   .height(33)
        //   .borderRadius(4)
        //   .margin({ left: 15, right: 5 })
        //   .objectFit(ImageFit.Cover)
        //   .onClick(unDevTip)


        Text("发送")
          .fontColor(Color.White)
          .width(65)
          .textAlign(TextAlign.Center)
          .height(36)
          .backgroundColor("#58BE6A")
          .fontSize(18)
          .visibility(this.chatText.length == 0 ? Visibility.None : Visibility.Visible)
          .borderRadius(6)
          .margin({ left: 10, right: 10 })
          .onClick(async () => {
            this.sendTextMsg()
          })

        // Image($r("app.media.ic_add"))
        //   .width(33)
        //   .height(33)
        //   .borderRadius(4)
        //   .visibility(this.chatText.length == 0 ? Visibility.Visible : Visibility.None)
        //   .margin({ left: 15, right: 8 })
        //   .objectFit(ImageFit.Cover)
        //   .onClick(() => {
        //     if (!this.showFuncBar) {
        //       this.inputType = WXInputType.keyboard
        //     }
        //     this.showFuncBarWithAnim(!this.showFuncBar)
        //   })

      }
      .padding({ top: 10, bottom: 10 })
      .alignItems(VerticalAlign.Bottom)
      .backgroundColor("#f9f9f9")

      Divider()
        .vertical(false)
        .color("#f0f0f0")
        .strokeWidth(1)
        .lineCap(LineCapStyle.Round)

      ChatFunctionBar()
        .height(this.funcBarHeight)

    }
    .width("100%")
    .height("100%")
    .backgroundColor("#f1f1f1")
    .padding({ bottom: WindowManager.navBarHeight })
  }


  private async  sendTextMsg(type?:number) {
    // TODO: save the new message to database
    // 获取操作数据库的对象
    const store = await this.getStoreInstance()
    console.log("1")
    // 添加一条数据
    const id = await store.insert(this.tableName, {
      id: null, // 新增时设置 id 为空值 null，用于自增 id
      c_id: this.c_id,
      msg: this.chatText,
      self: 1
    } as ChatContent)

    this.dataList.push({
      name: "鲁班",
      headSrc: $r("app.media.ic_user_head2"),
      msgType: 0,
      self: true,
      msg: this.chatText,
    })

    if (this.dataList.length == 1) {
      this.c_name = this.chatText
    }

    // 上下文逻辑
    let prompt : string = ''
    if (this.dataList.length > 0) {
      prompt += '上下文为：'
      this.dataList.forEach(item => {
        if (item.self) prompt += ('问:' + item.msg)
        else prompt += ('答:' + item.msg)
      })
    }

    this.test_api(prompt + this.chatText)

    this.scroller.scrollToIndex(this.dataList.length)
    this.chatText = ""
  }

  private test_api(question: string){
    hilog.error(0x0000, 'testTag', 'testing_api:', question);
    // 1 createHttp接口创建请求
    let httpRequest = http.createHttp();

    // 2 发起请求
    httpRequest.request(
      // 请求地址
      "https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation",
      // 请求options: HttpRequestOptions
      {
        // 请求方式
        method: http.RequestMethod.POST,
        // 请求头
        header: {
          "Content-Type": "application/json",
          // 这里的Authorization 就是刚才工作台查看的 API-KEY
          "Authorization": "sk-d3af13a4247e4082b8db7818e8c1e9b8" // 脱敏处理
        },
        // 请求体
        extraData: {
          "model": "qwen-plus", // 指定用于对话的通义千问模型名
          "input": {
            "messages": [
              {
                "role": "user",
                "content": question // 请求发起方传入的问题
              }
            ]
          }
        }
      }, async (err, data: http.HttpResponse) => {
      if (err) {
        hilog.error(0x0000, 'testTag', 'Failed to request ALiYun. Cause: %{public}s', JSON.stringify(err) ?? '');
        httpRequest.destroy();
      } else {
        hilog.error(0x0000, 'testTag', 'Request ALiYun success. data: %{public}s', JSON.stringify(data.result));
        httpRequest.destroy();
        let resp: ALiYunResponse = JSON.parse(data.result.toString())
        hilog.error(0x0000, 'testTag', 'data.result.text: %{public}', resp.output.text)
        // this.chatList.push({ headSrc: $r("app.media.ic_user_head7"),
        //   nickname: "老弟",
        //   content: question,
        //   time: "周一" })
        // const chat = new ChatMessage(MessageType.text, res);


        let answer : string = ''
        answer = resp.output.text

        //TODO: save the AI response message to database
        // 获取操作数据库的对象
        const store = await this.getStoreInstance()
        console.log("1")
        // 添加一条数据
        const id = await store.insert(this.tableName, {
          id: null, // 新增时设置 id 为空值 null，用于自增 id
          c_id: this.c_id,
          msg: answer,
          self: 0
        } as ChatContent)

        this.dataList.push({
          name: "鲁班",
          headSrc: $r("app.media.ic_user_head7"),
          msgType: 0,
          self: false,
          msg: answer,
        })

        if (this.dataList.length == 2) {
          this.c_des = resp.output.text
        }

        this.scroller.scrollToIndex(this.dataList.length)
      }
    })
  }

  async getData() {
    const store = await this.getStoreInstance()
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.orderByDesc('id') // 倒序(由大到小，常用于排序)
    // predicates.orderByAsc('id')   // 正序(小到大，常用于排序)
    // predicates.equalTo('id', 1)    // 等于(常用于详情页)
    // predicates.in('id', [1, 3, 5]) // 查找多项(常用批量删除)
    // predicates.like('title', '%哈%') //  模糊匹配(常用于搜索)
    // 还有很多...
    // predicates.greaterThan('id', 3)
    // resultSet 结果集
    const resultSet = await store.query(predicates)
    // 准备一个数组，用于存储数据库提取的数据
    const list: ChatContent [] = []
    // resultSet.goToNextRow()   指针移动到下一行
    while (resultSet.goToNextRow()) {
      // 移动指针的时候提取数据，按列下标提取数据
      list.push({
        // resultSet.getColumnIndex()        根据列名称获取下标(索引)
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        c_id: resultSet.getLong(resultSet.getColumnIndex('c_id')),
        msg: resultSet.getString(resultSet.getColumnIndex('msg')),
        self: resultSet.getLong(resultSet.getColumnIndex('self')),
      })
    }
    // 循环结束后，获取所有数据
    AlertDialog.show({ message: JSON.stringify(list, null, 2) })
  }

  private showFuncBarWithAnim(show: boolean) {
    animateTo({ duration: 400, curve: Curve.Ease }, () => {
      if (show) {
        this.funcBarHeight = 250;
      } else {
        this.funcBarHeight = 0;
      }
      this.showFuncBar = show;
    })
  }

  @Builder
  buildRecordVoiceView() {
    Column() {
      // 中心波浪线
      Row() {
        if (this.pressCancelVoicePostText !== PressCancelVoicePostText.postText) {
          // 声纹
          this.vocalPrint()

        } else {
          Scroll() {
            // 显示录音的文字
            Text(this.voiceToText)
              .fontSize(12)
              .fontColor("#666")
          }
          .width("100%")
          .height("100%")
        }

        Text()
          .width(10)
          .height(10)
          .backgroundColor(this.pressCancelVoicePostText === PressCancelVoicePostText.cancelVoice ? Color.Red :
            "#95EC6A")
          .position({
            bottom: -5,
            left: "50%"
          })
          .translate({
            x: "-50%"
          })
          .rotate({
            angle: 45
          })
      }
      .width("50%")
      .height(80)
      .backgroundColor(this.pressCancelVoicePostText === PressCancelVoicePostText.cancelVoice ? Color.Red : "#95EC6A")
      .position({
        top: "40%",
        left: "50%"
      })
      .translate({
        x: "-50%"
      })
      .borderRadius(10)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)

      // 取消和转文字
      Row() {
        // X
        Row() {
          Text("X")
            .fontSize(20)
            .width(80)
            .height(80)
            .borderRadius("50%")
            .fontColor(this.pressCancelVoicePostText === PressCancelVoicePostText.cancelVoice ? "#333" : Color.Gray)
            .backgroundColor(this.pressCancelVoicePostText === PressCancelVoicePostText.cancelVoice ? Color.White :
              "#333")
            .textAlign(TextAlign.Center)
            .align(Alignment.Center)
            .fontColor("#ccc")
            .id("cancel_record")
            .rotate({ angle: -15 })
        }

        // 文
        Row() {
          Text("文")
            .fontSize(20)
            .width(80)
            .height(80)
            .borderRadius("50%")
            .fontColor(this.pressCancelVoicePostText === PressCancelVoicePostText.postText ? "#333" : Color.Gray)
            .backgroundColor(this.pressCancelVoicePostText === PressCancelVoicePostText.postText ? Color.White : "#333")
            .textAlign(TextAlign.Center)
            .align(Alignment.Center)
            .id("translate_text")
            .rotate({ angle: 15 })
        }

        // 3  松开发送
        Text(this.pressCancelVoicePostText === PressCancelVoicePostText.cancelVoice ? '取消发送' :
          (this.pressCancelVoicePostText === PressCancelVoicePostText.postText ? '转换文字' : "松开发送"))
          .fontColor("#fff")
          .width("100%")
          .position({
            bottom: 0,
            left: 0
          })
          .textAlign(TextAlign.Center)
      }
      .width("100%")
      .position({
        bottom: "23%"
      })
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({
        left: 35, right: 35
      })


      Stack() {
        Text()
          .width(800)
          .height(800)
          .backgroundColor("#AAAAAA")
          .borderRadius("50%")// .position({ top: 0 ,left:"-50%"})
            // .position({ top: 0 ,left:"-50%"})
          .position({ top: 0, left: "50%" })
          .translate({
            x: "-50%",
          })

        Image($r("app.media.ic_voice_msg_left"))
          .width(33)
          .height(33)
          .objectFit(ImageFit.Cover)
      }
      .width("100%")
      .height(150)
      .alignContent(Alignment.Center)
      .position({
        bottom: 0
      })
      .id("bottom_bubble")
      .onAppear(() => {
        let modePosition: componentUtils.ComponentInfo = componentUtils.getRectangleById("bottom_bubble");
        this.bubbleScreenOffset.x = px2vp(modePosition.localOffset.x)
        this.bubbleScreenOffset.y = px2vp(modePosition.localOffset.y)
        this.bubbleScreenOffset.width = px2vp(modePosition.size.width)
        this.bubbleScreenOffset.height = px2vp(modePosition.size.height)
      })

    }
    .width("100%")
    .height("100%")
    .backgroundColor("#9F000000")
  }

  /**
   * 录音中的 动态声纹波浪
   */
  @Builder
  vocalPrint() {
    Canvas(this.context)
      .onDisAppear(() => {
        clearInterval(this.voiceTimeId)
      })
      .width('80%')
      .height('80%')
      .onReady(() => {
        clearInterval(this.voiceTimeId)
        this.voiceTimeId = setInterval(() => {
          this.context.clearRect(0, 0, 200, 200)
          for (let index = 0; index < 35; index++) {
            const random = Math.floor(Math.random() * 20)
            let height = 5 + random
            this.context.fillRect(10 + index * 5, 32 - height / 2, 2, height);
          }
        }, 100)
      })
  }

  private async startVibration() {
    try {
      // 触发马达振动
      vibrator.startVibration({
        type: 'time',
        duration: 100,
      }, {
        id: 0,
        usage: 'touch'
      }, () => {
      })
    } catch (err) {
    }
  }
}

const unDevTip = () => {
  ToastUtils.show("功能正在开发中...")
}


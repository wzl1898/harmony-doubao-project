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

  dateFormat(date?: number | Date, fmt?: string) {
    let _date = new Date();
    if (date == undefined || date == null) {
      _date = new Date();
    } else if (typeof (date) === 'number') {
      _date = new Date(date);
    }
    if (fmt == undefined || fmt == null || fmt.length <= 0) {
      fmt = "yyyy-MM-dd HH:mm";
    }
    let map = new Map<String, Number>();
    map.set("M+", _date.getMonth() + 1); // 月份
    map.set("d+", _date.getDate()); // 日
    map.set("h+", _date.getHours() % 12 == 0 ? 12 : _date.getHours() % 12); // 12小时
    map.set("H+", _date.getHours()); // 24小时
    map.set("m+", _date.getMinutes()); // 分
    map.set("s+", _date.getSeconds()); // 秒
    map.set("q+", Math.floor((_date.getMonth() + 3) / 3)); // 季度
    map.set("S", _date.getMilliseconds()); // 毫秒

    let week = new Map<string, string>();
    week.set("0", "日");
    week.set("1", "一");
    week.set("2", "二");
    week.set("3", "三");
    week.set("4", "四");
    week.set("5", "五");
    week.set("6", "六");
    let yearMatcher = /(y+)/.exec(fmt);
    if (yearMatcher && yearMatcher.length > 0) {
      let match = yearMatcher[0];
      fmt = fmt.replace(match, (_date.getFullYear() + "").substr(4 - match.length));
    }
    let weekMatcher = /(E+)/.exec(fmt);
    if (weekMatcher && weekMatcher.length > 0) {
      let match = weekMatcher[0];
      fmt = fmt.replace(match,
        ((match.length > 1) ? (match.length > 2 ? "星期" : "周") : "") + week.get(_date.getDay() + ""));
    }
    map.forEach((value, key) => {
      let matcher = new RegExp(`(${key})`).exec(fmt!);
      if (matcher && matcher.length > 0) {
        let match = matcher[0];
        let replaceValue = '';
        if ((match.length == 1)) {
          replaceValue = `${value}`;
        } else {
          replaceValue = (("00" + value).substr(("" + value).length))
        }
        fmt = fmt!.replace(match, replaceValue);
      }
    });
    return fmt;
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


      Text(this.dateFormat(this.data.time))
        .fontColor(Color.Gray)
        .fontSize(14)
        .alignSelf(ItemAlign.Start)
        .margin({ top: 15, right: 6 })

      // Text(new Date(this.data.time).toString())
      //   .fontColor(Color.Gray)
      //   .fontSize(14)
      //   .alignSelf(ItemAlign.Start)
      //   .margin({ top: 15, right: 6 })
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

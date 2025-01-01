/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

import CommonConstants from '../common/constants/CommonConstants';
import PromptUtil from '../common/utils/PromptUtil';
import HuksModel from '../model/HuksModel';
import { BusinessError } from '@kit.BasicServicesKit';
import Logger from '../common/utils/Logger';
import { util } from '@kit.ArkTS';
import PreferenceModel from '../model/PreferenceModel';
import UserAuthModel from '../model/UserAuthModel';

import { relationalStore, ValuesBucket } from '@kit.ArkData'

interface UserItem extends ValuesBucket {
  id: number | null // 新增时设置 id 为空值 null，用于自增 id
  name: string
  psw: string
}

@Extend(TextInput)
function inputStyle() {
  .placeholderColor($r('app.color.placeholder_color'))
  .height($r('app.float.login_input_height'))
  .fontSize($r('app.float.big_text_size'))
  .backgroundColor(Color.White)
  .width(CommonConstants.FULL_PARENT)
  .padding({ left: CommonConstants.INPUT_PADDING_LEFT })
  .margin({ top: $r('app.float.input_margin_top') })
}

@Extend(Line)
function lineStyle() {
  .width(CommonConstants.FULL_PARENT)
  .height($r('app.float.line_height'))
  .backgroundColor($r('app.color.line_color'))
}

@Component
export struct RegisterPage {
  @State isShowFace: boolean = false;
  @State isShowFingerprint: boolean = false;
  @State isRegisterAvailable: boolean = false;
  @Consume('pageInfos') pageInfos: NavPathStack;
  private name: string = '';
  private passWord: string = '';
  private confirmPassWord: string = '';
  @Consume('isFace') isFace : boolean;
  @Consume('isFingerprint') isFingerprint: boolean;
  private keyAlias: string = CommonConstants.LOGIN_KEYS;

  // 用户表
  tableName: string = 'user'
  sqlCreate: string = `CREATE TABLE IF NOT EXISTS ${this.tableName} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE,
        psw TEXT NOT NULL
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

  /**
   * Check whether the registration button can be clicked.
   */
  isRegister() {
    this.isRegisterAvailable = false;
    if (this.name.length > 0 && this.passWord.length > 0 && this.confirmPassWord.length > 0) {
      this.isRegisterAvailable = true;
    }
  }

  /**
   * Process the registration process.
   */
  async register() {
    if (!this.name) {
      PromptUtil.promptMessage($r('app.string.message_user_name'), CommonConstants.PROMPT_DURATION);
      return;
    }
    if (!this.passWord || this.passWord !== this.confirmPassWord) {
      PromptUtil.promptMessage($r('app.string.message_password_prompt'), CommonConstants.PROMPT_DURATION);
      return;
    }

    // 获取数据库对象
    const store = await this.getStoreInstance()

    // 判断用户名不重复
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.equalTo('name', this.name)
    const resultSet = await store.query(predicates)
    if (resultSet.goToNextRow()) {
      AlertDialog.show({ message: '用户名重复'})
      return
    }

    // 新建用户
    const id = await store.insert(this.tableName, {
      id: null, // 新增时设置 id 为空值 null，用于自增 id
      name: this.name,
      psw: this.passWord
    } as UserItem)
    AlertDialog.show({ message: '用户新建成功'})

    let isExist = false;
    await HuksModel.isKeyItemExist(this.keyAlias)
      .then((value: boolean) => {
        isExist = value;
      })
      .catch((error: BusinessError) => {
        Logger.error(CommonConstants.TAG, `huks keys not generate cause ${error.code} ${error.message}`);
      })
    if (!isExist) {
      PromptUtil.promptMessage($r('app.string.message_application_prompt'), CommonConstants.PROMPT_DURATION);
      return;
    }
    await HuksModel.encrypt(this.keyAlias, this.passWord).then((value?: Uint8Array) => {
      if (value) {
        let base64Helper = new util.Base64Helper();
        let password = base64Helper.encodeToStringSync(value);
        PreferenceModel.putPreference(CommonConstants.CRYPTO_PASSWORD, password);
        PreferenceModel.putPreference(CommonConstants.USER_NAME, this.name);
        PreferenceModel.putPreference(CommonConstants.IS_SHOW_FACE, this.isFace);
        PreferenceModel.putPreference(CommonConstants.IS_SHOW_FINGERPRINT, this.isFingerprint);
        this.pageInfos.pop();
      }
    })
  }

  build() {
    NavDestination() {
      Row() {
        Column() {
          Image($r('app.media.ic_logo'))
            .width($r('app.float.logo_image_size'))
            .height($r('app.float.logo_image_size'))
            .margin({
              top: $r('app.float.logo_margin_top'),
              bottom: $r('app.float.logo_margin_bottom')
            })
          Text($r('app.string.register_page'))
            .fontSize($r('app.float.title_text_size'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.title_text_color'))

          Column() {
            TextInput({ placeholder: $r('app.string.register_name')})
              .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
              .type(InputType.USER_NAME)
              .inputStyle()
              .onChange((value: string) => {
                this.name = value;
                this.isRegister();
              })

            Line().lineStyle()

            TextInput({ placeholder: $r('app.string.register_password')})
              .maxLength(CommonConstants.INPUT_PASSWORD_LENGTH)
              .type(InputType.NEW_PASSWORD)
              .inputStyle()
              .onChange((value: string) => {
                this.passWord = value;
                this.isRegister();
              })

            Line().lineStyle()

            TextInput({ placeholder: $r('app.string.register_confirm_password')})
              .maxLength(CommonConstants.INPUT_PASSWORD_LENGTH)
              .type(InputType.NEW_PASSWORD)
              .inputStyle()
              .onChange((value: string) => {
                this.confirmPassWord = value;
                this.isRegister();
              })
          }
          .backgroundColor(Color.White)
          .borderRadius($r('app.float.input_border_radius'))
          .padding({
            top: $r('app.float.input_padding_top'),
            bottom: $r('app.float.input_padding_top'),
            left: $r('app.float.input_padding_left'),
            right: $r('app.float.input_padding_left')
          })
          .margin({
            top: $r('app.float.register_margin_top')
          })

          if (this.isShowFace) {
            Row() {
              Checkbox()
                .selectedColor($r('app.color.register_checkbox'))
                .onChange((value: boolean) => {
                  this.isFace = value;
                })
              Text($r('app.string.register_face_checkbox'))
                .fontSize($r('app.float.small_text_size'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.register_text_color'))
            }
            .width(CommonConstants.FULL_PARENT)
            .margin({
              top: $r('app.float.face_margin_top'),
              left: $r('app.float.face_margin_left')
            })
          }

          if (this.isShowFingerprint) {
            Row() {
              Checkbox()
                .selectedColor($r('app.color.register_checkbox'))
                .onChange((value: boolean) => {
                  this.isFingerprint = value;
                })
              Text($r('app.string.register_fingerprint_checkbox'))
                .fontSize($r('app.float.small_text_size'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.register_text_color'))
            }
            .width(CommonConstants.FULL_PARENT)
            .margin({
              top: $r('app.float.fingerprint_margin_top'),
              left: $r('app.float.face_margin_left')
            })
          }

          Button($r('app.string.register_button'), { type: ButtonType.Capsule })
            .width(CommonConstants.BUTTON_WIDTH)
            .height($r('app.float.login_button_height'))
            .fontSize($r('app.float.normal_text_size'))
            .fontWeight(FontWeight.Medium)
            .backgroundColor(
              this.isRegisterAvailable ? $r('app.color.login_button_color') : $r('app.color.button_color_unavailable')
            )
            .margin({
              top: $r('app.float.register_button_top'),
              bottom: $r('app.float.button_bottom')
            })
            .enabled(this.isRegisterAvailable)
            .onClick(async () => {
              await this.register();
            })
        }
        .backgroundColor($r('app.color.background'))
        .height(CommonConstants.FULL_PARENT)
        .width(CommonConstants.FULL_PARENT)
        .padding({
          left: $r('app.float.page_padding_hor'),
          right: $r('app.float.page_padding_hor'),
          bottom: $r('app.float.login_page_bottom')
        })
      }
      .height(CommonConstants.FULL_PARENT)
    }
    .hideTitleBar(true)
    .onAppear(() => {
      HuksModel.isKeyItemExist(this.keyAlias)
        .then((isExist) => {
          if (!isExist) {
            HuksModel.generateKeyItem(this.keyAlias);
          }
        })
        .catch((error: BusinessError) => {
          Logger.error(CommonConstants.TAG, `huks keys not generate ${error.code} ${error.message}`);
          HuksModel.generateKeyItem(this.keyAlias);
        })
      this.isShowFace = UserAuthModel.isFaceAvailable();
      this.isShowFingerprint = UserAuthModel.isFingerprintAvailable();
      this.isFace = false;
      this.isFingerprint = false;
    })
  }
}
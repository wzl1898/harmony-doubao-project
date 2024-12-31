/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

import { huks } from '@kit.UniversalKeystoreKit';
import CommonConstants from '../common/constants/CommonConstants';
import Logger from '../common/utils/Logger';
import { BusinessError } from '@kit.BasicServicesKit';
import { util } from '@kit.ArkTS';

class HuksModel {
  /**
   * Key vector.
   */
  private IV: string = '0000000000000000';

  /**
   * Data size.
   */
  private static readonly MAX_LENGTH: number = 100*1024 / 2;

  generateKeyItem(keyAlias: string) {
    if (!keyAlias || keyAlias.length === 0) {
      return;
    }
    let properties = this.getProperties();
    let option: huks.HuksOptions = {
      properties: properties
    };
    huks.generateKeyItem(keyAlias, option).then(() => {
      Logger.info(CommonConstants.TAG, 'generateKeyItem success');
    }).catch((error: BusinessError) => {
      Logger.error(CommonConstants.TAG, `generateKeyItem failed, cause ${error.code} ${error.message}`);
    })
  }

  /**
   * Get default properties.
   */
  private getProperties() {
    let properties: Array<huks.HuksParam> = [];
    properties[0] = {
      tag: huks.HuksTag.HUKS_TAG_ALGORITHM,
      value: huks.HuksKeyAlg.HUKS_ALG_AES
    };
    properties[1] = {
      tag: huks.HuksTag.HUKS_TAG_PURPOSE,
      value: huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_ENCRYPT | huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_DECRYPT
    };
    properties[2] = {
      tag: huks.HuksTag.HUKS_TAG_KEY_SIZE,
      value: huks.HuksKeySize.HUKS_AES_KEY_SIZE_128
    };
    properties[3] = {
      tag: huks.HuksTag.HUKS_TAG_BLOCK_MODE,
      value: huks.HuksCipherMode.HUKS_MODE_CBC
    };
    properties[4] = {
      tag: huks.HuksTag.HUKS_TAG_PADDING,
      value: huks.HuksKeyPadding.HUKS_PADDING_PKCS7
    };
    return properties;
  }

  /**
   * huks handing process
   *
   * @param keyAlias keyAlias key alias
   * @param option huks required operation parameters
   */
  async huksProcess(keyAlias: string, option: huks.HuksOptions): Promise<Uint8Array> {
    if (!keyAlias || !option || keyAlias.length === 0) {
      return new Uint8Array([]);
    }
    let result: Uint8Array = new Uint8Array();
    let handle: number = 0;

    await huks.initSession(keyAlias, option).then((sessionHandle) => {
      handle = sessionHandle.handle;
    }).catch((error: BusinessError) => {
      Logger.error(CommonConstants.TAG, `updateSession failed, cause ${error.code} ${error.message}`);
    })

    if (option.inData && option.inData.length > HuksModel.MAX_LENGTH) {
      await huks.updateSession(handle, option).then((value: huks.HuksReturnResult) => {
        if (value.outData) {
          result = value.outData;
        }
      }).catch((error: BusinessError) => {
        Logger.error(CommonConstants.TAG, `updateSession failed, cause ${error.code} ${error.message}`);
      })
    }
    await huks.finishSession(handle, option).then((value: huks.HuksReturnResult) => {
      if (value.outData) {
        result = new Uint8Array(Array.from(result).concat(Array.from(value.outData)));
      }
    }).catch((error: BusinessError) => {
      Logger.error(CommonConstants.TAG, `finishSession failed, cause ${error.code} ${error.message}`);
    })
    return new Uint8Array(result);
  }

  /**
   * Encrypt option.
   *
   * @param keyAlias key alias.
   * @param data Data to be encrypted.
   */
  async encrypt(keyAlias: string, data: string) {
    if (!keyAlias || keyAlias.length === 0 || !data || data.length === 0) {
      return;
    }
    let encryptData: Uint8Array = new Uint8Array();
    let properties = this.getProperties();
    properties[1].value = huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_ENCRYPT;
    properties.push({
      tag: huks.HuksTag.HUKS_TAG_IV,
      value: this.StringToUint8Array(this.IV)
    } as huks.HuksParam);
    let options: huks.HuksOptions = {
      properties: properties,
      inData: this.StringToUint8Array(data)
    };
    await this.huksProcess(keyAlias, options).then((result) => {
      encryptData = result;
    }).catch((error: BusinessError) => {
      Logger.error(CommonConstants.TAG, `finishSession failed, cause ${error.code} ${error.message}`);
    })
    return encryptData;
  }

  /**
   * Decrypt option.
   *
   * @param keyAlias key alias.
   * @param data Data to be decrypted.
   */
  async decrypt(keyAlias: string, data: Array<number>) {
    if (!keyAlias || keyAlias.length === 0 || !data) {
      return;
    }
    let decryptData: Uint8Array = new Uint8Array();
    let properties = this.getProperties();
    properties[1].value = huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_DECRYPT;
    properties.push({
      tag: huks.HuksTag.HUKS_TAG_IV,
      value: this.StringToUint8Array(this.IV)
    } as huks.HuksParam);
    let options: huks.HuksOptions = {
      properties: properties,
      inData: new Uint8Array(data)
    };
    await this.huksProcess(keyAlias, options).then((result) => {
      decryptData = result;
    }).catch((error: BusinessError) => {
      Logger.error(CommonConstants.TAG, `finishSession failed, cause ${error.code} ${error.message}`);
    })
    let result = this.Uint8ArrayToString(decryptData);
    return result;
  }

  /**
   * Converting Strings to Arrays
   *
   * @param str string
   */
  StringToUint8Array(str: string) {
    let textEncoder = util.TextEncoder.create('utf-8');
    return textEncoder.encodeInto(str);
  }

  /**
   * Converting Arrays to Strings
   *
   * @param fileData arrays
   */
  Uint8ArrayToString(data: Uint8Array) {
    let textDecoder = util.TextDecoder.create('utf-8');
    return textDecoder.decodeWithStream(data);
  }

  /**
   * check whether a key exists
   *
   * @param keyAlias
   */
  isKeyItemExist(keyAlias: string) {
    let emptyOptions: huks.HuksOptions = {
      properties: []
    };
    return huks.isKeyItemExist(keyAlias, emptyOptions);
  }
}

export default new HuksModel();
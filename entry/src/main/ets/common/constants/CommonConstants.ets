/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

/**
 * Common constants for all features
 */
export default class CommonConstants {
  /**
   * Input length of the account.
   */
  static readonly INPUT_ACCOUNT_LENGTH: number = 11;

  /**
   * Input length of the password.
   */
  static readonly INPUT_PASSWORD_LENGTH: number = 8;

  /**
   * Left padding of the input box.
   */
  static readonly INPUT_PADDING_LEFT: number = 0;

  /**
   * Delay time of simulated login.
   */
  static readonly LOGIN_DELAY_TIME: number = 2000;

  /**
   * Common Spacing of Components.
   */
  static readonly COMMON_SPACE: number = 12;

  /**
   * Spacing of other login methods.
   */
  static readonly LOGIN_METHODS_SPACE: number = 44;

  /**
   * Prompt duration.
   */
  static readonly PROMPT_DURATION: number = 2000;

  /**
   * User authentication dialog.
   */
  static readonly PROMPT_AUTH_DURATION: number = 1000;

  /**
   * Home tab index.
   */
  static readonly HOME_TAB_INDEX: number = 0;

  /**
   * Mine tab index.
   */
  static readonly MINE_TAB_INDEX: number = 1;

  /**
   * Convert milliseconds to seconds.
   */
  static readonly MILLISECONDS_TO_SECONDS: number = 1;

  /**
   * Grid columns template.
   */
  static readonly HOME_COLUMNS_TEMPLATE: string = '1fr 1fr 1fr 1fr';

  /**
   * Grid rows template.
   */
  static readonly HOME_ROWS_TEMPLATE: string = '1fr 1fr';

  /**
   * Grid columns template.
   */
  static readonly SECOND_COLUMNS_TEMPLATE: string = '1fr 1fr';

  /**
   * Grid rows template.
   */
  static readonly SECOND_ROWS_TEMPLATE: string = '1fr 1fr';

  /**
   * Preferences database name.
   */
  static readonly PREFERENCES_NAME: string = 'login.db';

  /**
   * Logger tag.
   */
  static readonly TAG: string = '[UserAuth]';

  /**
   * Key storage field.
   */
  static readonly KEY: string = 'key';

  /**
   * Password storage field.
   */
  static readonly CRYPTO_PASSWORD: string = 'cryptoPassword';

  /**
   * UserName storage field.
   */
  static readonly USER_NAME: string = 'userName';

  /**
   * Keys alias storage field.
   */
  static readonly LOGIN_KEYS: string = 'loginKeys'

  /**
   * Display face authentication.
   */
  static readonly IS_SHOW_FACE: string = 'isShowFace';

  /**
   * Display fingerprint authentication.
   */
  static readonly IS_SHOW_FINGERPRINT: string = 'isShowFingerprint';

  /**
   * Login page url.
   */
  static readonly ROUTER_LOGIN_URL: string = 'pages/LoginPage';

  /**
   * Register page url.
   */
  static readonly ROUTER_REGISTER_URL: string = 'pages/RegisterPage';

  /**
   * Main page url.
   */
  static readonly ROUTER_MAIN_URL: string = 'pages/MainPage';

  /**
   * Default distance between the prompt and the bottom.
   */
  static readonly PROMPT_BOTTOM: string = '80vp';

  /**
   * The width or height of the component is spread across the parent component.
   */
  static readonly FULL_PARENT: string = '100%';

  /**
   * The width of button.
   */
  static readonly BUTTON_WIDTH: string = '90%';
}
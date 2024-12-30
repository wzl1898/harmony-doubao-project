
import http from '@ohos.net.http';
import hilog from '@ohos.hilog';
class AliYunHttpUtils {

  // request(question: string) {
  //   hilog.info(0x0000, 'testTag', 'ALiYunHttpUtils request invoke. question: %{public}s', question);
  //
  //   // 1 createHttp接口创建请求
  //   let httpRequest = http.createHttp();
  //
  //   // 2 发起请求
  //   httpRequest.request(
  //     // 请求地址
  //     "https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation",
  //     // 请求options: HttpRequestOptions
  //     {
  //       // 请求方式
  //       method: http.RequestMethod.POST,
  //       // 请求头
  //       header: {
  //         "Content-Type": "application/json",
  //         // 这里的Authorization 就是刚才工作台查看的 API-KEY
  //         "Authorization": "sk-d3af13a4247e4082b8db7818e8c1e9b8" // 脱敏处理
  //       },
  //       // 请求体
  //       extraData: {
  //         "model": "qwen-plus", // 指定用于对话的通义千问模型名
  //         "input": {
  //           "messages": [
  //             {
  //               "role": "user",
  //               "content": question // 请求发起方传入的问题
  //             }
  //           ]
  //         }
  //       }
  //     }, (err, data: http.HttpResponse) => {
  //     if (err) {
  //       hilog.error(0x0000, 'testTag', 'Failed to request ALiYun. Cause: %{public}s', JSON.stringify(err) ?? '');
  //       httpRequest.destroy();
  //     } else {
  //       hilog.error(0x0000, 'testTag', 'Request ALiYun success. data: %{public}s', JSON.stringify(data.result));
  //       httpRequest.destroy();
  //       return data.result['text']
  //     }
  //   })
  // }
  request(question: string): Promise<string> {
    return new Promise<string>(() => {
      hilog.info(0x0000, 'testTag', 'ALiYunHttpUtils request invoke. question: %{public}s', question);

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
          }, (err, data: http.HttpResponse) => {
          if (err) {
            hilog.error(0x0000, 'testTag', 'Failed to request ALiYun. Cause: %{public}s', JSON.stringify(err) ?? '');
            httpRequest.destroy();
          } else {
            hilog.error(0x0000, 'testTag', 'Request ALiYun success. data: %{public}s', JSON.stringify(data.result));
            httpRequest.destroy();
            return data.result['text']
          }
        })
    });
  }
}

export default new AliYunHttpUtils;

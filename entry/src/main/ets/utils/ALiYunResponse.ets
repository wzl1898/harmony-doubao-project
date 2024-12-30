export default  class ALiYunResponse {
  request_id: string
  output: ALiYunResp_output
  usage: ALiYunResp_usage

  constructor(request_id: string, output:ALiYunResp_output,usage: ALiYunResp_usage) {
    this.request_id = request_id
    this.output = output
    this.usage = usage
  }
}

class ALiYunResp_output {
  text: string

  constructor(text:string) {
    this.text = text
  }
}

class ALiYunResp_usage {
  output_tokens: string
  input_tokens: string

  constructor(output_tokens:string,input_tokens:string) {
    this.output_tokens = output_tokens
    this.input_tokens = input_tokens
  }
}
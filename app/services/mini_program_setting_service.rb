class MiniProgramSettingService < MiniProgramBaseService
  def set_domain
    request_body = {
      action: 'set',
      requestdomain: Array(ENVConfig.mini_program_request_domains.split(",")),
      wsrequestdomain: Array(ENVConfig.mini_program_ws_request_domains.split(",")),
      uploaddomain: Array(ENVConfig.mini_program_upload_domains.split(",")),
      downloaddomain: Array(ENVConfig.mini_program_download_domains.split(","))
    }
    logger.info "MiniProgram set domain request with: #{request_body.to_json}"
    resp = Faraday.post mini_program_api_url("modify_domain"), request_body.to_json
    SiteLog::Base.logger("mpapi", "MiniProgram set domain response with: #{resp.body}")
    JSON.load(resp.body)
  end

  def get_preview_qrcode
    resp = Faraday.get mini_program_api_url("get_qrcode")
    SiteLog::Base.logger("mpapi", "MiniProgram get preview qrcode response: #{resp.status}")
    QiniuUploader.upload_data(ENVConfig.qiniu_domain, ENVConfig.qiniu_bucket, resp.body)
  end

  def create_wxacode(request_body)
    logger.info "MiniProgram get wxacode request with: #{request_body.to_json}"
    resp = Faraday.post mini_program_api_url("getwxacodeunlimit"), request_body.to_json
    SiteLog::Base.logger("mpapi", "MiniProgram get wxacode response: #{resp.status}")
    QiniuUploader.upload_data(ENVConfig.qiniu_domain, ENVConfig.qiniu_bucket, resp.body)
  end
end

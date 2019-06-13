module MiniProgramCommit
  extend self

  def get_qrcode(action, mp_user)
    url = mini_program_api_url(action, mp_user)
    resp = HTTParty.get(url)
    SiteLog::Base.logger("mpapi", "MiniProgramCommit #{mp_user.app_id} get_qrcode response: #{resp.headers}")
    if resp.headers["content-disposition"]
      return Base64.strict_encode64(resp.body)
    end
  end

  def submit_audit(action, mp_user)
    a = ENVConfig.requestdomain.to_s.split(",").size
    a.times.each do |i|
      request_params = {
  		  action: "add",
  		  requestdomain: ENVConfig.requestdomain.to_s.split(",")[i],
  		  wsrequestdomain: ENVConfig.wsrequestdomain.to_s.split(",")[i],
  		  uploaddomain: ENVConfig.uploaddomain.to_s.split(",")[i],
  		  downloaddomain: ENVConfig.downloaddomain.to_s.split(",")[i]
      }.to_json
      resp_info = commit("modify_domain", mp_user, request_params, "post")
    end

    if mp_user.try(:site).ec_slides.bottom_menu.size > 0
      list = []
      mp_user.try(:site).ec_slides.bottom_menu.each do |menu|
        tab = nil
        if menu.url == 'pages/index/index'
          tab = {
            pagePath: "pages/index/index",
            iconPath: "assets/images/index.png",
            selectedIconPath: "assets/images/indexselected.png",
            text: menu.title.presence || "首页"
          }
        elsif menu.url == 'pages/ec/category/category'
          tab = {
            pagePath: "pages/ec/category/category",
            iconPath: "assets/images/category.png",
            selectedIconPath: "assets/images/categoryselected.png",
            text: menu.title.presence || "分类"
          }
        elsif menu.url == 'pages/site/category'
          tab = {
            pagePath: "pages/site/category",
            iconPath: "assets/images/category.png",
            selectedIconPath: "assets/images/categoryselected.png",
            text: menu.title.presence || "分类"
          }
        elsif menu.url == 'pages/ec/shopping-cart/shopping-cart'
          tab =  {
            pagePath: "pages/ec/shopping-cart/shopping-cart",
            iconPath: "assets/images/cart.png",
            selectedIconPath: "assets/images/cartselected.png",
            text: menu.title.presence || "购物车"
          }
        elsif menu.url == 'pages/user/my-center'
          tab =  {
            pagePath: "pages/user/my-center",
            iconPath: "assets/images/mycenter.png",
            selectedIconPath: "assets/images/mycenterselected.png",
            text: menu.title.presence || "我的"
          }
        elsif menu.url == "pages/site/case_list"
          tab = {
            pagePath: "pages/site/case_list",
            iconPath: "assets/images/category.png",
            selectedIconPath: "assets/images/categoryselected.png",
            text: menu.title.presence || "分类"
          }
        end
        list.push(tab) if tab
      end

      ext_json = {
        extEnable: true,
        extAppid: mp_user.app_id,
        ext: {
          appid: mp_user.app_id,
          name: mp_user.nickname
        },
        window: {
          navigationBarTitleText: mp_user.nickname
        },
        tabBar: {
          color: "#a3a3a3",
          selectedColor: "#ff2842",
          borderStyle: "black",
          backgroundColor: "#fff",
          list: list
        }
      }.to_json
    else
      ext_json = {
        extEnable: true,
        extAppid: mp_user.app_id,
        ext: {
          appid: mp_user.app_id,
          name: mp_user.nickname
        },
        window: {
          navigationBarTitleText: mp_user.nickname
        }
      }.to_json
    end

    new_release = WxRelease.last
    request_params = {
      template_id: new_release.template_id,
      ext_json: ext_json,
      user_version: new_release.user_version,
      user_desc: new_release.description
    }.to_json

    resp_info = commit("commit", mp_user, request_params, "post")
    return "上传代码失败#{resp_info["errmsg"]}" unless resp_info["errcode"] == 0

    resp_info = commit("get_category", mp_user, request_params, "get")
    return "获取分类失败#{resp_info["errmsg"]}" unless resp_info["errcode"] == 0

    category_list = resp_info["category_list"][0]

    resp_info = commit("get_page", mp_user, request_params, "get")
    return "获取页面失败#{resp_info["errmsg"]}" unless resp_info["errcode"] == 0
    page_list = resp_info["page_list"]

    request_params = {
      item_list: [
        {
          address: page_list[0],
          tag: "电商",
          first_class: category_list["first_class"],
          second_class: category_list["second_class"],
          first_id: category_list["first_id"],
          second_id: category_list["second_id"],
          title: "首页"
        }
      ]
    }.to_json.gsub(/\\u([0-9a-z]{4})/){|s| [$1.to_i(16)].pack("U")}
    resp_info = commit(action, mp_user, request_params, "post")

    if resp_info["errcode"] == 0
      mp_user.update_attributes(auditstatus: 0, new_template_id: new_release.template_id, new_user_version: new_release.user_version)
      return "提交成功"
    else
      return "提交失败#{resp_info["errmsg"]}"
    end
  end

  def get_latest_auditstatus(action, mp_user)
    resp_info = commit(action, mp_user, {}, "get")

    if resp_info["status"] == 0
      return "审核成功"
    elsif resp_info["status"] == 2
      return "审核中"
    elsif resp_info["status"] == 1
      return "审核失败，理由：#{resp_info["reason"]}"
    else
      return "网络有问题"
    end
  end

  def release(action, mp_user)
    request_params = {}.to_json
    resp_info = commit(action, mp_user, request_params, "post")

    if resp_info["errcode"] == 0
      mp_user.update_attributes(auditstatus: 2, template_id: mp_user.new_template_id, user_version: mp_user.new_user_version)
      # return "发布成功"
    elsif resp_info["errcode"] == 85052
      # mp_user.update_attributes(auditstatus: 3)
      # return "已经发布"
    else
      mp_user.update_attributes(auditstatus: 3)
      # return "发布失败"
    end
    true
  end

  def mp_qrcode(mp_user)
    if mp_user.expires_in.to_s > Time.now.to_s
      url = "https://api.weixin.qq.com/cgi-bin/wxaapp/createwxaqrcode?access_token=#{mp_user.access_token}"
    else
      url = "https://api.weixin.qq.com/cgi-bin/wxaapp/createwxaqrcode?access_token=#{MpUserSetting.fetch_access_token(mp_user)}"
    end

    request_params = {
      scene: "/scene",
      page: "pages/index/index"
    }.to_json

    url = "https://api.weixin.qq.com/wxa/getwxacodeunlimit?access_token=#{mp_user.access_token}"
    resp = HTTParty.post(url, body: request_params)

    SiteLog::Base.logger("mpapi", "MiniProgramCommit #{mp_user.app_id} qrcode response: #{resp.headers}")
    if resp.headers["content-disposition"]
      return Base64.strict_encode64(resp.body)
    end
  rescue
    ''
  end

  def qrcode(action, mp_user)
    if mp_user.expires_in.to_s > Time.now.to_s
      url = "https://api.weixin.qq.com/cgi-bin/wxaapp/createwxaqrcode?access_token=#{mp_user.access_token}"
    else
      url = "https://api.weixin.qq.com/cgi-bin/wxaapp/createwxaqrcode?access_token=#{MpUserSetting.fetch_access_token(mp_user)}"
    end

    request_params = {path: "pages/index/index", width: 430}.to_json
    resp = HTTParty.post(url, body: request_params)
    SiteLog::Base.logger("mpapi", "MiniProgramCommit #{mp_user.app_id} qrcode response: #{resp.headers}")

    if resp.headers["content-disposition"]
      return Base64.strict_encode64(resp.body)
    end
  end

  def add_bind_tester(mp_user)
    WxTestUser.delete_all
    ["happywenke", "Xueshaojie6", "l850691579"].each do |wechatid|
      WxTestUser.create(site_id: mp_user.site_id, wx_id: wechatid)
      bind_tester(wechatid, "bind_tester", mp_user)
    end
    true
  end

  def bind_tester(wx_id, action, mp_user)
    request_params = { wechatid: wx_id }.to_json

    resp_info = commit(action, mp_user, request_params, "post")

    if action == "bind_tester" && resp_info["errcode"] == 0
      return "绑定体验者成功"
    elsif action == "unbind_tester" && resp_info["errcode"] == 0
      return "解绑体验者成功"
    else
      SiteLog::Base.logger("mpapi", "MiniProgramCommit #{mp_user.app_id}, #{action}, 操作失败:#{resp_info["errmsg"]}")
      return "操作失败#{resp_info["errmsg"]}"
    end
  end

  private

    def mini_program_api_url(action, mp_user)
      if mp_user.expires_in.to_s > Time.now.to_s
        "https://api.weixin.qq.com/wxa/#{action}?access_token=#{mp_user.access_token}"
      else
        "https://api.weixin.qq.com/wxa/#{action}?access_token=#{MpUserSetting.fetch_access_token(mp_user)}"
      end
    end

    def commit(action, mp_user, request_params, type)
      url = mini_program_api_url(action, mp_user)
      resp = type == "post" ? HTTParty.post(url, body: request_params) : HTTParty.get(url)

      SiteLog::Base.logger("mpapi", "MiniProgramCommit #{mp_user.app_id}, #{action}, request_params:#{request_params}, response: #{resp.body}")
      JSON.parse(resp.body)
    end
end

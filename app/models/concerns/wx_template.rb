module WxTemplate

  #订单支付通知-模板库编号：OPENTM200449480（OPENTM405584202 添加于20170504）
  def order_temp(touser)
    # remark = shop.basic_info_setting.hotline.present? ? "，若有疑虑请拨打客服热线#{shop.basic_info_setting.hotline}。" : "。"
    options = {
      touser:touser,
      template_id:"#{user.wx_user.wx_mp_user.new_order_wx_message_template_id}",
      url:"#{Settings.m_host}/wap/orders/#{id}",
      topcolor:"#FF0000",
      data:{
        first:{
          value:"您有一笔订单已经生成但尚未支付，请尽快到“我的订单”支付。",
          color:"#173177"
        },
        keyword1:{
          value:order_no,
          color:"#173177"
        },
        keyword2:{
          value:ec_order_items.collect{|i| i.product_name}.join(","),
          color:"#173177"
        },
        keyword3:{
          value:ec_order_items.sum(:qty),
          color:"#173177"
        },
        keyword4:{
          value:"#{total_amount}元",
          color:"#173177"
        },
        remark:{
          value:"订单24小时后自动取消",
          color:"#173177"
        }
      }
    }
  end

  #支付成功通知-模板库编号：OPENTM400231951
  def buy_temp(touser)
    options = {
      touser:touser,
      template_id:"#{user.wx_user.wx_mp_user.order_paid_wx_message_template_id}",
      url:"#{Settings.m_host}/wap/orders/#{id}",
      topcolor:"#FF0000",
      data:{
        first:{
          value:"您已支付成功，美酒即刻准备启程！",
          color:"#173177"
        },
        keyword1:{
          value:"#{total_amount}元",
          color:"#173177"
        },
        keyword2:{
          value:order_no,
          color:"#173177"
        },
        remark:{
          value:"感谢您选择喝吧，祝您生活愉快。",
          color:"#173177"
        }
      }
    }
  end

  #商品开始发货通知-模板库编号：OPENTM200303341（OPENTM400262692 添加于20170504）
  def packing_temp(touser)
    options = {
      touser:touser,
      template_id:"#{user.wx_user.wx_mp_user.order_packing_wx_message_template_id}",
      url:"#{Settings.m_host}/wap/orders/#{id}",
      topcolor:"#FF0000",
      data:{
        first:{
          value:"您好，你的商品已开始发货",
          color:"#173177"
        },
        keyword1:{
          value:ec_logistic_company.try(:name) || '喝吧配送团队',
          color:"#173177"
        },
        keyword2:{
          value:"#{logistic_no}",
          color:"#173177"
        },
        keyword3:{
          value:ec_order_items.collect{|i| i.product_name}.join(","),
          color:"#173177"
        },
        keyword4:{
          value:ec_order_items.sum(:qty),
          color:"#173177"
        },
        remark:{
          value:" ",
          color:"#173177"
        }
      }
    }
  end

  #商品发货通知-模板库编号：OPENTM200303341（OPENTM400262692 添加于20170504）
  def delivery_temp(touser)
    options = {
      touser: touser,
      template_id: "#{user.wx_user.wx_mp_user.order_delivered_wx_message_template_id}",
      url: "#{Settings.m_host}/wap/orders/#{id}",
      topcolor: "#FF0000",
      data: {
        first: {
          value: "您的美酒已经打包完毕，正在朝您飞奔而来！",
          color: "#173177"
        },
        keyword1: {
          value: ec_logistic_company.try(:name) || '喝吧配送团队',
          color: "#173177"
        },
        keyword2: {
          value: "#{logistic_no}",
          color: "#173177"
        },
        keyword3: {
          value: ec_order_items.collect{|i| i.product_name}.join(","),
          color: "#173177"
        },
        keyword4: {
          value: ec_order_items.sum(:qty),
          color: "#173177"
        },
        remark: {
          value: "酒类产品运输较为谨慎，还请小柜族耐心等待。",
          color: "#173177"
        }
      }
    }
  end

  #商品发货通知-模板库编号：OPENTM200303341（OPENTM400262692 添加于20170504）
  def arrived_temp(touser)
    options = {
      touser: touser,
      template_id: "#{user.wx_user.wx_mp_user.order_delivered_wx_message_template_id}",
      url: "#{Settings.m_host}/wap/orders/#{id}",
      topcolor: "#FF0000",
      data: {
        first: {
          value: "美酒已经送达，尽情享用吧！",
          color: "#173177"
        },
        keyword1: {
          value: ec_logistic_company.try(:name) || '喝吧配送团队',
          color: "#173177"
        },
        keyword2: {
          value: "#{logistic_no}",
          color: "#173177"
        },
        keyword3: {
          value: ec_order_items.collect{|i| i.product_name}.join(","),
          color: "#173177"
        },
        keyword4: {
          value: ec_order_items.sum(:qty),
          color: "#173177"
        },
        remark: {
          value: "如遇质量问题，烦请致电 400 8075 199 。餐桌美酒不用等，想喝就喝吧！",
          color: "#173177"
        }
      }
    }
  end


  # IT科技 - 互联网|电子商务 - 新订单通知 - 编号[OPENTM201785396] - 内容示例[管理员请注意，已收到新订单]
  def new_order_temp(touser)
    options = {
      touser:touser,
      template_id: "#{user.wx_user.wx_mp_user.new_order_wx_message_template_id}",
      # url: "http://#{site_id}.#{Settings.mhostname}/#{site_id}/shop_orders/#{id}?openid=#{touser}",
      topcolor:"#FF0000",
      data:{
        first:{
          value:"您收到了一条新的订单。",
          color:"#173177"
        },
        keyword1:{
          value:"#{order_no}",
          color:"#173177"
        },
        keyword2:{
          value:"#{order_type_wx_display}",
          color:"#173177"
        },
        keyword3:{
          value:"￥#{total_amount || 0.0}元",
          color:"#173177"
        },
        keyword4:{
          value:"#{created_at}",
          color:"#173177"
        },
        keyword5:{
          value:"#{description}",
          color:"#173177"
        },
        remark:{
          value:"#{order_detail}",
          color:"#173177"
        }
      }
    }

    if touser == user.wx_user.openid
      arr = options.to_a
      arr.insert(2, [:url, "#{Settings.m_host}/wap/orders/#{id}?openid=#{user.wx_user.openid}"])
      options = arr.to_h
    end

    options
  end

  def cancel_order_temp(touser)
    if touser == user.wx_user.openid
      title = "您的订单已取消"
      remark = "感谢您的支持，如有问题请联系客服"
    else
      title = "用户#{username}订单取消通知"
      remark = "#{order_detail}\n用户信息：#{user_info}"
    end  
    options = {
      touser: touser,
      template_id: "#{user.wx_user.wx_mp_user.cancel_order_wx_message_template_id}",
      # url: "http://#{site_id}.#{Settings.mhostname}/#{site_id}/shop_orders/#{id}?openid=#{touser}",
      topcolor:"#FF0000",
      data:{
        first:{
          value: title,
          color:"#173177"
        },
        keyword1:{
          value:"#{order_no}",
          color:"#173177"
        },
        keyword2:{
          value:"#{created_at}",
          color:"#173177"
        },
        keyword3:{
          value:"￥#{total_amount || 0.0}元",
          color:"#173177"
        },
        keyword4:{
          value:"#{updated_at}",
          color:"#173177"
        },
        remark:{
          value: remark,
          color:"#173177"
        }
      }
    }

    if touser == user.wx_user.openid
      arr = options.to_a
      arr.insert(2, [:url, "#{Settings.m_host}/wap/orders/#{id}?openid=#{user.wx_user.openid}"])
      options = arr.to_h
    end

    options
  end  

  def order_delivery_temp(touser)
    options = {
      touser:touser,
      template_id: "#{user.wx_user.wx_mp_user.new_order_wx_message_template_id}",
      # url: "http://#{site_id}.#{Settings.mhostname}/#{site_id}/shop_orders/#{id}?openid=#{touser}",
      topcolor:"#FF0000",
      data:{
        first:{
          value:"您的订单已经发货，请您耐心等待！",
          color:"#173177"
        },
        keyword1:{
          value:"#{order_no}",
          color:"#173177"
        },
        keyword2:{
          value:"#{order_no}",
          color:"#173177"
        },
        keyword3:{
          value:"#{order_detail}",
          color:"#173177"
        },
        keyword4:{
          value:"￥#{total_amount || 0.0}元",
          color:"#173177"
        },
        remark:{
          value:"收货地址：#{address}#{order_detail}",
          color:"#173177"
        }
      }
    }

    if touser == user.wx_user.openid
      arr = options.to_a
      arr.insert(2, [:url, "#{Settings.m_host}/wap/orders/#{id}?openid=#{user.wx_user.openid}"])
      options = arr.to_h
    end

    options
  end

  #微信模板消息接口
  #return: {"errcode":0,"errmsg":"ok","msgid":200228332}
  def send_wx_message_temp(origin_params)
    begin
      url = "https://api.weixin.qq.com/cgi-bin/message/template/send?access_token=#{origin_params[:access_token]}"
      res_api = HTTParty.post url, body: origin_params[:options].to_json
      Rails.logger.info "send_wx_message_temp result: #{res_api}"
    rescue Exception => e
      Rails.logger.error "send_wx_message_temp result: #{res_api}"
    end
  end

  def order_type_wx_display
    if self.is_a?(BookingOrder)
      '微服务订单'
    elsif self.is_a?(ShopOrder)
      "#{order_type_name}订单"
    else
      '其它'
    end
  end

end
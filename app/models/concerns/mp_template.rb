module MpTemplate
  #支付成功通知-模板库编号：OPENTM400231951
  def buy_temp(openid, form_id)
    options = {
      touser: openid,
      # template_id: "5sG8r29g8E1KMxOLgfYM4EnVdmGbn5M8Zqa9wtybg9Y",
      template_id:"#{user.wx_user.wx_mp_user.order_paid_wx_message_template_id}",
      form_id: form_id,
      # page: "pages/ec/order-detail/order-detail?id=#{id}&status=#{status_name}",
      page: "pages/user/my-center",
      color:"#FF0000",
      data:{
        keyword1:{
          value:"#{pay_amount}元",
          color:"#173177"
        },
        keyword2:{
          value:order_no,
          color:"#173177"
        },
        keyword3:{
          value:paid_at.to_s,
          color:"#173177"
        },
        keyword4:{
          value:"#{ec_items.map{|e| e.try(:ec_product).try(:name)}.uniq.join(",")}",
          color:"#173177"
        }
      },
      emphasis_keyword: "keyword1.data"
    }
  end

  #商品开始发货通知-模板库编号：OPENTM200303341（OPENTM400262692 添加于20170504）
  def delivery_temp(openid, form_id)
    options = {
      touser:openid,
      # template_id: "PtXo8SsaD5FwdC1hR17qzRGkrmnG2z3S4SaDDr5Gb3I",
      template_id:"#{user.wx_user.wx_mp_user.order_packing_wx_message_template_id}",
      # url:"#{Settings.m_host}/wap/orders/#{id}",
      form_id: form_id,
      color:"#FF0000",
      data:{
        keyword1:{
          value:"#{ec_items.map{|e| e.try(:ec_product).try(:name)}.uniq.join(",")}",
          color:"#173177"
        },
        keyword2:{
          value:order_no,
          color:"#173177"
        },
        keyword3:{
          value:Time.now.strftime("%Y年%m月%d日"),
          color:"#173177"
        },
        keyword4:{
          value:username,
          color:"#173177"
        },
        keyword5:{
          value:mobile,
          color:"#173177"
        },
        keyword6:{
          value: "卖家已发货，请注意查收！",
          color:"#173177"
        }
      },
      emphasis_keyword: "keyword1.data"
    }
  end

  def send_mp_message_temp(origin_params)
    Rails.logger.info "send_wx_message_temp result: #{origin_params}"
    begin
      url = "https://api.weixin.qq.com/cgi-bin/message/wxopen/template/send?access_token=#{origin_params[:access_token]}"
      res_api = HTTParty.post url, body: origin_params[:options].to_json
      Rails.logger.info "send_wx_message_temp result: #{res_api}"
    rescue Exception => e
      Rails.logger.error "send_wx_message_temp result: #{res_api}"
    end
  end

end

class Wap::BaseController < ActionController::Base
  include ErrorHandler, DetectUserAgent, JsapiHelper

  before_filter :setup_jsapi

  layout 'wap/main'

  before_filter :redirect_to_non_openid_url, :load_site, :require_wx_mp_user, :load_user_data, :load_shop, except: [:notice]

  before_filter :auth, if: -> { @wx_mp_user.try(:manual?) }
  # before_filter :authorize, if: -> { @wx_mp_user.try(:plugin?) }
  before_filter :fetch_wx_user_info

  helper_method :judge_andriod_version, :wx_browser?, :display_wday, :shared_pic

  def display_wday(date)
    wday = date.to_date.wday
    case wday.to_i
    when 0
        '星期日'
    when 1
        '星期一'
    when 2
        '星期二'
    when 3
        '星期三'
    when 4
        '星期四'
    when 5
        '星期五'
    when 6
        '星期六'
    end
  end

  def shared_pic
    default_pic_url = "#{Settings.m_host}/wap/assets/images/logo.png"

    if controller_name =~ /categories/
    elsif controller_name =~ /items/ && action_name =~ /index/
      category = EcCategory.where(id: params[:category_id]).first
      default_pic_url = category.format_pic_url if category.present?
    elsif controller_name =~ /items/ && action_name =~ /show/
      default_pic_url = @item.format_pic_url if @item.present?
    elsif controller_name =~ /shops/
      default_pic_url = @shop.format_logo_url if @shop.present?
    end

    default_pic_url
  end

end
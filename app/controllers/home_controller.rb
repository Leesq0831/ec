class HomeController < ApplicationController
  include Biz::HighchartHelper

  skip_before_filter *ADMIN_FILTERS, except: [:console]
  skip_before_filter :check_account_expire, :check_auth_mobile#, only: [:index, :console]

  before_filter :set_dates, :set_data, only: [:console]

  # caches_page :about

  def index
    if current_user && current_user.is_a?(Account)
      redirect_to console_path
    else
      @html_class = 'index'
      redirect_to sign_in_path
    end
  end

  def console
    @high_chart = {"订单数" => {}, "待付款" => {}, '待发货' => {}, "待收货" => {}, "已完成" => {}}
    @data = {'today' => {}, 'yesterday' => {}, 'seven' => {}, 'month' => {}, 'all' => {}}

    @data['all']['总订单'] = @total_orders.to_i
    #月
    
    @data['month']['订单数'] = @month_total_orders.to_i
    #@data['month']['待付款'] = @month_pending_orders.to_i
    @data['month']['待发货'] = @month_waiting_orders.to_i
    @data['month']['已完成'] = @month_finish_orders.to_i
    @data['month']['待收货'] = @month_delivered_orders.to_i

    #周
    @data['seven']['订单数'] = @seven_total_orders.to_i
    #@data['seven']['待付款'] = @seven_pending_orders.to_i
    @data['seven']['待发货'] = @seven_waiting_orders.to_i
    @data['seven']['已完成'] = @seven_finish_orders.to_i
    @data['seven']['待收货'] = @seven_delivered_orders.to_i



    @dates.each do |date|
      @high_chart.keys.each do |key|
        @high_chart[key][date.to_s] = 0
      end
    end

    requests = current_user.ec_orders.orders_all.where(created_at: @dates).select("DATE_FORMAT(created_at, '%Y-%m-%d') as dataformat").select("count(*) as counts").group("dataformat")
    requests.each do |r|
      @high_chart["订单数"][r.dataformat.to_s] = r.counts 
    end

    requests = current_user.ec_orders.finished.where(created_at: @dates).select("DATE_FORMAT(created_at, '%Y-%m-%d') as dataformat").select("count(*) as counts").group("dataformat")
    requests.each do |r|
      @high_chart["已完成"][r.dataformat.to_s] = r.counts 
    end

    requests = current_user.ec_orders.waiting.where(created_at: @dates).select("DATE_FORMAT(created_at, '%Y-%m-%d') as dataformat").select("count(*) as counts").group("dataformat")
    requests.each do |r|
      @high_chart["待发货"][r.dataformat.to_s] = r.counts 
    end

    requests = current_user.ec_orders.pending.where(created_at: @dates).select("DATE_FORMAT(created_at, '%Y-%m-%d') as dataformat").select("count(*) as counts").group("dataformat")
    requests.each do |r|
      @high_chart["待付款"][r.dataformat.to_s] = r.counts 
    end

    requests = current_user.ec_orders.delivered.where(created_at: @dates).select("DATE_FORMAT(created_at, '%Y-%m-%d') as dataformat").select("count(*) as counts").group("dataformat")
    requests.each do |r|
      @high_chart["待收货"][r.dataformat.to_s] = r.counts 
    end

    @chart = WxLog.multi_line(@dates.to_a, @high_chart, "#{@st.strftime("%Y-%m-%d")} 至 #{@ed.strftime("%Y-%m-%d")} 订单报告", "订单数量")

    if @dates.count == 1
      @high_chart['订单数'][@ed.to_s] = @high_chart['订单数'][@ed.to_s]
    end

    #销量前5
    @hot_products = current_user.ec_items.show.select("ec_product_id, sum(sold_qty) as sold").group("ec_product_id").order("sold desc").limit(5)

    respond_to do |format|
      format.html do
        #@activities = current_user.activities.active.unexpired.where(activity_type_id: ActivityType::ACTIVITY_IDS)
        render layout: 'application'
      end
      format.js do
        @piwik_sites = PiwikSite.where(:site_id => current_user.id)
        @total_vip_users = current_user.vip_users.normal_and_freeze
        @all_wx_requests = WxRequest.where(site_id: current_user.id).select('date, increase, subscribe')

        total_pv_count = @piwik_sites.sum(:nb_actions)
        total_uv_count = @piwik_sites.sum(:nb_visits)
        @total_pv_count = total_pv_count
        @total_uv_count = total_uv_count

        @yesterday_piwik_site = @piwik_sites.where(date: Date.yesterday).first

        @today = Date.today
        @total_vip_user_count = @total_vip_users.count
        @yesterday_vip_user_count = @total_vip_users.where("date(created_at) = ?", Date.yesterday).count

        total_subscribes = @all_wx_requests.sum(:increase)
        @total_subscribe_count = total_subscribes

        @yesterday_wx_request  = @all_wx_requests.where(date: Date.yesterday..Date.today).first
        @yesterday_subscribe_count = @yesterday_wx_request.try(:increase).to_i

        @pv_categories, @pv_data = @piwik_sites.get_recent_data(current_user.id, 'nb_actions', 'recent_30')
        @uv_categories, @uv_data = @piwik_sites.get_recent_data(current_user.id, 'nb_uniq_visitors', 'recent_30')

        @vip_user_categories, @vip_user_data, @start_time, @end_time, min_tick = cube_chart_data_for_datacube_vip_card(@total_vip_users, 'one_months', Date.yesterday)

        @subscribe_data = {}
        @subscribe_categories = []
        @dates = ((Date.yesterday - 30)..Date.yesterday).to_a
        @dates.each do |date|
          @subscribe_data[date.to_s] = 0
          @subscribe_categories << date.try(:strftime, "%m/%d")
        end

        requests = @all_wx_requests.where(["date >= ? and date <= ?", @dates.first, @dates.last])
        requests.each do |r|
          @subscribe_data[r.date.to_s] = r.subscribe
        end
      end
    end

    
  end

  def help_menus
    @help_menus = HelpMenu.order(:sort)
    render layout: 'application'
  end

  def help_post
    @help_menu = HelpMenu.where(id: params[:id].to_i).first
    return redirect_to root_url, alert: '页面不存在' unless @help_menu

    render layout: 'application'
  end

  def verify_code
    image = VerifyCode.new(4)
    session[:image_code] = image.code
    send_data image.code_image, :type => 'image/jpeg', :disposition => 'inline'
  end

  def validate_image_code
    if session[:image_code] != params[:image_code]
      return render json: {code: -1, message: "验证码错误!", num: 3, status: 0}
    else
      return render json: {code: 1}
    end
  end

  def not_found
    render "404_#{detect_browser}", layout: "mobile" != detect_browser, :status => 404
  end

  def error
    render "500_#{detect_browser}", layout: "mobile" != detect_browser
  end

  private

  MOBILE_BROWSERS = ["playbook", "windows phone", "android", "ipod", "iphone", "opera mini", "blackberry", "palm","hiptop","avantgo","plucker", "xiino","blazer","elaine", "windows ce; ppc;", "windows ce; smartphone;","windows ce; iemobile", "up.browser","up.link","mmp","symbian","smartphone", "midp","wap","vodafone","o2","pocket","kindle", "mobile","pda","psp","treo"]

  def detect_browser
    agent = request.user_agent.to_s.downcase

    MOBILE_BROWSERS.each do |m|
      return "mobile" if agent.match(m)
    end
    return "desktop"
  end

  def print_f(float)
    num = format("%0.1f", float)
    b = 7 - num.length #最大5位数
    b = 0 if b < 0
    ret = " " * b + num.to_s
    ret
  end

  def set_dates
    if params[:start_at_and_end_at].present?
      @st = Date.parse(params[:start_at_and_end_at].split(' - ').first)
      @ed = Date.parse(params[:start_at_and_end_at].split(' - ').last)
    else
      if params[:type].present?
        case params[:type]
          when 'seven' then
            @st = Date.today - 6.days
            @ed = Date.today
          when 'month' then
            @st = Date.today - 1.month + 1.days
            @ed = Date.today
        end
      else
        @st = Date.today - 6.days
        @ed = Date.today
      end
    end
    params[:start_at_and_end_at] = [@st, @ed].join(' - ')
    @dates = (@st..@ed)
  end

  def set_data
    #总数据
    @total_orders = current_user.ec_orders.orders_all.count
    @pending_orders = current_user.ec_orders.pending.count
    @waiting_orders = current_user.ec_orders.waiting.count

    #月
    @month_total_orders = current_user.ec_orders.orders_all.where(created_at: ((Date.today - 1.month + 1.days)..Date.today)).count
    @month_waiting_orders = current_user.ec_orders.waiting.where(created_at: ((Date.today - 1.month + 1.days)..Date.today)).count
    #@month_pending_orders = current_user.ec_orders.pending.where(created_at: ((Date.today - 1.month + 1.days)..Date.today)).count
    @month_finish_orders = current_user.ec_orders.finished.where(created_at: ((Date.today - 1.month + 1.days)..Date.today)).count
    @month_delivered_orders = current_user.ec_orders.delivered.where(created_at: ((Date.today - 1.month + 1.days)..Date.today)).count

    #周
    @seven_total_orders = current_user.ec_orders.orders_all.where(created_at: ((Date.today - 6.days)..Date.today)).count
    #@seven_pending_orders = current_user.ec_orders.pending.where(created_at: ((Date.today - 6.days)..Date.today)).count    
    @seven_waiting_orders = current_user.ec_orders.waiting.where(created_at: ((Date.today - 6.days)..Date.today)).count
    @seven_finish_orders = current_user.ec_orders.finished.where(created_at: ((Date.today - 6.days)..Date.today)).count
    @seven_delivered_orders = current_user.ec_orders.delivered.where(created_at: ((Date.today - 6.days)..Date.today)).count

    # #昨日
    # @yesterday_total_orders = current_user.ec_orders.orders_all.where(created_at: Date.yesterday..Date.today).count
    # @yesterday_pending_orders = current_user.ec_orders.pending.where(created_at: Date.yesterday..Date.today).count
    # @yesterday_waiting_orders = current_user.ec_orders.pending.where(created_at: Date.yesterday..Date.today).count
    params[:VCFields] ||= 'message'
  end


end

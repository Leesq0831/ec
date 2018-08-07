class Api::MiniProgram::OrderDataController < ApplicationController

  before_filter :set_dates, :set_data

  def index
    @high_chart = {"订单数" => {}, "待付款" => {},"待收货" => {}, "已完成" => {}, '待发货' => {}}
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

    requests = current_site.ec_orders.orders_all.where(created_at: @dates).select("DATE_FORMAT(created_at, '%Y-%m-%d') as dataformat").select("count(*) as counts").group("dataformat")
    requests.each do |r|
      @high_chart["订单数"][r.dataformat.to_s] = r.counts 
    end

    requests = current_site.ec_orders.finished.where(created_at: @dates).select("DATE_FORMAT(created_at, '%Y-%m-%d') as dataformat").select("count(*) as counts").group("dataformat")
    requests.each do |r|
      @high_chart["已完成"][r.dataformat.to_s] = r.counts 
    end

    requests = current_site.ec_orders.waiting.where(created_at: @dates).select("DATE_FORMAT(created_at, '%Y-%m-%d') as dataformat").select("count(*) as counts").group("dataformat")
    requests.each do |r|
      @high_chart["待发货"][r.dataformat.to_s] = r.counts 
    end

    requests = current_site.ec_orders.pending.where(created_at: @dates).select("DATE_FORMAT(created_at, '%Y-%m-%d') as dataformat").select("count(*) as counts").group("dataformat")
    requests.each do |r|
      @high_chart["待付款"][r.dataformat.to_s] = r.counts 
    end

    requests = current_site.ec_orders.delivered.where(created_at: @dates).select("DATE_FORMAT(created_at, '%Y-%m-%d') as dataformat").select("count(*) as counts").group("dataformat")
    requests.each do |r|
      @high_chart["待收货"][r.dataformat.to_s] = r.counts 
    end

    @chart = WxLog.multi_line(@dates.to_a, @high_chart, "#{@st.strftime("%Y-%m-%d")} 至 #{@ed.strftime("%Y-%m-%d")} 订单报告", "订单数量")

    if @dates.count == 1
      @high_chart['订单数'][@ed.to_s] = @high_chart['订单数'][@ed.to_s]
    end

    #销量前5
    @hot_products = current_site.ec_items.show.select("ec_product_id, sum(sold_qty) as sold").group("ec_product_id").order("sold desc").limit(5)
  end


  private

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
    @total_orders = current_site.ec_orders.orders_all.count
    @pending_orders = current_site.ec_orders.pending.count
    @waiting_orders = current_site.ec_orders.waiting.count

    #月
    @month_total_orders = current_site.ec_orders.orders_all.where(created_at: ((Date.today - 1.month + 1.days)..Date.today)).count
    @month_waiting_orders = current_site.ec_orders.waiting.where(created_at: ((Date.today - 1.month + 1.days)..Date.today)).count
    #@month_pending_orders = current_site.ec_orders.pending.where(created_at: ((Date.today - 1.month + 1.days)..Date.today)).count
    @month_finish_orders = current_site.ec_orders.finished.where(created_at: ((Date.today - 1.month + 1.days)..Date.today)).count
    @month_delivered_orders = current_site.ec_orders.delivered.where(created_at: ((Date.today - 1.month + 1.days)..Date.today)).count

    #周
    @seven_total_orders = current_site.ec_orders.orders_all.where(created_at: ((Date.today - 6.days)..Date.today)).count
    #@seven_pending_orders = current_site.ec_orders.pending.where(created_at: ((Date.today - 6.days)..Date.today)).count    
    @seven_waiting_orders = current_site.ec_orders.waiting.where(created_at: ((Date.today - 6.days)..Date.today)).count
    @seven_finish_orders = current_site.ec_orders.finished.where(created_at: ((Date.today - 6.days)..Date.today)).count
    @seven_delivered_orders = current_site.ec_orders.delivered.where(created_at: ((Date.today - 6.days)..Date.today)).count

    # #昨日
    # @yesterday_total_orders = current_site.ec_orders.orders_all.where(created_at: Date.yesterday..Date.today).count
    # @yesterday_pending_orders = current_site.ec_orders.pending.where(created_at: Date.yesterday..Date.today).count
    # @yesterday_waiting_orders = current_site.ec_orders.pending.where(created_at: Date.yesterday..Date.today).count
    params[:VCFields] ||= 'message'
  end

end

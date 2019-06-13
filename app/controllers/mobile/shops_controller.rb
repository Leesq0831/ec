class Mobile::ShopsController < Mobile::BaseController
  layout 'mobile/food'

  before_filter :require_wx_user

  def index
    if @site
      @search = @site.shop.shop_branches.used.joins(:shop_menu).search(params[:search])
      @shop_branches = @search.order(:id).page(params[:page])
      respond_to do |format|
        format.html{}
        format.js{}
      end
    else
      redirect_to four_o_four_url
    end
  end

  def book_table
    if @site
      @search = @site.shop.shop_branches.used.search(params[:search])
      @shop_branches = @search.order(:id)
      respond_to do |format|
        format.html{
          redirect_to book_table_mobile_shop_branch_url(site_id: session[:site_id], id: @shop_branches.first.id) if @shop_branches.count == 1
        }
        format.js{}
      end
    else
      redirect_to four_o_four_url
    end
  end

  def book_dinner
    @search = @site.shop.shop_branches.used.order(:sort).joins(:shop_menu).search(params[:search])
    @shop_branches = @search.order(:id)
    respond_to do |format|
      format.html{
        redirect_to want_dinner_mobile_shop_branch_url(site_id: session[:site_id], id: @shop_branches.first.id) if @shop_branches.count == 1
      }
      format.js{}
    end
  end

  def take_out
    @search = @site.shop.shop_branches.used.order(:sort).joins(:shop_menu).search(params[:search])
    @shop_branches = @search.order(:id)
    respond_to do |format|
      format.html{
        redirect_to take_out_mobile_shop_branch_url(site_id: session[:site_id], id: @shop_branches.first.id) if @shop_branches.count == 1
      }
      format.js{}
    end
  end
end

class Api::MiniProgram::HomeController < Api::MiniProgram::BaseController
  skip_before_filter :verify_authenticity_token
  skip_before_filter :set_wx_mp_user, only: [:logistics]
  before_filter :set_wx_user, only: [:add_cart, :cart_num]

  # 轮播图片
  def swip_slides
    @slides = @current_account.ec_slides.swipe
    ids = []
    @current_account.employees.first.employee_roles.each{|role| ids << role.permission_ids } rescue nil

    render json: {
      slides: @slides.map{|s| [s.pic_url, s.url]},
      template: ids.flatten.uniq,
      template_id: @current_account.try(:ec_template_id) || 1,
      mobile: @current_account.try(:tel),
      name: @current_mp_user.nickname,
      cashpay: @current_account.try(:cashpay).to_i
    }
  end

  # Banner广告活动
  def banner_slides
    @banners = @current_account.ec_slides.banner
    render json: {banners: @banners.map{|s| [s.pic_url, s.url]} }
  end

  def home_menu
    @categories = @current_account.ec_slides.home_menu
    render json: {categories: @categories.map{|s| [s.pic_url, s.url, s.title]} }
  end

  # 推荐商品菜单
  def banner_products
    @categories = @current_account.ec_categories.onshelf.product_category.recommend
    respond_to :json
  end

  # 推荐商品列表
  def index_products
    @categories = @current_account.ec_categories.onshelf.product_category.recommend
    respond_to do |format|
      format.json {render "api/mini_program/home/banner_products" }
    end
  end

  # 搜索
  def search
    return render json: {products: []} if params[:name].blank?
    @products = @current_account.ec_products.onshelf.where("name like ?", "%#{params[:name]}%").order("ec_products.position asc")
    respond_to :json
  end

  # 添加到购物车
  def add_cart
    return render json: {code: -2, errormsg: "暂未登录"} unless @current_user

    @ec_item = @current_account.ec_items.find_by_id(params[:item_id])
    return render json: {code: -1, errormsg: "该规格不存在"} unless @ec_item
    return render json: {code: 0, errormsg: "商品库存不足"} if @ec_item.qty < 1
    @cart_item = @current_user.ec_cart_items.where(ec_item_id: @ec_item.id).first_or_initialize(qty: params[:qty] || 1, ec_shop_id: 1, original_price: @ec_item.price)

    if @cart_item.new_record? && @cart_item.save
      render json: {code: 1, errormsg: "ok"}
    elsif @cart_item.increment!(:qty, params[:qty] || 1)
      render json: {code: 1, errormsg: "ok"}
    else
      render json: {code: 0, errormsg: "商品库存不足"}
    end
  end

  def cart_num
    cart_num = @current_user.ec_cart_items.sum(:qty) rescue 0
    render json: {cart_num: cart_num, version: @current_mp_user.try(:user_version).to_s, mobile: @current_account.try(:tel)}
  end

  def get_areas
    @provinces = Province.all
    respond_to :json
  end

  def get_info
    account = @current_account
    return render json: {code: 1, errormsg: "ok", des: account.try(:description), name: @current_mp_user.nickname, qr: qiniu_image_url(@current_mp_user.mp_code), mobile: @current_account.try(:tel), lng: @current_account.try(:lng), lat: @current_account.try(:lat), address: @current_account.try(:address) } #if @current_mp_user.mp_code
    url = "http://upload.qiniu.com/putb64/-1"
    w_url = "https://api.weixin.qq.com/wxa/getwxacodeunlimit?access_token=#{@current_mp_user.wx_access_token}" 
    qr = HTTParty.post(w_url, body: {scene: "scene", page: 'pages/index/index'}.to_json)

    if qr["content-disposition"]
      headers = {
        "Content-Type"=>"application/octet-stream",
        "Authorization"=>"UpToken #{qiniu_pictures_upload_token}"
      }
      r = HTTParty.post(url, headers: headers, body: Base64.strict_encode64(resp.body))
      @current_mp_user.update_attributes(mp_code: r["key"]) if r["key"]
    end

    render json: {code: 1, errormsg: "ok", des: account.try(:description), name: @current_mp_user.nickname, qr: qiniu_image_url(@current_mp_user.mp_code), mobile: @current_account.try(:tel), lng: @current_account.try(:lng), lat: @current_account.try(:lat), address: @current_account.try(:address) }
  end

  def logistics
    return redirect_to "https://m.kuaidi100.com/result.jsp?nu=#{params[:no]}"
  end

end

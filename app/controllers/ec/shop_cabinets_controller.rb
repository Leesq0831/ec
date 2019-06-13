class Ec::ShopCabinetsController < Ec::BaseController

  def index
    if params[:ec_shop_id].present?
      @search = EcShopCabinet.where(ec_shop_id:params[:ec_shop_id]).search(params[:search])
      @ec_shop_cabinets = @search.order("created_at desc").page(params[:page])
    else
      @search = EcShopCabinet.search(params[:search])
      @ec_shop_cabinets = @search.order("created_at desc").page(params[:page])
    end
  end

  def new
    @ec_shop_cabinet = EcShopCabinet.new
    render layout: 'application_pop'

  end

  def create
    @ec_shop_cabinet = EcShopCabinet.new(params[:ec_shop_cabinet])
    if @ec_shop_cabinet.save
      flash[:notice] = '添加成功'
      render inline: "<script>parent.location.reload();</script>"
      else
      redirect_to :back, notice: "添加失败"
    end
  end

  def edit
    @ec_shop_cabinet = EcShopCabinet.find(params[:id])
    render layout: 'application_pop'

  end

  def update
    @ec_shop_cabinet = EcShopCabinet.find(params[:id])
    if @ec_shop_cabinet.update_attributes(params[:ec_shop_cabinet])
     flash[:notice] = '添加成功'
      render inline: "<script>parent.location.reload();</script>"
    else
      redirect_to :back, notice: "添加失败"
    end
  end

  def destroy
    @ec_shop_cabinet = EcShopCabinet.find(params[:id])
    if @ec_shop_cabinet.destroy
      redirect_to ec_shop_cabinets_path, notice: "删除成功！"
    else
      redirect_to :back, notice: "删除失败！"
    end
  end

end

class Ec::ShopRecommendsController < Ec::BaseController

  def index
    @search = EcShopRecommend.search(params[:search])
    @ec_shop_recommends = @search.order(:position).page(params[:page])
  end

  def show
    @ec_shop_recommend = EcShopRecommend.find(params[:id])
    @ec_shop_recommend_details = @ec_shop_recommend.ec_shop_recommend_details

    @search = EcItem.onshelf.product.show.search(params[:search])
    @ec_items = @search.page(params[:page])
  end

  def new
    @ec_shop_recommend = EcShopRecommend.new
    render layout: 'application_pop'
  end

  def create
    @ec_shop_recommend = EcShopRecommend.new(params[:ec_shop_recommend])
    if @ec_shop_recommend.save
      flash[:notice] = '创建成功'
      render inline: "<script>parent.location.reload();</script>"
      else
      redirect_to :back, alert: "添加失败"
    end
  end

  def edit
    @ec_shop_recommend = EcShopRecommend.find(params[:id])
    render layout: 'application_pop'
  end

  def update
    @ec_shop_recommend = EcShopRecommend.find(params[:id])

    if @ec_shop_recommend.update_attributes(params[:ec_shop_recommend])
      flash[:notice] = '操作成功'
      render inline: "<script>parent.location.reload();</script>"
      # redirect_to ec_shop_recommends_path, notice: "添加成功"
    else
      redirect_to :back, alert: "操作失败"
    end
  end

  def change
    @ec_shop_recommend = EcShopRecommend.find(params[:id])
    if params[:ec_shop_recommend] && params[:ec_shop_recommend][:ec_item_ids]
      @ec_shop_recommend.ec_item_ids = @ec_shop_recommend.ec_item_ids + params[:ec_shop_recommend][:ec_item_ids]
      @ec_shop_recommend.save
      redirect_to :back, notice: "操作成功"
    else
      redirect_to :back, alert: "操作失败"
    end
  end

  def destroy
      @ec_shop_recommend = EcShopRecommend.find(params[:id])
    if @ec_shop_recommend.destroy
      redirect_to :back, notice: "删除成功！"
    else
      redirect_to :back, alert: "删除失败！"
    end
  end

  def del
    @ec_shop_recommend_detail = EcShopRecommendDetail.find(params[:id])
    if @ec_shop_recommend_detail.destroy
    redirect_to :back, notice: "删除成功！"
    else
    redirect_to :back, alert: "删除失败！"
    end
  end

  def delete
    EcShopRecommendDetail.where(id: params[:ids]).delete_all
    redirect_to :back, notice: "删除成功！"
  end

end
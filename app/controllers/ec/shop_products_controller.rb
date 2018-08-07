class Ec::ShopProductsController < Ec::BaseController

  def edit
    @ec_shop = EcShop.find(params[:id])
    @ec_shop_products = EcShopProduct.where(ec_shop_id: params[:id])
    # render layout: 'application_pop'

    @search = EcProduct.onshelf.search(params[:search])
    @ec_products = @search.page(params[:page])
  end

  def update
    @ec_shop = EcShop.find(params[:id])
    # if @ec_shop.update_attributes(params[:ec_shop])
    if params[:ec_shop] && params[:ec_shop][:ec_product_ids]
      @ec_shop.ec_product_ids = @ec_shop.ec_product_ids + params[:ec_shop][:ec_product_ids]
      @ec_shop.save
      redirect_to :back, notice: '商品设置成功'
    else
      redirect_to :back, alert: '请先勾选商品'
    end
  end

  def destroy
    @ec_shop_product = EcShopProduct.find(params[:id])
    if @ec_shop_product.destroy
      redirect_to :back, notice: "删除成功！"
    else
      redirect_to :back, alert: "删除失败！"
    end
  end

  def delete
    EcShopProduct.where(id: params[:ids]).delete_all
    redirect_to :back, notice: "删除成功！"
  end
end

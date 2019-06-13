class Mobile::ShopOrderItemsController < Mobile::BaseController
  before_filter :require_wx_user

  def minus
    @item = ShopOrderItem.find(params[:id])
    @shop_order = @item.shop_order
    @product = @item.shop_product
    if @item.qty == 1
      @item.destroy
    else
      @item.qty = @item.qty - 1
      @item.save!
    end
    respond_to do |format|
      format.js {}
    end
  end

  def plus
    @item = ShopOrderItem.find(params[:id])
    @shop_order = @item.shop_order
    @product = @item.shop_product

    if @user.take_out_new_user? && @product.new_user_activity? && @shop_order.shop_order_items.reload.pluck(:shop_product_id).include?(@product.id)
    else
      if (@item.shop_product.quantity.present? && @item.qty + 1 <= @item.shop_product.quantity) || @item.shop_product.quantity.blank?
        @item.qty = @item.qty + 1
      else
        return render js: "alert('当前库存不足');$('.porduct-number-of-#{@product.id}').val(#{@item.try(:qty) || 0})"
      end
    end

    @item.save!
    respond_to do |format|
      format.js {}
    end
  end

  def change
    @item = ShopOrderItem.find(params[:id])
    @shop_order = @item.shop_order
    @product = @item.shop_product
    @item.qty = params[:number]
    @item.save!
    respond_to do |format|
      format.js {}
    end
  end
end
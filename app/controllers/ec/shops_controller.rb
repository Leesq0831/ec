class Ec::ShopsController < Ec::BaseController
	def index
		@search = EcShop.search(params[:search])
		@ec_shops = @search.page(params[:page])
	end

	def new
		@ec_shop = EcShop.new(province_id: nil, city_id: nil, district_id: nil)
	end

	def create
		@ec_shop = EcShop.new(params[:ec_shop])
		if @ec_shop.save
			flash[:notice] = '餐厅创建成功！'
			redirect_to ec_shops_path
		else
			redirect_to :back, alert: "餐厅创建失败！"
		end
	end

	def edit
		@ec_shop = EcShop.find(params[:id])
	end

	def update
		@ec_shop = EcShop.find(params[:id])
		if @ec_shop.update_attributes(params[:ec_shop])
			flash[:notice] = '餐厅信息更新成功！'
	    redirect_to ec_shops_path
		else
			redirect_to :back, alert: "餐厅信息修改失败！"
		end
	end

	def qrcode
		@ec_shop = EcShop.find(params[:id])
		render layout: 'application_pop'
	end

	def destroy
		@ec_shop = EcShop.find(params[:id])
		if @ec_shop.deleted!
			redirect_to ec_shops_path, notice: "删除成功！"
		else
			redirect_to :back, alert: "删除失败！"
		end
	end

	def enabled
		@ec_shop = EcShop.find(params[:id])
		if @ec_shop.update_attributes(status: EcShop::PASS)
			redirect_to ec_shops_path, notice: "审核通过！"
		end
	end

	def disabled
		@ec_shop = EcShop.find(params[:id])
		if @ec_shop.update_attributes(status:EcShop::WAIT)
			redirect_to ec_shops_path, notice: "已禁用！"
		end
	end

end

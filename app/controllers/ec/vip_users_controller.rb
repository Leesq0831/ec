class Ec::VipUsersController < Ec::BaseController

	def index
		@search = VipUser.search(params[:search])
		@vip_users = @search.page(params[:page])

		respond_to do |format|
			format.html
			format.xls
		end
	end

end
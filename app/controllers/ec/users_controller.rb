class Ec::UsersController < Ec::BaseController

  def index
    @search = @current_site.users.search(params[:search])
    @users = @search.page(params[:page])

    respond_to do |format|
      format.html
      format.xls
    end
  end

end
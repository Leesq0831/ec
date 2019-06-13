class Wx::UsersController < ApplicationController
  PAGE_SIZE = 24

  before_filter :require_wx_mp_user

  before_filter do
    # @partialLeftNav = "/layouts/partialLeftWeixin"
    @users = @wx_mp_user.wx_users.page(params[:page]).per(PAGE_SIZE)
  end

  def index
    @search = @wx_mp_user.wx_users.order('created_at DESC').search(params[:search])
    @wx_users = @search.page(params[:page]).per(PAGE_SIZE)
  end

end

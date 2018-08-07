class Wap::FavoritesController < Wap::BaseController

  def index
    @favs = @user.ec_favorites.joins(:ec_item)
  end

  def destroy
    @fav = EcFavorite.where(id: params[:id].to_i).first
    render json: {code: @fav.try(:destroy) ? 1 : 0}
  end

end

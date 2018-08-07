class Mobile::LikesController < Mobile::BaseController
  def create
    @like = Like.new(params[:like])
    @likeable = @like.likeable
    @like_images = @like.likeable.likes.limit(10)
    respond_to do |format|
      if @like.save
        format.html { redirect_to :back }
        format.js
      else
        format.js
      end
    end
  end

  def destroy
    @like = Like.find(params[:id])
    @likeable = @like.likeable
    @like.destroy
    @like_images = @likeable.likes.limit(10)
    respond_to do |format|
      format.html { redirect_to :back }
      format.js
    end
  end
end

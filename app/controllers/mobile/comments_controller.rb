class Mobile::CommentsController < Mobile::BaseController
  def create
    _comment = params[:comment][:comment].split("://")
    pre_comment, __comment = _comment.first, _comment.last
    if params[:comment][:id].present? && pre_comment.present?
      @comment = Comment.where(id: params[:comment][:id]).first
      @comment.attributes = {reply: __comment, replied_at: Time.now}
    else
      @comment = Comment.new(params[:comment])
    end  
    
    respond_to do |format|
      if @comment.save
        @comments = @comment.commentable.comments
        format.html { redirect_to :back }
        format.js
      else
        format.js
      end
    end
  end

end

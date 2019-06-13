class Data::CommentsController < ApplicationController
  before_filter :set_comment, only: [:edit, :update, :destroy]

  def index
    @search = current_site.comments.search(params[:search])
    @comments = @search.page(params[:page]).order("id desc")
  end

  def edit
    render :form, layout: 'application_pop'
  end

  def update
    if @comment.update_attributes(reply: params[:comment][:reply], replied_at: Time.now)
      flash[:notice] = "回复评论成功"
      render inline: "<script>window.parent.document.getElementById('addGate').style.display='none';window.parent.location.reload();</script>"
    else
      redirect_to :back, alert: "更新失败，#{@comment.errors.full_messages.join('\n')}"
    end
  end

  def destroy
    @comment.destroy

    redirect_to comments_path, notice: "评论删除成功"
  end

  private
    def set_comment
      @comment = current_site.comments.where(id: params[:id]).first
    end

end

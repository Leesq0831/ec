class Wap::CommentsController < Wap::BaseController
  before_filter :find_comment, only: :show
  before_filter do
    @hidden_footer = true
  end

  def index
    @comments = @user.ec_comments.normal.order("created_at asc")
  end

  def new
    @order_items = EcOrderItem.where(ec_order_id: params[:order_id] )
  end

  def create
    if EcComment.save_multi(params[:data], @user, params[:order_id])
      respond_to do |format|
        format.json { render json: { code: 1} }
      end
    else
      respond_to do |format|
        format.json { render json: { code: 0} }
    end
  end

  end

  private

    def find_comment
      @comment = @user.ec_comments.normal.where(id: params[:id]).first
    end
end

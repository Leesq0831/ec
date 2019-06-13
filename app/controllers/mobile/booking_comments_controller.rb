class Mobile::BookingCommentsController < Mobile::BaseController
  layout "mobile/booking"

  before_filter :set_booking_item, only: [:index, :new]

  def new
    comment_params = {
      site_id: @booking_item.booking.site_id,
      commentable_id: @booking_item.id,
      commentable_type: @booking_item.class.to_s,
      commenter_id: @user.try(:id),
      commenter_type: @user.try(:class).to_s
    }
    @comment = Comment.new(comment_params)
    @comments = @booking_item.comments.order("created_at desc")
  end

  def create
    @comment = Comment.new(params[:comment])
    if @comment.save
      redirect_to :back
    else
      redirect_to :notice => "评论失败"
    end
  end

  def set_booking_item
    @booking = @site.bookings.where(id: params[:booking_id]).first
    @booking_item = @booking.booking_items.find(params[:booking_item_id])
    @comments = @booking_item.comments.order("created_at desc")
  rescue
    render :text => '商品不存在'
  end

end

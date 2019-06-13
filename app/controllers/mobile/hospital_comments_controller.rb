class Mobile::HospitalCommentsController < Mobile::BaseController
  layout "mobile/hospital"
  include LikeableCommentable

  before_filter :set_doctor_and_comments, only: [:index, :create, :new]

  def index
    @page_class = "detail"
  end

  def new
    @page_class = "detail"
    comments_partial(@hospital_doctor, @user)
  end

  def create
    @comment = Comment.new(params[:comment])
    if @comment.save
      redirect_to :back
    else
      render :back, notice: "评论失败"
    end
  end

  def set_doctor_and_comments
    @user = User.find(session[:user_id])
    @hospital = @site.hospital
    @hospital_doctor = @hospital.hospital_doctors.find(params[:id])
    @comments = @hospital_doctor.comments.order("created_at desc")
  end
end

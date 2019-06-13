class Api::MiniProgram::FeedbacksController < Api::MiniProgram::BaseController

  def create
    @feedback = @current_user.feedbacks.new(params[:feedback])
    if @feedback.save
      render json: {errcode: 1, errmsg: "ok"}
    else
      render json: {errcode: 40001, errmsg: "#{@feedback.errors.messages}"}
    end
  end

end

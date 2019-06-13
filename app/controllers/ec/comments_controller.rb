class Ec::CommentsController < Ec::BaseController
	before_filter :find_comment, only: [:show, :edit, :update, :destroy]
	def index
		@search = EcComment.search(params[:search])
		@ec_comments = @search.page(params[:page])
	end

	def edit
		render layout: 'application_pop'
	end

	def update
		if @ec_comment.update_attributes(reply: params[:ec_comment][:reply], replied_at: Time.now)
			flash[:notice] = '回复成功'
		    render inline: "<script>parent.location.reload();</script>"
		else
			redirect_to :back, notice: '回复失败'
		end
	end

	def show
		render layout: 'application_pop'
	end

	def destroy
		if @ec_comment.disabled!
			redirect_to :back, notice: '删除成功'
		else
			redirect_to :back, notice: '删除失败'
		end
	end

	private
	def find_comment
		@ec_comment = EcComment.find(params[:id])
	end
end
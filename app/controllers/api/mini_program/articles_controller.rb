class Api::MiniProgram::ArticlesController < Api::MiniProgram::BaseController

  skip_before_filter :set_wx_user
  #skip_before_filter :set_wx_user, :set_wx_mp_user
  before_filter :find_current_site

  #推荐分类和文章
  def index_categories
    @categories = @current_site.site_categories.onshelf.send(params[:category_type]).recommend
    respond_to :json
  end

  #分类列表
  def list_categories
    if params[:type] == "1"
      @categories = @current_site.site_categories.onshelf.news
    else
      @categories = @current_site.site_categories.onshelf.case
    end
    respond_to :json
  end

  #文章列表
  def index
    if params[:id]
      @articles = @current_site.site_categories.onshelf.where(id: params[:id]).first.site_articles.onshelf
    end
    respond_to :json
  end

  #文章详情
  def show
    @article = @current_site.site_articles.find(params[:id].to_i)
    return render json: {articles: []} unless @article
  end

  private

  def find_current_site
    #@current_site = Site.first
    @current_site = @current_mp_user.try(:site)
    raise ActiveRecord::RecordNotFound unless @current_site
  end

end

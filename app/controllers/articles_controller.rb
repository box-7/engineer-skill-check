class ArticlesController < ApplicationController
  def index
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)
    @article.author = current_user.id
    # add_params

    if @article.save
      redirect_to articles_url, notice: "「#{@article.title}」を登録しました。"
    else
      render :new
    end
  end

  def show
  end



  private

  def article_params
    params.require(:article).permit(:title, :content)
  end


end

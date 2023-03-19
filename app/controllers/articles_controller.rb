class ArticlesController < ApplicationController
  before_action :set_article, only: %i(edit update destroy)

  def index
    if params[:latest]
      @articles = Article.active.latest
    elsif params[:old]
      @articles = Article.active.old
    else
      @articles = Article.active.all
    end
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

  def edit
  end

  def update
    if @article.update(article_params)
      redirect_to articles_url, notice: "「#{@article.title}」を更新しました。"
    else
      render :edit
    end
  end

  def destroy
    ActiveRecord::Base.transaction do
      now = Time.now
      @article.update_column(:deleted_at, now)
    end

    redirect_to articles_url, notice: "「#{@article.title}」を削除しました。"
  end

  private

  def article_params
    params.require(:article).permit(:title, :content)
  end

  def set_article
    @article = Article.find(params["id"])
  end

end

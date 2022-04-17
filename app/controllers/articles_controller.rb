class ArticlesController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def index
    articles = Article.all.includes(:user).order(created_at: :desc)
    render json: articles, each_serializer: ArticleListSerializer
  end

  def show
    #set the initial value of 0
    session[:page_views] ||= 0
    #increment the value by 1 for every request
    session[:page_views] += 1
    
    #if user has 3 or less views, render the request article data
    if session[:page_views] <= 3
    article = Article.find(params[:id])
    render json: article
    else
      #if more than 3, render the custome message with status code 401, unauthorized
      render json: { error: "Maximum pageview limit reached" }, status: :unauthorized
    end
  end

  private

  def record_not_found
    render json: { error: "Article not found" }, status: :not_found
  end

end

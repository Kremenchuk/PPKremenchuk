class NewsController < ApplicationController
  before_action :find_news, only: [:show, :edit, :update, :destroy]

  def index
    @news = News.all
  end

  def news_admin_index
    @news = News.all
    @new_news = News.new
  end

  def show

  end

  def new
    @news = News.new
  end

  def edit
  end

  def create
    news = News.new(news_params)

    begin
      image_name = "news_#{(Time.now).to_i}_#{params[:photo].original_filename}"
      image_path = File.join(Rails.root,'public/assets/news')

      File.open(File.join(image_path, image_name),'wb') do |f|
        f.write(params[:photo].read)
      end

      news.photo = File.join('/news', image_name)

      news.save!
    end
    redirect_to news_admin_index_path
  end

  def update
    @news.update(news_params)

    redirect_to news_admin_index_path
  end


  def destroy
    @news.destroy
    redirect_to news_admin_index_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def find_news
      @news = News.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def news_params
      params.permit(:news_header, :short_text, :text, :news_date)
    end
end

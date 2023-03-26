class NewsController < ApplicationController
  before_action :check_if_admin, except: [:index, :show]
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
    begin
      news = News.new(news_params)

      if params[:photo].present?
        image_name = "news_#{(Time.now).to_i}_#{params[:photo].original_filename}"
        image_path = File.join(Rails.root,'/public/assets/news')
        if !File.directory?(File.join(Rails.root,'public/assets/news'))
          if !File.directory?(File.join(Rails.root,'public/assets'))
            Dir.mkdir(File.join(Rails.root,'public/assets'))
          end
          Dir.mkdir(File.join(Rails.root,'public/assets/news'))
        end
        File.open(File.join(image_path, image_name),'wb') do |f|
          f.write(params[:photo].read)
        end

        news.photo = File.join('/assets/news', image_name)
      end
      news.save!

    rescue => error
      flash_message("danger", "Невозможно создать новость. #{error.message}")
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
      params.permit(:news_date,
                    title: {},
                    short_text: {},
                    text: {} )
    end
end

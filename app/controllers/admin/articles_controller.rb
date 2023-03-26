module Admin
  class ArticlesController < Admin::ApplicationController
    before_action :find_article, only: [:edit, :destroy, :update]

    def index
      @articles = Article.all
      @images_to_articles = Image.all
    end

    def new
      @article = Article.new
    end

    def edit
    end

    def create
      Article.create!(article_params)
      redirect_to admin_articles_path
    end

    def update
      @article.update!(article_params)
      redirect_to admin_articles_path
    end

    def destroy
      @article.destroy!
      redirect_to admin_articles_path
    end

    def image_to_article
      begin
        if params[:image].present?
          image_name = "#{Time.now.to_i}_stm_industry_#{params[:image].original_filename}"
          image_path = File.join(Rails.root,'public/assets/articles')

          unless File.exist?(File.join(image_path))
            FileUtils.mkdir_p(image_path)
          end

          File.open(File.join(image_path, image_name),'wb') do |f|
            f.write(params[:image].read)
          end

          image = Image.new
          image.path_to_image = File.join('/assets/articles', image_name)
          image.save!
        else
          redirect_to admin_articles_path and return
        end
      end
      redirect_to admin_articles_path
    end

    def image_delete
      begin
        image = Image.find(params[:id])
        image_path = File.join(Rails.root,'public', image.path_to_image)
        File.delete(image_path) if File.exist?(image_path)
        image.destroy!
      end
      redirect_to admin_articles_path
    end

    private

    def article_params
      params.permit(title: {}, short_body: {}, body: {})
    end

    def find_article
      @article = Article.find(params[:id])
    end

  end
end
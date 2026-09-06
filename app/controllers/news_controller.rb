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
    @new_news = News.new(news_params)
    @new_news.photo = store_photo(params[:photo]) if params[:photo].present?

    if @new_news.save
      redirect_to news_admin_index_path
    else
      # Re-render instead of redirecting, so everything the admin typed
      # survives the round trip (a redirect drops the params). The file
      # input cannot be repopulated — browsers forbid it — so the photo
      # has to be picked again.
      reject("Невозможно создать новость", @new_news)
      @news = News.all
      render :news_admin_index, status: :unprocessable_entity
    end
  rescue => error
    flash_now("danger", "Невозможно создать новость. #{error.message}")
    @new_news ||= News.new(news_params)
    @news = News.all
    render :news_admin_index, status: :unprocessable_entity
  end

  def update
    if @news.update(news_params)
      redirect_to news_admin_index_path
    else
      reject("Невозможно сохранить новость", @news)
      render :edit, status: :unprocessable_entity
    end
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

    # Writes the uploaded file under public/assets/news and returns the
    # public path stored in the `photo` column.
    def store_photo(upload)
      image_name = "news_#{Time.now.to_i}_#{upload.original_filename}"
      image_dir  = Rails.root.join('public', 'assets', 'news')
      FileUtils.mkdir_p(image_dir)

      File.open(image_dir.join(image_name), 'wb') { |f| f.write(upload.read) }

      File.join('/assets/news', image_name)
    end

    # Validation errors read as "Картинка не може бути порожньою" — far more
    # useful than the bare RecordInvalid message the old `save!` produced.
    def reject(prefix, record)
      details = record.errors.full_messages.to_sentence
      flash_now("danger", details.present? ? "#{prefix}: #{details}." : "#{prefix}.")
    end

    # flash.now, not flash: the response is rendered, not redirected, so the
    # message must not survive into the next request.
    def flash_now(type, message)
      flash.now[:class]   = "alert alert-#{type}"
      flash.now[:message] = message
    end
end

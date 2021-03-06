class ArticleController < ApplicationController
  before_filter :check_if_admin, except: [:index, :show]

  def index
    @articles = Array.new
    file_list = Dir.entries(File.join(Rails.root,'public/articles')).select {|f| !File.directory? f}
    file_list.each do |file|
      @articles << [file, File.open(File.join(Rails.root,'public/articles', file), "r") {|io| io.read}]
    end
    @articles.sort!
  end


  def show
    begin
      @article = File.open(File.join(Rails.root,'public/articles', params[:id] + ".html"), "r") {|io| io.read}
    end
  end

  def articles_admin_index
    begin
      if !File.directory?(File.join(Rails.root,'public/articles'))
        Dir.mkdir(File.join(Rails.root,'public/articles'))
      end
      if !File.directory?(File.join(Rails.root,'public/assets/articles'))
        if !File.directory?(File.join(Rails.root,'public/assets'))
          Dir.mkdir(File.join(Rails.root,'public/assets'))
        end
        Dir.mkdir(File.join(Rails.root,'public/assets/articles'))
      end
      @articles = Array.new
      file_list = Dir.entries(File.join(Rails.root,'public/articles')).select {|f| !File.directory? f}
      file_list.each do |file|
        @articles << [file, File.open(File.join(Rails.root,'public/articles', file), "r") {|io| io.read}]
      end
      @articles.sort!
      @images = Array.new
      @images = Dir.entries(File.join(Rails.root,'public/assets/articles')).select {|f| !File.directory? f}
    end
  end

  def article_admin_show
    @article = Array.new
    article_name = params[:article_name] + '.html'
    article_path = File.join(Rails.root,'public/articles')
    @article[0] = article_name
    @article[1] = File.open(File.join(article_path, article_name)){ |file| file.read }
    @images = Array.new
    @images = Dir.entries(File.join(Rails.root,'public/assets/articles')).select {|f| !File.directory? f}
  end


  def article_admin_edit
    begin
      article_name = params[:article_name]
      article_path = File.join(Rails.root,'public/articles')
      File.open(File.join(article_path, article_name),'wb') do |f|
        f.write(params[:article_text])
      end
    end
    redirect_to articles_admin_index_path
  end


  def article_new
    # :path_to_image, :path_to_thumb, :alt_to_image, :horizontal, :image_folder
    begin
      article_name = params[:article].original_filename.split('.')[0] + '.html'
      article_path = File.join(Rails.root,'public/articles')

      File.open(File.join(article_path, article_name),'wb') do |f|
        f.write(params[:article].read)
      end
    end
    redirect_to articles_admin_index_path
  end


  def image_to_article
    begin
      image_name = "#{params[:image].original_filename}"
      image_path = File.join(Rails.root,'public/assets/articles')

      File.open(File.join(image_path, image_name),'wb') do |f|
        f.write(params[:image].read)
      end
    rescue
      Dir.mkdir(File.join(Rails.root,'public/assets'))
      Dir.mkdir(File.join(Rails.root,'public/assets/articles'))
      File.open(File.join(image_path, image_name),'wb') do |f|
        f.write(params[:image].read)
      end
    end
    redirect_to articles_admin_index_path
  end


  def article_delete
    begin
      article_path = File.join(Rails.root,'public/articles')
      File.delete(File.join(article_path, params[:article_name])) if File.exist?(File.join(article_path, params[:article_name]))
    end
    redirect_to articles_admin_index_path
  end

  def image_delete
    begin
      image_path = File.join(Rails.root,'public/assets/articles')
      File.delete(File.join(image_path, params[:image_name])) if File.exist?(File.join(image_path, params[:image_name]))
    end
    redirect_to articles_admin_index_path
  end

end
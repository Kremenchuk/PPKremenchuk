class ArticleController < ApplicationController

  def index
    @articles = Array.new
    file_list = Dir.entries("public/articles").select {|f| !File.directory? f}
    file_list.each do |file|
      @articles << [file, File.open(File.join(Rails.root,'public/articles', file), "r") {|io| io.read}]
    end
  end


  def show
    begin
      @article = File.open(File.join(Rails.root,'public/articles', params[:name]), "r") {|io| io.read}
    end
  end

  def articles_admin_index
    @articles = Dir.entries("public/articles").select {|f| !File.directory? f}
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
      image_name = "stillage_images_to_article_#{params[:image].original_filename}"
      image_path = File.join(Rails.root,'public/assets/articles')

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

end
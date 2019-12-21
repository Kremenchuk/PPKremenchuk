# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://stm-industry.com.ua"

SitemapGenerator::Sitemap.create do
  add '/ru/stillage',  :priority => 0.5, :changefreq => 'weekly'
  add '/ru/stillage_warehouse',  :priority => 0.5, :changefreq => 'weekly'
  add '/ru/stillage_pallet',  :priority => 0.5, :changefreq => 'weekly'
  add '/ru/trolley',  :priority => 0.5, :changefreq => 'weekly'
  add '/ru/mezzanine',  :priority => 0.5, :changefreq => 'weekly'
  add '/ru/platform',  :priority => 0.5, :changefreq => 'weekly'
  add '/ru/lofts',  :priority => 0.5, :changefreq => 'weekly'
  add '/ru/galleries',  :priority => 0.5, :changefreq => 'weekly'
  add '/ru/contact',  :priority => 0.5, :changefreq => 'weekly'
  add '/ru/about_us',  :priority => 0.5, :changefreq => 'weekly'
  add '/ru/news',  :priority => 0.5, :changefreq => 'weekly'
  add '/ru/article',  :priority => 0.5, :changefreq => 'weekly'
  add '/ru/users/sign_in',  :priority => 0.5, :changefreq => 'weekly'
  add '/ru/welcome',  :priority => 0.5, :changefreq => 'weekly'

  add '/uk/stillage',  :priority => 0.5, :changefreq => 'weekly'
  add '/uk/stillage_warehouse',  :priority => 0.5, :changefreq => 'weekly'
  add '/uk/stillage_pallet',  :priority => 0.5, :changefreq => 'weekly'
  add '/uk/trolley',  :priority => 0.5, :changefreq => 'weekly'
  add '/uk/mezzanine',  :priority => 0.5, :changefreq => 'weekly'
  add '/uk/platform',  :priority => 0.5, :changefreq => 'weekly'
  add '/uk/lofts',  :priority => 0.5, :changefreq => 'weekly'
  add '/uk/galleries',  :priority => 0.5, :changefreq => 'weekly'
  add '/uk/contact',  :priority => 0.5, :changefreq => 'weekly'
  add '/uk/about_us',  :priority => 0.5, :changefreq => 'weekly'
  add '/uk/news',  :priority => 0.5, :changefreq => 'weekly'
  add '/uk/article',  :priority => 0.5, :changefreq => 'weekly'
  add '/uk/users/sign_in',  :priority => 0.5, :changefreq => 'weekly'
  add '/uk/welcome',  :priority => 0.5, :changefreq => 'weekly'



  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  #   add articles_path, :priority => 0.5, :changefreq => 'daily'
  #
  # Add all articles:
  #
  #   Article.find_each do |article|
  #     add article_path(article), :lastmod => article.updated_at
  #   end
end

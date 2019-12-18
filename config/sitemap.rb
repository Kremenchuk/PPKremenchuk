# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://stm-industry.com.ua"

SitemapGenerator::Sitemap.create do
  add site_map_path, :priority => 0.5, :changefreq => 'daily'
  add stillage_pallet_index_path, :priority => 0.5, :changefreq => 'daily'
  add stillage_warehouse_index_path, :priority => 0.5, :changefreq => 'daily'
  add stillage_index_path, :priority => 0.5, :changefreq => 'daily'
  add trolley_index_path, :priority => 0.5, :changefreq => 'daily'
  add mezzanine_index_path, :priority => 0.5, :changefreq => 'daily'
  add platform_index_path, :priority => 0.5, :changefreq => 'daily'
  add about_us_path, :priority => 0.5, :changefreq => 'daily'
  add news_index_path, :priority => 0.5, :changefreq => 'daily'
  add galleries_path, :priority => 0.5, :changefreq => 'daily'
  add article_index_path, :priority => 0.5, :changefreq => 'daily'
  add lofts_path, :priority => 0.5, :changefreq => 'daily'

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

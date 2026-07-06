module WelcomeHelper
  # Image locale — the localized product GIFs only ship in uk/ru; English
  # falls back to the Ukrainian artwork.
  def welcome_image_locale
    I18n.locale == :ru ? 'ru' : 'uk'
  end

  # Product cards shown on the welcome page.
  # Each item: { key:, title:, path:, image: (or nil for a feature card), icon: }
  def welcome_products
    l = welcome_image_locale
    [
      { key: 'stillage',  title: t('page.welcome.stillage'),           path: stillage_index_path,           image: "design/all_parts/welcome/stillage_arxivniy_bitovoy_#{l}.gif", icon: 'fa-archive' },
      { key: 'warehouse', title: t('page.welcome.stillage_warehouse'), path: stillage_warehouse_index_path, image: "design/all_parts/welcome/stillage_warehouse_#{l}.gif",         icon: 'fa-warehouse' },
      { key: 'pallet',    title: t('page.welcome.stillage_pallet'),    path: stillage_pallet_index_path,    image: "design/all_parts/welcome/stillage_pallet_#{l}.gif",            icon: 'fa-pallet' },
      { key: 'trolley',   title: t('page.welcome.troles'),             path: trolley_index_path,            image: "design/all_parts/welcome/troleys_#{l}.gif",                    icon: 'fa-dolly' },
      { key: 'mezzanine', title: t('page.welcome.stillage_mezonin'),   path: mezzanine_index_path,          image: "design/all_parts/welcome/stillage_mezonin_#{l}.gif",           icon: 'fa-layer-group' },
      { key: 'platform',  title: t('page.welcome.platform'),           path: platform_index_path,           image: nil,                                                           icon: 'fa-truck-loading' },
      { key: 'loft',      title: t('page.welcome.loft'),               path: lofts_path,                    image: nil,                                                           icon: 'fa-couch' },
      { key: 'gallery',   title: t('page.welcome.gallery'),            path: gallery_index_path,            image: "design/all_parts/welcome/gallery_#{l}.gif",                    icon: 'fa-images' }
    ]
  end

  # Collapsible editorial rows for the mobile layout.
  # [checkbox id, link i18n key, path, anons i18n key, block i18n key]
  def welcome_reductions
    [
      ['hd-2', 'link_text_we_create_arxiv',  stillage_index_path,           'text_we_create_arxiv_anons',  'text_we_create_arxiv_block'],
      ['hd-3', 'link_text_we_create_wareh',  stillage_warehouse_index_path, 'text_we_create_wareh_anons',  'text_we_create_wareh_block'],
      ['hd-4', 'link_text_we_create_pallet', stillage_pallet_index_path,    'text_we_create_pallet_anons', 'text_we_create_pallet_block'],
      ['hd-5', 'link_text_we_create_troley', trolley_index_path,            'text_we_create_troley_anons', 'text_we_create_troley_block'],
      ['hd-6', 'link_text_we_create_mez',    mezzanine_index_path,          'text_we_create_mez_anons',    'text_we_create_mez_block'],
      ['hd-7', 'link_text_we_create_plat',   platform_index_path,           'text_we_create_plat_anons',   'text_we_create_plat_block'],
      ['hd-8', 'link_text_we_create_loft',   lofts_path,                    'text_we_create_loft_anons',   'text_we_create_loft_block']
    ]
  end
end

module ApplicationHelper
  # SEO <title>: a keyword-rich, per-page title with a sensible fallback.
  def page_title
    t("page.titles.#{controller_name}", default: t("page.layout.title"))
  end

  # SEO meta description for the current page (set by the controllers as
  # @meta_tags; falls back to the welcome description).
  def meta_description
    (@meta_tags.presence || t("page.meta_tags.welcome")).to_s
  end
end

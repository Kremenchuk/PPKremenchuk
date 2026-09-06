module ApplicationHelper
  # News and Article keep their copy as a JSON hash keyed by locale
  # ({"uk" => …, "en" => …, "ru" => …}).
  #
  # The views used to read it with a bare `locale` method that is not
  # defined anywhere in the app — it never raised only because both tables
  # were empty. Read through this helper instead, and fall back to the
  # first filled translation so a half-translated record does not show up
  # as a blank card.
  def localized(field)
    return "" if field.blank?
    return field.to_s unless field.is_a?(Hash)

    value = field[I18n.locale.to_s]
    value = field.values.find(&:present?) if value.blank?
    value.to_s
  end
end

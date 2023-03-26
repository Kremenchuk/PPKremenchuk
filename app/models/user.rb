class User < ActiveRecord::Base

  DILLER_TYPES = { "Класс №1": 1, "Класс №2": 2, "Класс №3": 3, "Розница": 4 }.freeze
  AVAILABLE_LOCALES = { uk: 0, en: 1, ru: 2 }

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :email, presence: true, uniqueness: true

  enum diller: DILLER_TYPES
  enum language: AVAILABLE_LOCALES
end

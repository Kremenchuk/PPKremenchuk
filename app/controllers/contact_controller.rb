class ContactController < ApplicationController
  def index
    @contacts = Contact.all
    button_const
  end
end

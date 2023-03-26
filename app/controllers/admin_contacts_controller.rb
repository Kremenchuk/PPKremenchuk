class AdminContactsController < ApplicationController
  before_action :check_if_admin
  before_action :find_contact, only: [:update, :destroy]

  def index
    @contacts = Contact.all
  end

  def create
    contact = Contact.new
    contact.attributes = permit_contact_info
    contact.save!
    redirect_to admin_contacts_path
  end

  def update
    @contact.attributes = permit_contact_info
    @contact.save!
    redirect_to admin_contacts_path
  end

  def destroy
    @contact.destroy!
    redirect_to admin_contacts_path
  end


  private

  def permit_contact_info
    params.permit('name', 'text')
  end

  def find_contact
    if params[:id].present?
      @contact = Contact.find params[:id]
    else
      @contact = Contact.new
    end
  end

end
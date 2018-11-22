class AdminPanelController < ApplicationController
  before_filter :check_if_admin, only: [:index]
  before_filter :find_user, only: [:change_diller, :destroy]

  before_action :find_contact, only: [:contacts_new, :contacts_update, :contact_destroy]

  def index
    @users = User.all

    #if @user.diller == nil
    #  @diller_namb = 4
    #else
    #  @diller_namb = @user.diller
    #end
    #case @diller_namb
    #  when 1
    #    @diller_text = "Класс №1"
    #  when 2
    #    @diller_text = "Класс №2"
    #  when 3
    #    @diller_text = "Класс №3"
    #  when 4
    #    @diller_text = "Розница"
    #end
  end

  def destroy
    @user.destroy
    redirect_to action: "index"
  end

   def change_diller
    @diller_type          = params[:select2]

    case @diller_type
      when "Розница"
        @user.diller = 4
      when "Класс №1"
        @user.diller = 1
      when "Класс №2"
        @user.diller = 2
      when "Класс №3"
        @user.diller = 3
    end
    @user.save!
    redirect_to action: "index"
  end



  def show
    @users = User.all
    y=0
    @users.each do |i|
      y += 1
      @user = User.where(id: i.id).first
      @name_params_var = "dil" + "#{y}"
      @diller_type = params[@name_params_var]

      case @diller_type
        when "Розница"
          @user.diller = 4
        when "Класс №1"
          @user.diller = 1
        when "Класс №2"
          @user.diller = 2
        when "Класс №3"
          @user.diller = 3
      end

      @name_params_var = "adm" + "#{y}"
      @admin_type          = params[@name_params_var]
      case @admin_type
        when "Да"
          @user.admin = true
        when "Нет"
          @user.admin = false
      end

      @user.save!
    end

    redirect_to action: "index"
  end


  def contacts_index
    @contacts = Contact.all
  end

  def contacts_new
    @contact.attributes = permit_contact_info
    @contact.save!
    redirect_to contacts_index_path
  end

  def contacts_update
    @contact.attributes = permit_contact_info
    @contact.save!
    redirect_to contacts_index_path
  end

  def contact_destroy
    @contact.destroy!
    redirect_to contacts_index_path
  end


  private

  def permit_contact_info
    params.permit('name', 'text')
  end

  def find_user
    @user = User.where(id: params[:id]).first
    render_404 unless @user
  end


  def find_contact
    if params[:id].present?
      @contact = Contact.find params[:id]
    else
      @contact = Contact.new
    end
  end


end
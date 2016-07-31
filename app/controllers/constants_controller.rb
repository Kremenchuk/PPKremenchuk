class ConstantsController < ApplicationController
  before_filter :find_item, only: [:edit, :update, :show]
  before_filter :check_if_admin, only: [:index, :show, :edit, :update]


  #index
  #%form{:action => "index", :method => "get", :name => "contact_form", :onsubmit => "return validate_form ( );"}
  #%input.input_style{:maxlength => "8", :name => "mat_list_2_1_055", :pattern => "\[0-9]+\[.]\[0-9]{2}",
  #    :size => "12", :value => "#{@constant.mat_list_2_1_055}", :type => "text"}



  def index
    #@constant = Constant.all
    #@constant = Constant.where("id = 1")
  end

  def edit
    button_const
    #@material = Material.where("id = 1")
    flash[:success]="Отредактировано"
  end

  def show
    #SendEmail.login_from_site('current_user.email').deliver_now  #просто проверка отправки почты
    redirect_to action: "edit"



  end


  def update

    @constant.update_attributes(params[:constant])
    if @constant.errors.empty?
      flash[:success]="Отредактировано"
      redirect_to constant_path(@constant)
    else
      flash.now[:error] = "Ошибка в заполнении формы"
      render "/constants/edit"
    end

  end

  def find_item
    @constant = Constant.all
    @constant = Constant.where("id = 1").first

  end

end

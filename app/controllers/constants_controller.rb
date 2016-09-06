class ConstantsController < ApplicationController
  before_filter :find_item, only: [:edit, :update, :show, :load_constant]
  before_filter :check_if_admin, only: [:index, :show, :edit, :update]


  def edit
    button_const
  end

  def show
    redirect_to action: :edit
  end


  def load_constant
    # Завантаження файлу з константами


    uploaded_io = params[:constant_file]
    if uploaded_io != nil
      begin
        FileUtils.mkdir_p(Rails.root.join('public', 'file'))
      rescue => error
        flash_message("danger", "Невозможно открыть файл. #{error.message}")
      end
      begin
        FileUtils.rm_rf(Dir.glob(Rails.root.join('public', 'file') + "*"))
        File.open(Rails.root.join('public', 'file', uploaded_io.original_filename), 'wb') do |file|
          file.write(uploaded_io.read)
        end
      rescue => error
        flash_message("danger", "Невозможно открыть файл. #{error.message}")
      end
      column_names = Constant.column_names.to_a

      # Завантаження констант
      begin
        workbook = Roo::Spreadsheet.open(Rails.root.join('public', 'file', uploaded_io.original_filename).to_s)
      rescue => error
        flash_message("danger", "Невозможно открыть файл. #{error.message}")
      end

      unless error
        const_name_list  = workbook.sheet(1).parse
        const_value_list = workbook.sheet(2)
        result = {}

        # Видалення непотрібних полів
        no_use_fields =
        [
            "id", "created_at", "updated_at", "email_to_send", "on_off_calc_stillage", "on_off_calc_stillage_warehouse",
         "on_off_calc_stillage_pallet", "on_off_calc_TP01", "on_off_calc_TP02", "on_off_calc_TP03", "on_off_calc_TP04",
         "on_off_calc_TP05", "on_off_calc_TP06", "on_off_calc_TP07", "on_off_calc_KS01", "on_off_calc_KS02", "on_off_calc_KS03",
         "on_off_calc_KS04", "on_off_calc_PT01", "on_off_calc_PT02", "on_off_calc_PT03", "on_off_calc_PT04", "mat_shina_30_4",
         "wei_shina_30_4", "area_shina_30_4"
        ]
        column_names = column_names.compact
        no_use_fields.each do |no_use_field|
          column_names.delete(no_use_field)
        end

        column_names.each do |column_name|
          col = 0
          const_name_list.each do |col_excel|
            col += 1
            row = col_excel.index(column_name)
            if row
              result[column_name] = const_value_list.cell(col,row + 1).to_s.gsub(',', '.').to_f
              break
            end
          end
        end


        # Проверка все ли поля найдены и не равні 0
        warnings = ''
        result.each do |key, value|
          if value == 0
            warnings += "#{key} равняеться #{value}. "
          else
            column_names.delete(key.to_s)
          end


        end
        if warnings.present?
          warnings += "Константы не обновлены"
          flash_message("danger", warnings)
        else
          if column_names.count == 0
            @constant.update_attributes(result)
            flash_message("success", "Константы загружены")
          else
            flash_message("danger", "Поля #{column_names.inspect} не найдены. Константы не обновлены")
          end
        end
      end
    else
      flash_message("danger", "Не выбран файл с константами. Константы не обновлены")
    end
    redirect_to edit_constant_path(1)
  end


  def update
    @constant.update_attributes(params[:constant])
    if @constant.errors.empty?
      flash_message("success", "Отредактировано")
      redirect_to constant_path(@constant)
    else
      flash_message("danger", "Ошибка в заполнении формы. #{@constant.errors.full_messages}")
      redirect_to edit_constant_path(1)
    end

  end



  private

  def find_item
    @constant = Constant.where(id: 1).first
  end


  def flash_message(type, mesage)
    flash[:class] = "alert alert-#{type}"
    flash[:style] = "font-size:20px;"
    flash[:message] = mesage
  end


end

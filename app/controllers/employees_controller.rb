class EmployeesController < ApplicationController
  before_action :set_employee, only: %i(edit update destroy)
  before_action :set_form_option, only: %i(new create edit update)

  require 'csv'

  def index
    if sort_column == "number"
      if sort_direction == 'asc'
        @employees = Employee.active.sort
      else
        @employees = Employee.active.sort.reverse
      end
    else
      @employees = Employee.active.order("#{sort_column} #{sort_direction}")
    end
    @employees = Kaminari.paginate_array(@employees).page(params[:page]).per(10)

    if params[:format] == 'csv'
      @employees_all = Employee.active.sort
    end

    respond_to do |format|
      format.html
      format.csv do |csv|
        send_employees_csv(@employees_all)
      end
    end
  end

  def send_employees_csv(employees)
    csv_data = CSV.generate do |csv|
      header = %w(社員番号 氏名（姓） 氏名（名） アカウント メールアドレス 入社年月日 部署 オフィス 社員情報管理権限 お知らせ投稿権限 )
      csv << header
      employees.each do |employee|
        values = [employee.number,employee.last_name,employee.first_name,employee.account,employee.email,employee.date_of_joining,
          employee.department_id,employee.office_id,employee.employee_info_manage_auth,employee.news_posts_auth]
        csv << values
      end
    end
    send_data(csv_data, filename: "employees.csv")
  end

  def new
    @employee = Employee.new
  end

  def create
    @employee = Employee.new(employee_params)

    add_params

    if @employee.save
      redirect_to employees_url, notice: "社員「#{@employee.last_name} #{@employee.first_name}」を登録しました。"
    else
      render :new
    end
  end

  def edit
  end

  def update
    add_params

    if @employee.update(employee_params)
      redirect_to employees_url, notice: "社員「#{@employee.last_name} #{@employee.first_name}」を更新しました。"
    else
      render :edit
    end
  end

  def destroy
    ActiveRecord::Base.transaction do
      now = Time.now
      @employee.update_column(:deleted_at, now)
      @employee.profiles.active.first.update_column(:deleted_at, now) if @employee.profiles.active.present?
    end

    redirect_to employees_url, notice: "社員「#{@employee.last_name} #{@employee.first_name}」を削除しました。"
  end

  private

  def employee_params
    params.require(:employee).permit(:number, :last_name, :first_name, :account, :password, :email, :date_of_joining, :department_id, :office_id, :employee_info_manage_auth, :news_posts_auth)
  end

  def set_employee
    @employee = Employee.find(params["id"])
  end

  def set_form_option
    @departments = Department.all
    @offices = Office.all
  end

  # 現在、メールアドレスと入社日は入力できないため、ここで追加しています。
  def add_params
    unless @employee.email
      @employee.email = 'sample@example.com'
    end
    unless @employee.date_of_joining
      @employee.date_of_joining = Date.today
    end
  end

  def sort_column
    params[:sort] ? params[:sort] : 'number'
  end

  def sort_direction
    params[:direction] ? params[:direction] : 'asc'
  end

end

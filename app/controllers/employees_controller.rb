class EmployeesController < ApplicationController

  def index
    @search = @current_user.employees.search(params[:search])
    @employees = @search.page(params[:page])
  end

  def new
    @employee = current_user.employees.new
    render layout: 'application_pop'
  end

  def create
    @employee = current_user.employees.new(params[:employee].merge(user_type: 2))
    if @employee.save
      # EmployeeRoleMap.create(
      #   employee_id: @employee.id,
      #   employee_role_id: params[:employee_role][:employee_role_id].to_i
      # )
      flash[:notice] = '添加成功'
      render inline: "<script>parent.location.reload();</script>"
    else
      redirect_to :back, notice: '添加失败'
    end
  end

  def show
    @employee = current_user.employees.find(params[:id])
  end

  def edit
    @employee = current_user.employees.find(params[:id])
    render layout: 'application_pop'
  end

  def update
    @employee = current_user.employees.find(params[:id])
    if @employee.update_attributes(params[:employee])
      flash[:notice] = '更新成功'
      render inline: "<script>parent.location.reload();</script>"
    else
      redirect_to :back, notice: '更新失败'
    end
  end

  def destroy
    @employee = Employee.find(params[:id])
    if @employee.destroy
      redirect_to :back, notice: '删除成功'
    else
      redirect_to :back, alter: "删除失败,#{@employee.errors.full_messages.join(',')}"
    end
  end

end

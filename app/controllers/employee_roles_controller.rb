class EmployeeRolesController < ApplicationController

  def index
    @search = current_user.employee_roles.search(params[:search])
    @employee_roles = @search.page(params[:page])
  end

  def new
    @employee_role = current_user.employee_roles.new
    render layout: 'application_pop'
  end

  def create
    @employee_role = current_user.employee_roles.new(params[:employee_role])
    if @employee_role.save
      params[:permission][:permission_ids].each do |t|
				RolePermissionMap.create(
					permission_id: t,
					employee_role_id: @employee_role.id
				)
      end
      flash[:notice] = '添加成功'
      render inline: "<script>parent.location.reload();</script>"
    else
      redirect_to :back, notice: '添加失败'
    end
  end

  def show
    @employee_role = current_user.employee_roles.find(params[:id])
  end

  def edit
    @employee_role = current_user.employee_roles.find(params[:id])
    render layout: 'application_pop'
  end

  def update
    @employee_role = current_user.employee_roles.find(params[:id])
    if @employee_role.update_attributes(params[:employee_role])
      RolePermissionMap.where(employee_role_id: @employee_role.id).each do |m|
				m.destroy
			end

			params[:permission][:permission_ids].each do |t|
				RolePermissionMap.create(
					permission_id: t,
					employee_role_id: @employee_role.id
				)
      end
      flash[:notice] = "更新成功!"
      render inline: "<script>parent.location.reload();</script>"
    else
      return redirect_to :back , alert: '更新失败，请确认数据正确和必填项。'
    end
  end

  def destroy
    @employee_role = current_user.employee_roles.find(params[:id])
    if @employee_role.destroy
      redirect_to :back, notice: '删除成功!'
    else
      redirect_to :back, alter: "删除失败,#{@employee_role.errors.full_messages.join(',')}"
    end
  end

end

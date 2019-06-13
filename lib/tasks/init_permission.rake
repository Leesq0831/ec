namespace :permission do

  desc 'init permission'
  task :init => :environment do
    puts 'Starting init permissions ******'

    permission_parent_list = {
      1 => '系统设置',
      2 => '小程序设置',
      3 => '账号权限',
      4 => '会员管理',
      5 => '商城管理',
      6 => '内容管理'
    }

    permission_list = {
      # 'a1' => '系统设置',
      '1,1' => '商家信息',
      '1,2' => '修改密码',
      '1,3' => '首页设置',
      '1,4' => '支付设置',

      # 'a2' => '小程序设置',
      '2,1' => '一键授权',
      '2,2' => '开发设置',

      # 'a2' => '账号权限',
      '3.1' => '账号管理',
      '3,2' => '角色管理',

      # 'a3' => '会员管理',
      '4,1' => '用户管理',
      
      # 'a4' => '商城管理',
      '5,1' => '商品管理',
      '5,2' => '库存管理',
      '5,3' => '分类管理',
      '5,4' => '服务承诺',
      '5,5' => '物流运费',
      '5,6' => '订单管理',
      '5,7' => '订单设置',
      # '4,3' => '评论管理',
      # '4,4' => '评论模板',

      # 'a6' => '商城管理',
      '6,1' => '资讯管理',
      '6,2' => '展示管理'
    }

    Account.find_each do |account|
      role = account.employee_roles.where(account_id: account.id, name: "系统管理员").first_or_create

      permission_parent_list.each do |key, value|
        permission = Permission.where(name: value, parent_id: 0).first_or_create

        RolePermissionMap.where(
          employee_role_id: role.id,
          permission_id: permission.id
        ).first_or_create
      end

      permission_list.each do |key, value|
        permission = Permission.where(name: value, parent_id: key.split(',').first.to_i).first_or_create

        RolePermissionMap.where(
          employee_role_id: role.id,
          permission_id: permission.id
        ).first_or_create
      end

      employee = Employee.where(account_id: account.id, name: account.nickname).first
      unless employee
        employee = Employee.new(account_id: account.id, name: account.nickname, password_digest: account.password_digest)
        employee.save(validate: false)
      end

      EmployeeRoleMap.where(
        employee_id: employee.id,
        employee_role_id: role.id
      ).first_or_create
    end
    puts "finished"
  end

end

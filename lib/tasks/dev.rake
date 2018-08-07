# -*- encoding : utf-8 -*-

namespace :dev do

  desc 'build test data ...'
  task init: [
    :create_database,
  ]

  desc 'created accounts'
  task :create_database => :environment do
    puts 'Starting create accounts ******'
    account = Account.where(nickname: 'admin').first_or_create(company_name: 'zztech', password: 111111, password_confirmation: 111111, mobile: 18862631811, email: '18862631811@163.com')
    puts "created account: #{account.nickname}"
    employee = Employee.where(login: 'admin').first_or_create(account_id: account.id, name: "管理员", password: "111111", user_type: 1)

    role = EmployeeRole.where(account_id: account.id, name: "系统管理员").first_or_create

    EmployeeRoleMap.where(
      employee_id: employee.id,
      employee_role_id: role.id
    ).first_or_create

    permission_list = {

      1 => '商家信息',
      2 => '修改密码',
      3 => '首页设置',
      4 => '支付设置',

      10 => '一键授权',
      11 => '开发设置',

      20 => '员工管理',
      21 => '角色管理',

      30 => '用户管理',
      
      40 => '商品管理',
      41 => '库存管理',
      42 => '分类管理',
      43 => '服务承诺',
      44 => '物流运费',
      45 => '订单管理',
      46 => '订单设置',

    }

    permission_list.each do |key, value|
      permission = Permission.where(key: key).first_or_create(name: value)
      RolePermissionMap.where(
          employee_role_id: role.id,
          permission_id: permission.id
        ).first_or_create
    end

  end


  desc 'update city'
  task :update_city => :environment do
    puts 'Starting update city ******'

    require 'ruby-pinyin'

    Province.find_each do |province|
      province.update_attributes(pinyin: PinYin.of_string(province.name).join)
      puts "update province #{province.name} #{province.pinyin}"
    end

    City.find_each do |city|
      city.update_attributes(pinyin: PinYin.of_string(city.name.gsub(/市|地区|自治州|特别行政区/,'')).join)
      puts "update city #{city.name} #{city.pinyin}"
    end

    District.find_each do |district|
      district.update_attributes(pinyin: PinYin.of_string(district.name).join)
      puts "update district #{district.name} #{district.pinyin}"
    end

    puts 'Done!'
  end

end

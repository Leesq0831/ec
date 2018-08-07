# -*- encoding : utf-8 -*-

namespace :dev do

  desc 'build test data ...'
  task init: [
    :create_accounts,
  ]

  desc 'created accounts'
  task :create_accounts => :environment do
    puts 'Starting create accounts ******'
    account = Account.where(nickname: 'admin').first_or_create(company_name: 'zztech', password: 111111, password_confirmation: 111111, mobile: 18862631811, email: '18862631811@163.com')
    puts "created account: #{account.nickname}"
    employee = Employee.where(login: 'admin').first_or_create(account_id: account.id, name: "管理员", password: "111111", user_type: 1)
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

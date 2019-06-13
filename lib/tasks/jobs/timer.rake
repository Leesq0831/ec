# -*- encoding : utf-8 -*-
namespace :timer do

  desc 'expire shop orders'
  task :shop_order_expire => :environment do
    puts 'Starting expire .........'

    # ShopOrder.need_expires.update_all({:status => ShopOrder::EXPIRED})
    ShopOrder.need_expires.update_all(status: ShopOrder::CANCELED)

    puts 'done .........'
  end

  desc 'expire hospital orders'
  task :hospital_order_expire => :environment do
    puts 'Starting expire .........'

    # HospitalOrder.need_expires.update_all({:status => HospitalOrder::EXPIRED})
    HospitalOrder.need_expires.update_all(status: HospitalOrder::CANCELED, canceled_at: Time.now)

    puts 'done .........'
  end

  desc 'start and stop vote activities'
  task :vote => :environment do
    puts 'start and stop vote activities....'
    Activity.vote_need_start.update_all({:status => Activity::SETTED})
    Activity.vote_need_stop.update_all({:status => Activity::STOPPED})
  end
end

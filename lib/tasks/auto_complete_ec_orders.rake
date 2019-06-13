namespace :auto_complete_ec_orders do

  ##24小时后，未支付订单自动置为逾期未支付状态
  desc 'auto complete ec orders when ec order paying'
  task :change_paying_ec_order_status => :environment do
    EcOrder.paying.find_each do |ec_order|
      if Time.now > ec_order.created_at + 1.days
        ec_order.update_attributes(description: '未按时支付', status: EcOrder::OVERDUE)
      else
        next
      end
    end
  end

  ##7天后，已发货订单自动置为已完成状态
  desc 'auto complete ec orders when ec order receipt'
  task :change_receipt_ec_order_status => :environment do
    EcOrder.receipt.find_each do |ec_order|
      if Time.now > ec_order.updated_at + 7.days
        ec_order.completed!
      else
        next
      end
    end
  end
end
namespace :order do

  desc "Automatic closing of unpaid orders"
  task :close_unpaid_order => :environment do
    order_rule = EcOrderRule.where(is_auto_expire: true).first
    if order_rule
      ec_orders = EcOrder.pending.where("created_at < ?", order_rule.expires_in.to_f.hours.ago)
      ec_orders.find_each do |ec_order|
        ec_order.canceled!
      end
    end
  end

  desc "Automatic confirmed of arrived orders"
  task :confirmed_order => :environment do
    if order_rule = EcOrderRule.where(is_auto_confirm: true).first
      ec_orders = EcOrder.arrived.where("arrived_at < ?", order_rule.expires_in.to_f.days.ago)
      ec_orders.find_each do |ec_order|
        ec_order.confirmed!
      end
    end
  end

  desc "Automatic finished and comment of confirmed orders"
  task :complete_unfinished_order => :environment do
    if order_rule = EcOrderRule.where(is_auto_comment: true).first
      ec_orders = EcOrder.confirmed.where("receipt_at < ?", order_rule.confirms_in.to_f.days.ago)
      ec_orders.find_each do |ec_order|
        ec_order.finished!

        ec_order.ec_order_items.find_each do |ec_order_item|
          comment_content = EcCommentTemplate.all.sample(1).first.content
          nickname = WxUser.where(user_id: ec_order.user_id).first.try(:nickname)
          EcComment.create(
            comment_type: EcComment::ROBOT,
            ec_order_item_id: ec_order_item.id,
            user_id: ec_order.user_id,
            ec_item_id: ec_order_item.ec_item_id,
            content: comment_content,
            nickname: nickname,
            star: 5
          )
        end
      end
    end
  end

end

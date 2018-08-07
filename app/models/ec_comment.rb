class EcComment < ActiveRecord::Base
  validates :ec_order_item_id, :user_id, :ec_item_id, :content, presence: true
  validates :reply, presence: true, on: :update

  belongs_to :ec_order_item
  belongs_to :user
  belongs_to :ec_item

  acts_as_enum :comment_type, :in => [
    ['human', 1, '正常'],
    ['robot', 2, '自动评论']
  ]

  acts_as_enum :status, :in => [
  	['normal', 1, '正常'],
  	['disabled', -1, '已删除']
  ]

  scope :high, -> {where(star: [4, 5])}
  scope :middle, -> {where(star: [2, 3])}
  scope :low, -> {where(star: 1)}

  after_create :get_comment_points

  def self.judge_rating(type)
    case type.to_i
    when 1
      where(true)
    when 2
      high
    when 3
      middle
    when 4
      low
    else
      where(true)
    end
  end

  def self.save_multi(data, user, order_id)
    data = data.collect {|k, v| v }
    transaction do
      data.each do |attrs|
        user.ec_comments.create(
          ec_order_item_id: attrs[:pid],
          ec_item_id: EcOrderItem.where(id: attrs[:pid]).first.ec_item.id,
          content: attrs[:content],
          star: attrs[:point]
        )
      end
      user.ec_orders.where(id: order_id).first.finished!
    end

    return true
  rescue => e
    Rails.logger.info e
    puts "出现异常: #{e}"
    return false
  end
  private

    def get_comment_points
      if human?
        transaction do
          point_rule = EcPointRule.first_or_create

          if user.vip_user && point_rule.enabled? && point_rule.comment_points.to_i > 0
            user.vip_user.update_attributes(
              total_points: user.vip_user.total_points + point_rule.comment_points.to_i,
              usable_points: user.vip_user.usable_points + point_rule.comment_points.to_i
            )
            user.vip_user.point_transactions.create(
              site_id: user.site_id,
              pointable_id: user_id,
              pointable_type: 'User',
              direction_type: PointTransaction::IN,
              points: point_rule.comment_points.to_i,
              description: '评论送积分'
            )
          end
        end
      end
    end

end

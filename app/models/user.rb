# coding: utf-8
class User < ActiveRecord::Base

  acts_as_enum :gender, :in => [
    ['secret', 0, '未知'],
    ['male', 1, '男'],
    ['female', 2, '女'],
  ]

  acts_as_enum :status, :in => [
    ['normal', 0, '正常'],
    ['disabled', -1, '冻结']
  ]

  has_many :ec_cart_items
  has_many :ec_orders
  has_many :ec_addresses
  has_many :ec_favorites
  has_many :ec_items, through: :ec_favorites
  has_many :ec_comments
  has_many :ec_search_histories
  has_many :ec_user_activities
  has_many :ec_activities, through: :ec_user_activities
  has_many :ec_slide_users
  has_many :ec_slides, through: :ec_slide_users

  belongs_to :account

  has_one :user
  has_one :vip_user
  has_one :wx_user

  has_one :broker, class_name: '::Brokerage::Broker'
  has_many :greet_voices
  has_many :wx_wall_users
  has_many :shake_users
  has_many :wx_participates
  has_many :guess_participations, class_name: 'Guess::Participation'
  has_many :wx_prizes
  has_many :custom_values
  has_many :activity_users
  has_many :activity_consumes
  has_many :activity_users
  has_many :activity_groups
  has_many :leaving_messages, as: :replier
  has_many :addresses, class_name: 'WxUserAddress', dependent: :destroy
  has_many :ec_carts
  has_many :booking_orders
  has_many :group_orders
  has_many :hospital_orders
  has_many :hospital_comments
  has_many :donation_orders
  has_many :trip_orders
  has_many :reservation_orders
  has_many :lottery_draws
  has_many :user_voices
  has_many :share_photo_comments
  has_many :share_photo_likes
  has_many :share_photos
  has_many :consumes
  has_many :govchats
  has_many :govmails
  has_many :qrcode_logs
  has_many :qrcode_users
  has_many :wbbs_topics, as: :poster
  has_many :wbbs_notifications, as: :notifier
  has_many :repairs, class_name: 'WxPlotRepairComplain', conditions: { category: WxPlotRepairComplain::REPAIR }, order: 'wx_plot_repair_complains.created_at DESC'
  has_many :complain_advices, class_name: 'WxPlotRepairComplain', conditions: { category: [WxPlotCategory::COMPLAIN, WxPlotCategory::ADVICE] }, order: 'wx_plot_repair_complains.created_at DESC'
  has_many :wx_invites, foreign_key: :from_user_id
  has_many :likes, as: :likeable
  has_many :comments, as: :commenter

  has_many :shop_orders
  has_many :feedbacks, as: :user

  delegate :leave_message_forbidden, to: :wx_user, allow_nil: true
  delegate :headimgurl, to: :wx_user, allow_nil: true

  #TODO
  # scope :message_forbidden, ->{ where(leave_message_forbidden: 1)}
  # scope :message_normal, ->{ where(leave_message_forbidden: 0)}

  def self.current
    Thread.current[:user]
  end
  def self.current=(user)
    Thread.current[:user] = user
  end

  def self.message_forbidden
    joins(:wx_user).where(wx_user: { leave_message_forbidden: 1 })
  end

  def self.message_normal
    joins(:wx_user).where(wx_user: { leave_message_forbidden: 0 })
  end

  def nickname
    name.presence || wx_user.nickname
  end

  def related_mobile
    vip_mobile || consumes_mobile
  end

  def consumes_mobile
    activity_consumes.pluck(:mobile).uniq.compact.last
  end

  def consumes_for_activity(activity)
    if activity.guess? && activity.guess_setting.prize
      consumes.where(consumable_id: activity.guess_setting.prize_id, consumable_type: activity.guess_setting.prize_type)
    end
  end

  def vip_mobile
    vip_user.try(:mobile)
  end

  def applicable_for_coupon_by_vip?(coupon, vip)
    return false if vip.nil? || !vip.normal?
    coupon.usable_vip_grades.include?(vip.vip_grade)
  end

  # MATCH_TYPE_OPTIONS.map(&:first).each do |match_type|
  #   define_method "#{match_type}!" do
  #     update_attributes(match_type: WxUser.const_get(match_type.upcase), match_at: Time.now)
  #   end
  # end

  def wbbs_topics_count
    wbbs_topics.count
  end

  def wbbs_up_count
    wbbs_topics.sum(:up_count)
  end

  def wbbs_reports_count
    wbbs_topics.sum(:reports_count)
  end

  def wbbs_replies_count
    wbbs_topics.sum(:wbbs_replies_count)
  end

  # 没有叫过外卖订单的用户
  def take_out_new_user?
    shop_orders.formal.count.zero?
  end

  def has_info?
    nickname.present? && headimgurl.present?
  end

  def logo_url
    headimgurl || '/assets/wx_wall/user-img.jpg'
  end

  def guess_left_count(activity)
   return '无限' if (activity.guess_setting.user_day_answer_limit == -1 && activity.guess_setting.user_total_answer_limit == -1)
   arr = []
   if activity.guess_setting.user_day_answer_limit != -1
    arr << (activity.guess_setting.user_day_answer_limit - guess_participations_today(activity).count)
   end
   if activity.guess_setting.user_total_answer_limit != -1
    arr << (activity.guess_setting.user_total_answer_limit - guess_participations_all(activity).count)
   end
   [arr.min, 0].max
  end

  def can_not_guess?(activity)
    guess_left_count(activity) == 0
  end

  def guess_participations_today(activity)
    guess_participations_all(activity).today
  end

  def guess_participations_all(activity)
    activity.guess_participations.where(user_id: id)
  end

  def gua_left_count(activity_id)
    left_count_arr = []
    activity = Activity.find(activity_id)
    self_lottery_draws = activity.lottery_draws.where(user_id: id)
    if activity.activity_property.day_partake_limit != -1
      left_count_arr << activity.activity_property.day_partake_limit - self_lottery_draws.today.count #每人每天参与次数
    end

    if activity.activity_property.partake_limit != -1
      left_count_arr << activity.activity_property.partake_limit - self_lottery_draws.count  #每人参与总次数
    end

    left_count_arr.min || 99
  end

  def qrcode_user_amount(column_name,amount)
    qrcode = qrcode_logs.normal.earliest.first
    if qrcode
      qrcode_user = qrcode_users.where(site_id: site_id, qrcode_id: qrcode.try(:qrcode_id)).first_or_create
      qrcode_user[column_name] += amount.to_f
      qrcode_user.save if qrcode_user[column_name] >= 0
    end
  end

end

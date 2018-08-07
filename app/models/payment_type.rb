class PaymentType < ActiveRecord::Base

  CSS_CLASS = {
    10005 => 'zhifu1',
    10001 => 'zhifu2',
    20001 => 'zhifu2',
    10003 => 'zhifu3',
    20003 => 'zhifu3',
    10002 => 'zhifu4',
    20002 => 'zhifu4'
  }

  ENUM_ID_OPTIONS = [
    ['cashpay', 10000, '货到付款'],
    ['wxpay', 10001, '微信支付'],
    ['yeepay', 10002, '易宝支付'],
    ['alipay', 10003, '支付宝支付'],
    ['tenpay', 10004, '财付通支付'],
    ['vip_userpay', 10005, '余额支付'],
    ['wx_redpacket_pay', 10006, '微信红包'],
    ['proxy_wxpay', 20001, '微信代支付'],
    ['proxy_yeepay', 20002, '易宝代支付'],
    ['proxy_alipay', 20003, '支付宝代支付'],
  ]

  enum_attr :id, in: ENUM_ID_OPTIONS

  enum_attr :status, :in => [
    ['enabled', 1, '启用'],
    ['disabled', -1, '停用'],
  ]

end

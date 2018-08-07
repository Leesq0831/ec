module CalculateDistance
  extend ActiveSupport::Concern
  EARTH_RADIUS = 6378137.0 #地球半径
  PI = Math::PI

  def real_address(real_address)
    [real_address.city.try(:name), real_address.district.try(:name), real_address.address].compact.join
  end

  def get_shop_branch_location(address)
    params = {address: address, output: 'json', ak: '9c72e3ee80443243eb9d61bebeed1735'}
    result = RestClient.get('http://api.map.baidu.com/geocoder/v2/', params: params)
    data = JSON(result)
    data['result']['location']
  rescue
    {}
  end

  def self.get_rad(d)
    return d.to_f*PI/180.0
  end

  def get_great_circle_distance(lat1, lng1, lat2, lng2)
    lat1, lng1, lat2, lng2 = [lat1, lng1, lat2, lng2].map(&:to_f)
    radLat1 = CalculateDistance.get_rad(lat1)
    radLat2 = CalculateDistance.get_rad(lat2)
    a = radLat1 - radLat2
    b = CalculateDistance.get_rad(lng1) - CalculateDistance.get_rad(lng2)
    s = 2*Math.asin(Math.sqrt(Math.sin(a/2)**2 + Math.cos(radLat1)*Math.cos(radLat2)*Math.sin(b/2)**2))
    s = s*EARTH_RADIUS
    return (s/1000).round(2)
  end

  def calculate_distance(shop_address, user_address)
    shop_detail_address = real_address(shop_address)
    shop_result = get_shop_branch_location(shop_detail_address)
    puts shop_result
    lat1 = shop_result['lat']
    lng1 = shop_result['lng']
    user_result = get_shop_branch_location(user_address)
    lat2 = user_result['lat']
    lng2 = user_result['lng']
    distance = get_great_circle_distance(lat1, lng1, lat2, lng2)
    distance
  end

end
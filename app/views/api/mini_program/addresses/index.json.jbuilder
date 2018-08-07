json.addresses @addresses do |address|
  json.id 			address.id
  json.province		address.province.try(:name)
  json.city			address.city.try(:name)
  json.district		address.district.try(:name)
  json.address      address.address
  json.username     address.username
  json.mobile       address.mobile
  json.is_default	address.is_default
  json.detail 		"#{address.province.try(:name)}" + "#{address.city.try(:name)}" + "#{address.district.try(:name)}" + "#{address.address}"
end
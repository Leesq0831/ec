total_pay = 0.00
logistic = 0.00
if @order
  json.items @ec_item do |item|
    item_pay = (@qty.to_i * item.price.round(2)).round(2)
    total_pay = total_pay + item_pay
    json.id             nil
    json.ec_item_id     item.id
    json.qty            @qty
    json.price          item.price
    json.pic            item.try(:ec_product).try(:ec_picture).try(:pic_url)
    json.name           item.try(:ec_product).try(:name)
    json.item_name      item.name
    json.total_price    item_pay
    if @address && item.ec_logistic_template
      logistic = logistic + item.logistic(@address.city_id, @qty.to_i).to_f.round(2)
    end
  end
else
  json.items @cart_items do |item|
    item_pay = (item.qty.round(2) * item.original_price.round(2)).round(2)
    total_pay = total_pay + item_pay
    json.id           item.id
    json.ec_item_id   item.try(:ec_item).try(:id)
    json.price        item.original_price
    json.qty          item.qty
    json.pic          item.try(:ec_item).try(:ec_product).try(:ec_picture).try(:pic_url)
    json.name         item.try(:ec_item).try(:ec_product).try(:name)
    json.item_name    item.try(:ec_item).try(:name)
    json.total_price  item_pay

    if @address && item.ec_item.ec_logistic_template_id.present?
      logistic = logistic + (item.ec_item.logistic(@address.city_id, item.qty)).round(2)
    end
  end
end

json.total_pay total_pay
json.logistic logistic
json.site @current_site.try(:id) 

if @address
  json.address [
    @address.id,
    @address.username,
    @address.mobile,
    @address.is_default,
    "#{@address.province.try(:name)}" + "#{@address.city.try(:name)}" + "#{@address.district.try(:name)}" + "#{@address.address}"
  ]
else
  json.address []
end
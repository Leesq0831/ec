module PrintCenter
  def print_receipt
    if printer && printer.set?
      options = {
        deviceNo: printer.printer_id,
        key: printer.printer_key,
        times: printer.print_times,
        printContent: print_content
      }

      result = RestClient.post(URI::encode("http://open.printcenter.cn:8080/addOrder"), options)
      data = JSON(result)

      SiteLog::Base.logger('print', "****** [ShopOrder] order #{id} print response: #{data}")

      if [0, 1, 2, 3].include?(data['responseCode'].to_i)
        to_print(data['responseCode'], data['orderindex'])
      end
    else
      Rails.logger.info "not set printer at shop_branch_print_templates"
    end
  rescue => error
    SiteLog::Base.logger('print', "****** [ShopOrder] order #{id} print error response: #{error.message}")
  end

  def printer
    if self.is_a?(ShopOrder)
      shop_branch.get_templates self
    end
  end

  def print_content
    # content = "^N1^F1\n"
    content = "^B2 #{printer.title || '欢迎光临'}\n"
    content += "^H2订单编号：#{order_no}\n"
    content += "^H2送餐时间：#{book_at.to_s}\n"
    # content += "^H2下单时间：#{created_at.to_s}\n"
    # content += "^H1下单门店：#{shop_branch.try(:name)}\n"
    content += "^H2用户姓名：#{username}\n"
    content += "^H2联系电话：#{mobile[0..2]}-#{mobile[3..6]}-#{mobile[7..-1]}\n"
    if address.to_s.size > 11
      content += "^H2送餐地址：#{address.to_s[0..10]}\n"
      content += "^H2#{address.to_s[11..-1]}\n"
    else
      content += "^H2送餐地址：#{address.to_s}\n"
    end
    if description.to_s.size > 13
      content += "^H2备注：#{description.to_s[0..13]}\n"
      content += "^H2#{description.to_s[14..-1]}\n"
    else
      content += "^H2备注：#{description}\n" if description.present?
    end
    # content += "名称　　　　　 单价    数量 金额\n"
    # content += "西红柿鸡蛋炒饭 100.0  10  100.0\n"
    content += "^H2" + text_format("菜品名称", 12) + text_format("数量x单价", 9) + " " + text_format("小计", 5) + "\n"
    content += "--------------------------------\n"
    shop_order_items.each do |item|
      content += "^H2" + text_format("#{item.product_name}", 12) + text_format("#{item.qty}x#{item.price}", 9) + " " + text_format("#{item.total_price}", 5) + "\n"
    end
    content += "--------------------------------\n"
    content += "^H2配送费：#{deliver_amount}元\n"
    content += "^H2合计：#{total_amount}元\n"

    content
  end

  def text_format(str, length)
    str = truncate_u(str, options = {length: length})
    space_length = (length - text_length(str)) < 0 ? 0 : (length - text_length(str))

    return str + " " * space_length
  end

  def text_length(str)
    char_array = str.unpack("U*")

    l = 0
    char_array.each_with_index do |c, i|
      l = l + (c < 127 ? 1 : 2)
    end

    l
  end

  def truncate_u(text, options = {})
    options.reverse_merge!(length: 30, omission: '')

    l = 0
    char_array = text.to_s.unpack("U*")
    char_array.each_with_index do |c,i|
      l = l + (c < 127 ? 0.5 : 1)
      if l > options[:length]
        return char_array[0...i].pack("U*") + (i ? options[:omission] : "")
      end
    end

    text
  end

end
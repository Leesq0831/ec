class Api::PrinterController < Api::BaseController
  def index
    if params[:device_no] && params[:key]
      result = RestClient.post(URI::encode("http://open.printcenter.cn:8080/queryPrinterStatus"), {deviceNo: params[:device_no], key: params[:key]})
      data = JSON(result)

      result = case data['responseCode'].to_i
      when 1
        '打印机正常在线'
      when 2
        '打印机缺纸'
      when 3
        '打印机下线'
      when 4
        '错误的机器号或口令'
      else
        '未知错误'
      end
    else
      result = '打印机还未设置'
    end

    respond_to do |format|
      format.json {render json: [result]}
    end
  end
end
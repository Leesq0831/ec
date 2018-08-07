class Api::MiniProgram::AddressesController < Api::MiniProgram::BaseController
  #skip_before_filter :set_wx_mp_user
  before_filter :find_address, only: [:show, :edit, :update, :destroy, :set_default]

  def index
    @addresses = @current_user.ec_addresses.order("is_default desc, created_at asc")
    respond_to :json
  end

  def create
    if params[:ec_address][:is_default] == "true"
      @current_user.ec_addresses.update_all(is_default: false)
    end
    @address = @current_user.ec_addresses.new(params[:ec_address])
    respond_to do |format|
      format.json { render json: {code: @address.save ? 1 : 0, id: @address.try(:id)} }
    end
  end

  def edit
    city_id = @address.province.cities.pluck(:id).index(@address.city_id) rescue 0
    district_id = @address.city.districts.pluck(:id).index(@address.district_id) rescue 0

    render json: {code: 1, address: @address, city: city_id, district: district_id, p: @address.province.try(:name), c: @address.city.try(:name), d: @address.district.try(:name) }
  end

  def update
    if !@address.is_default && params[:ec_address][:is_default] == "true"
      @current_user.ec_addresses.update_all(is_default: false)
    end

    respond_to do |format|
      format.json {render json: {code: @address.update_attributes(params[:ec_address]) ? 1 : 0 , id: @address.try(:id)}}
    end
  end

  def destroy
    respond_to do |format|
      format.json {render json: {code: @address.destroy ? 1 : 0 }}
    end
  end

  def set_default
    address = @current_user.ec_addresses.where(is_default: true).first
    return render json: {code: 0}  if address.try(:id) == params[:id].to_i
    address.update_attributes(is_default: false) if address
    
    respond_to do |format|
      format.json { render json: {code: @address.update_attributes(is_default: true) ? 1 : -1} }
    end
  end

  private
    def find_address
      @address = @current_user.ec_addresses.where(id: params[:id]).first
    end
end

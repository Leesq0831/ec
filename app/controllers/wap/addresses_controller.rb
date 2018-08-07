class Wap::AddressesController < Wap::BaseController
  before_filter :find_address, only: [:show, :edit, :update, :destroy, :set_default]
  before_filter do
    @hidden_footer = true
  end

  def index
    @addresses = @user.ec_addresses.order("is_default desc, created_at asc")
  end

  def new
    @address = @user.ec_addresses.new
  end

  def create
    if params[:newadr].present?
      params[:newadr][:username] = params[:newadr].delete(:name)
      params[:newadr][:mobile] = params[:newadr].delete(:phone)
      params[:newadr][:province_id] = params[:newadr].delete(:sheng)
      params[:newadr][:city_id] = params[:newadr].delete(:shi)
      params[:newadr][:district_id] = params[:newadr].delete(:qu)
      params[:newadr][:address] = params[:newadr].delete(:street)
    end

    @address = @user.ec_addresses.new(params[:data] || params[:newadr])
    if @user.ec_addresses.count == 0
      @address.is_default = true
    end
    if @address.save
      respond_to do |format|
        format.json { render json: {code: 1, data: @address.address_display} }
      end
    else
      respond_to do |format|
        format.json { render json: {code: 0} }
      end
    end
  end

  def update
    if @address.update_attributes(params[:data])
      respond_to do |format|
        format.json { render json: {code: 1} }
      end
    else
      respond_to do |format|
        format.json { render json: {code: 0} }
      end
    end
  end

  def destroy
    if @address.destroy
      respond_to do |format|
        format.json { render json: {code: 1} }
      end
    else
      respond_to do |format|
        format.json { render json: {code: 0} }
      end
    end
  end

  def set_default
    @user.ec_addresses.each{|m| m.update_attributes(is_default: false)}
    @address.update_attributes(is_default: true)
    respond_to do |format|
      format.json { render json: @address }
    end
  end

  private

    def find_address
      @address = @user.ec_addresses.where(id: params[:id]).first
    end
end

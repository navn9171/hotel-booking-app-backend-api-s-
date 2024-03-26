class Api::V1::HotelController < ApplicationController

    # all hotels listing having filter of location
    def index
        if !params[:location].present? && params[:location].blank?
            @hotels = Hotel.all
        else
            @hotels = Hotel.where("location LIKE ?", "%" + params[:location] + "%")
        end

        render :json => @hotels
    end

end

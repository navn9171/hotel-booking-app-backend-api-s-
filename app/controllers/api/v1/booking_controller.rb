class Api::V1::BookingController < ApplicationController
    before_action :set_current_user, only: [:index, :booked_hotels]

    def set_current_user
        @user = User.find_by_id(1)
        if @user.nil?
            render :json => "User Not Found" and return
        end
    end

    # list all booking of an user
    def index
        begin
            @bookings = @user.bookings
            render :json => @bookings, :status => 200
        rescue
            render :json => "Something went wrong!", :status => 500
        end
    end

    # book hotel
    # {
    #     "booking" : 
    #         {
    #             "hotel_id" : 1,
    #             "user_id" : 1,
    #             "no_of_room" : 2,
    #             "check_in" : "21/03/2024",
    #             "check_out" : "23/03/2024"
    #         }
    # }
    def book_hotel
        if !params[:booking].nil? && permit_params()
            begin
                params[:booking][:check_in] = Date.parse(params[:booking][:check_in]).strftime("%d/%m/%Y") if !params[:booking][:check_in].nil?
                params[:booking][:check_out] = Date.parse(params[:booking][:check_out]).strftime("%d/%m/%Y") if !params[:booking][:check_out].nil?
                message, status = Booking.create_booking(params[:booking])
                if status
                    render :json => message, :status => 201
                else
                    render :json => message, :status => 400
                end
            rescue
                render :json => "Something went wrong!", :status => 500
            end
        end
    end

    # user booked hotels listing
    def booked_hotels
        begin
            booking_arr = Booking.get_all_booked_hotels(@user)
            render :json => booking_arr, :status => 200
        rescue
            render :json => "Something went wrong!", :status => 500
        end
    end

    # cancel booking
    def destroy
        begin
            if params[:id].present? and !params[:id].blank?
                @booking = Booking.find_by_id(params[:id])
                if !@booking.nil?
                    @booking.destroy
                    render :json => "Booking cancelled successfully.", :status => 200
                else
                    render :json => "Booking Not found with the ID: "+params[:id], :status => 404
                end
            end
        rescue
            render :json => "Something went wrong!", :status => 500
        end
    end

    def update
        # begin
            if params[:id].present? && !params[:id].blank?
                @booking = Booking.find_by_id(params[:id])
                if !@booking.nil?
                    if !params[:booking].blank? && permit_params_update()
                        params[:booking][:check_in] = Date.parse(params[:booking][:check_in]).strftime("%d/%m/%Y") if !params[:booking][:check_in].nil?
                        params[:booking][:check_out] = Date.parse(params[:booking][:check_out]).strftime("%d/%m/%Y") if !params[:booking][:check_out].nil?
                        message, status = @booking.update_booking_details(params[:booking])
                        if status
                            render :json => message, :status => 201
                        else
                            render :json => message, :status => 400
                        end 
                    else
                        render :json => "Please send request body correctly", :status => 400
                    end
                else
                    render :json => "Booking Not found with the ID: "+params[:id], :status => 404
                end
            else
                render :json => "Please send correct booking ID", :status => 400
            end
        # rescue
        #     render :json => "Something went wrong!", :status => 500
        # end
    end
    
    def show
        @booking = Booking.find_by_id(params[:id])
        if !@booking.nil?
            render :json => @booking, :status => 200
        else
            render :json => "Booking not found with the ID: "+params[:id], :status => 404
        end
    end

    def permit_params
        params.require(:booking).permit(:user_id, :hotel_id, :no_of_room, :check_in, :check_out)
    end

    def permit_params_update
        params.require(:booking).permit(:no_of_room, :check_in, :check_out)
    end
end

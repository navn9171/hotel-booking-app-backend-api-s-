class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :hotel

  def self.create_booking(params)
    msg = ""
    status = false
    if validate_date_params(params)
      @booking = Booking.new()
      @booking.no_of_room = params["no_of_room"]
      @booking.check_in = params["check_in"]
      @booking.check_out = params["check_out"]
      @booking.hotel_id = params["hotel_id"]
      @booking.user_id = params["user_id"]
      if @booking.save
        msg = "Hotel Booked Successfully"
        status = true
      else
        msg = "Something went wrong. Please Try again later"
        status = false
      end
    else
      msg = "Check IN Date must be less than the Check OUT Date."
      status = false
    end
    return msg, status
  end

  def self.validate_date_params(params)
    flag = false
    check_in = params["check_in"]
    check_out = params["check_out"]
    if(check_in < check_out)
      flag = true
    end

    return flag
  end

  def self.get_all_booked_hotels(user)
    arr = []
    booking_obj = user.bookings
    if !booking_obj.nil?
      hotel_ids = booking_obj.map(&:hotel_id).uniq.join(',')
      if !hotel_ids.blank?
        hotels = Hotel.where("id in (#{hotel_ids})")
        booking_obj.each do |booking|
          hotel_obj = hotels.select{|x| x.name if x.id == booking.hotel_id}
          hotel_name = hotel_obj[0].name
          hotel_location = hotel_obj[0].location
          arr<<{:booking_id => booking.id, :hotel_name => hotel_name, :location => hotel_location, :check_in_date => booking.check_in, :check_out_date => booking.check_out, :no_of_room => booking.no_of_room}
        end
      end
    end

    return arr
  end

  def update_booking_details(params)
    status = false
    if self.validate_updated_dates(params)
      if self.update(:no_of_room => params["no_of_room"], :check_in => params["check_in"], :check_out => params["check_out"])
        msg = "Booking Updated Successfully"
        status = true
      else
        msg = "Something went wrong. Please try again"
      end
    else
      msg = "Please send check_in/check_out dates correctly"
    end

    return msg, status
  end

  def validate_updated_dates(params)
    flag = false
    check_in_date = params["check_in"]
    check_out_date = params["check_out"]
    if(check_in_date < check_out_date && (check_in_date.to_date > Date.today && check_out_date.to_date > Date.today))
      flag = true
    end

    return flag
  end

end

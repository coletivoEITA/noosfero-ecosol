def __split_nil_time
  Time.parse("#{Time.now.hour}:0:0")
end
def __split_nil_date
  Date.today
end

def __split_to_time(datetime)
  datetime = __split_nil_time if datetime.blank?
  datetime.to_time.to_formatted_s(:time)
end
def __split_to_date(datetime)
  datetime = __split_nil_date if datetime.blank?
  datetime.to_date.strftime('%d/%m/%Y')
end
def __split_set_time(datetime, value)
  value = if value.blank?
    __split_nil_time
  elsif value.kind_of?(String)
    Time.parse(value)
  else
    value.to_time
  end
  datetime = __split_nil_date if datetime.blank?

  Time.mktime(datetime.year, datetime.month, datetime.day, value.hour, value.min, value.sec).to_datetime
end
def __split_set_date(datetime, value)
  value = if value.blank?
    __split_nil_date
  elsif value.kind_of?(String)
    DateTime.strptime(value, '%d/%m/%Y')
  else
    value.to_time
  end
  datetime = __split_nil_time if datetime.blank?

  Time.mktime(value.year, value.month, value.day, datetime.hour, datetime.min, datetime.sec).to_datetime
end

module SplitDatetime

  module SplitMethods

    def split_datetime(attr)
      class_eval do
        define_method (attr.to_s+'_time') do
          datetime = send(attr.to_s)
          __split_to_time(datetime)
        end
        define_method (attr.to_s+'_date') do
          datetime = send(attr.to_s)
          __split_to_date(datetime)
        end
        define_method (attr.to_s+'_time=') do |value|
          datetime = send(attr.to_s)
          send(attr.to_s+'=', __split_set_time(datetime, value))
        end
        define_method (attr.to_s+'_date=') do |value|
          datetime = send(attr.to_s)
          send(attr.to_s+'=', __split_set_date(datetime, value))
        end
      end
    end

  end

end

Class.extend SplitDatetime::SplitMethods
ActiveRecord::Base.extend SplitDatetime::SplitMethods

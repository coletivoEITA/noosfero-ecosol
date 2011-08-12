def __split_to_time(datetime)
  datetime.to_time.to_formatted_s(:time)
end
def __split_to_date(datetime)
  datetime.to_date.to_formatted_s(:db)
end
def __split_set_time(datetime, value)
  value = Time.parse(value) if value.kind_of?(String)
  Time.mktime(datetime.year, datetime.month, datetime.day, value.hour, value.min, value.sec).to_datetime
end
def __split_set_date(datetime, value)
  value = value.to_date
  Time.mktime(value.year, value.month, value.day, datetime.hour, datetime.min, datetime.sec).to_datetime
end

module SplitDatetime

  module SplitMethods
    def split_datetime(attr)
      class_eval do
        define_method (attr.to_s+'_time') do
          datetime = send(attr.to_s)
          __split_to_time(datetime) if datetime
        end
        define_method (attr.to_s+'_date') do
          datetime = send(attr.to_s)
          __split_to_date(datetime) if datetime
        end
        define_method (attr.to_s+'_time=') do |value|
          datetime = send(attr.to_s)
          send(attr.to_s+'=', __split_set_time(datetime, value)) if datetime
        end
        define_method (attr.to_s+'_date=') do |value|
          datetime = send(attr.to_s)
          send(attr.to_s+'=', __split_set_date(datetime, value)) if datetime
        end
      end
    end
  end
end

Class.extend SplitDatetime::SplitMethods
ActiveRecord::Base.extend SplitDatetime::SplitMethods

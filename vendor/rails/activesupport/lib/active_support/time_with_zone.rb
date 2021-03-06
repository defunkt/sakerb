module ActiveSupport
  # A Time-like class that can represent a time in any time zone. Necessary because standard Ruby Time instances are 
  # limited to UTC and the system's ENV['TZ'] zone
  class TimeWithZone
    include Comparable
    attr_reader :time_zone
  
    def initialize(utc_time, time_zone, local_time = nil, period = nil)
      @utc, @time_zone, @time = utc_time, time_zone, local_time
      @period = @utc ? period : get_period_and_ensure_valid_local_time
    end
  
    # Returns a Time or DateTime instance that represents the time in time_zone
    def time
      @time ||= utc_to_local
    end

    # Returns a Time or DateTime instance that represents the time in UTC
    def utc
      @utc ||= local_to_utc
    end
    alias_method :comparable_time, :utc
    alias_method :getgm, :utc
    alias_method :getutc, :utc
    alias_method :gmtime, :utc
  
    # Returns the underlying TZInfo::TimezonePeriod
    def period
      @period ||= time_zone.period_for_utc(@utc)
    end

    # Returns the simultaneous time in the specified zone
    def in_time_zone(new_zone)
      return self if time_zone == new_zone
      utc.in_time_zone(new_zone)
    end
  
    # Returns the simultaneous time in Time.zone
    def in_current_time_zone
      utc.in_current_time_zone
    end
  
    # Returns a Time.local() instance of the simultaneous time in your system's ENV['TZ'] zone
    def localtime
      utc.getlocal
    end
    alias_method :getlocal, :localtime
  
    def dst?
      period.dst?
    end
    alias_method :isdst, :dst?
  
    def utc?
      time_zone.name == 'UTC'
    end
    alias_method :gmt?, :utc?
  
    def utc_offset
      period.utc_total_offset
    end
    alias_method :gmt_offset, :utc_offset
    alias_method :gmtoff, :utc_offset
  
    def formatted_offset(colon = true, alternate_utc_string = nil)
      utc? && alternate_utc_string || utc_offset.to_utc_offset_s(colon)
    end
  
    # Time uses #zone to display the time zone abbreviation, so we're duck-typing it
    def zone
      period.abbreviation.to_s
    end
  
    def inspect
      "#{time.strftime('%a, %d %b %Y %H:%M:%S')} #{zone} #{formatted_offset}"
    end

    def xmlschema
      "#{time.strftime("%Y-%m-%dT%H:%M:%S")}#{formatted_offset(true, 'Z')}"
    end
    alias_method :iso8601, :xmlschema
  
    def to_json(options = nil)
      %("#{time.strftime("%Y/%m/%d %H:%M:%S")} #{formatted_offset(false)}")
    end
    
    def to_yaml(options = {})
      time.to_yaml(options).gsub('Z', formatted_offset(true, 'Z'))
    end
    
    def httpdate
      utc.httpdate
    end
  
    def rfc2822
      to_s(:rfc822)
    end
    alias_method :rfc822, :rfc2822
  
    # :db format outputs time in UTC; all others output time in local. Uses TimeWithZone's strftime, so %Z and %z work correctly
    def to_s(format = :default) 
      return utc.to_s(format) if format == :db
      if formatter = ::Time::DATE_FORMATS[format]
        formatter.respond_to?(:call) ? formatter.call(self).to_s : strftime(formatter)
      else
        "#{time.strftime("%Y-%m-%d %H:%M:%S")} #{formatted_offset(false, 'UTC')}" # mimicking Ruby 1.9 Time#to_s format
      end
    end
    
    # Replaces %Z and %z directives with #zone and #formatted_offset, respectively, before passing to 
    # Time#strftime, so that zone information is correct
    def strftime(format)
      format = format.gsub('%Z', zone).gsub('%z', formatted_offset(false))
      time.strftime(format)
    end
  
    # Use the time in UTC for comparisons
    def <=>(other)
      utc <=> other
    end
    
    def between?(min, max)
      utc.between?(min, max)
    end
    
    def eql?(other)
      utc == other
    end
    
    # If wrapped #time is a DateTime, use DateTime#since instead of #+
    # Otherwise, just pass on to #method_missing
    def +(other)
      time.acts_like?(:date) ? method_missing(:since, other) : method_missing(:+, other)
    end
    
    # If a time-like object is passed in, compare it with #utc
    # Else if wrapped #time is a DateTime, use DateTime#ago instead of #-
    # Otherwise, just pass on to method missing
    def -(other)
      if other.acts_like?(:time)
        utc - other
      else
        time.acts_like?(:date) ? method_missing(:ago, other) : method_missing(:-, other)
      end
    end
    
    %w(asctime day hour min mon sec usec wday yday year).each do |name|
      define_method(name) do
        time.__send__(name)
      end
    end
    alias_method :ctime, :asctime
    alias_method :mday, :day
    alias_method :month, :mon
    
    %w(sunday? monday? tuesday? wednesday? thursday? friday? saturday?).each do |name|
      define_method(name) do
        time.__send__(name)
      end
    end unless RUBY_VERSION < '1.9'
    
    def to_a
      [time.sec, time.min, time.hour, time.day, time.mon, time.year, time.wday, time.yday, dst?, zone]
    end
    
    def to_f
      utc.to_f
    end    
    
    def to_i
      utc.to_i
    end
    alias_method :hash, :to_i
    alias_method :tv_sec, :to_i
  
    # A TimeWithZone acts like a Time, so just return self
    def to_time
      self
    end
    
    def to_datetime
      utc.to_datetime.new_offset(Rational(utc_offset, 86_400))
    end
    
    # so that self acts_like?(:time)
    def acts_like_time?
      true
    end
  
    # Say we're a Time to thwart type checking
    def is_a?(klass)
      klass == ::Time || super
    end
    alias_method :kind_of?, :is_a?
  
    # Neuter freeze because freezing can cause problems with lazy loading of attributes
    def freeze
      self
    end

    def marshal_dump
      [utc, time_zone.name, time]
    end
    
    def marshal_load(variables)
      initialize(variables[0], ::TimeZone[variables[1]], variables[2])
    end
  
    # Ensure proxy class responds to all methods that underlying time instance responds to
    def respond_to?(sym)
      # consistently respond false to acts_like?(:date), regardless of whether #time is a Time or DateTime
      return false if sym.to_s == 'acts_like_date?'
      super || time.respond_to?(sym)
    end
  
    # Send the missing method to time instance, and wrap result in a new TimeWithZone with the existing time_zone
    def method_missing(sym, *args, &block)
      result = utc.__send__(sym, *args, &block)
      result = result.in_time_zone(time_zone) if result.acts_like?(:time)
      result
    end
    
    private      
      def get_period_and_ensure_valid_local_time
        # we don't want a Time.local instance enforcing its own DST rules as well, 
        # so transfer time values to a utc constructor if necessary
        @time = transfer_time_values_to_utc_constructor(@time) unless @time.utc?
        begin
          @time_zone.period_for_local(@time)
        rescue ::TZInfo::PeriodNotFound
          # time is in the "spring forward" hour gap, so we're moving the time forward one hour and trying again
          @time += 1.hour
          retry
        end
      end
      
      def transfer_time_values_to_utc_constructor(time)
        ::Time.utc_time(time.year, time.month, time.day, time.hour, time.min, time.sec, time.respond_to?(:usec) ? time.usec : 0)
      end
    
      # Replicating logic from TZInfo::Timezone#utc_to_local because we want to cache the period in an instance variable for reuse
      def utc_to_local
        ::TZInfo::TimeOrDateTime.wrap(utc) {|utc| period.to_local(utc)}
      end
      
      # Replicating logic from TZInfo::Timezone#local_to_utc because we want to cache the period in an instance variable for reuse
      def local_to_utc
        ::TZInfo::TimeOrDateTime.wrap(time) {|time| period.to_utc(time)}
      end
  end
end

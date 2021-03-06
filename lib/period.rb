require_relative 'period/version.rb'
require 'active_support/all'
require 'i18n'

I18n.load_path << File.expand_path("../config/locales/en.yml", __dir__)
I18n.load_path << File.expand_path("../config/locales/fr.yml", __dir__)

require_relative 'numeric.rb'
require_relative 'period/free_period.rb'
require_relative 'period/day.rb'
require_relative 'period/week.rb'
require_relative 'period/month.rb'
require_relative 'period/quarter.rb'
require_relative 'period/year.rb'

module Period
  def self.new(range)
    Period::FreePeriod.new(range)
  end

  def self.env_time
    (Time.zone || Time)
  end

  class << self
    %i[day week month quarter year].each do |period|
      define_method "last_#{period}" do
        date = env_time.now.send(period == :day ? 'yesterday' : "last_#{period}")
        Object.const_get("Period::#{period.capitalize}").new(date)
      end

      define_method "this_#{period}" do
        Object.const_get("Period::#{period.capitalize}").new(env_time.now)
      end

      define_method "next_#{period}" do
        date = env_time.now.send(period == :day ? 'tomorrow' : "next_#{period}")
        Object.const_get("Period::#{period.capitalize}").new(date)
      end

      define_method period.to_s do |range|
        Object.const_get("Period::#{period.capitalize}").new(range)
      end
    end

    alias yesterday last_day
    alias tomorrow next_day
    alias today this_day

    def method_missing(method_name, *arguments, &block)
      super unless method_name.match?(/(last|next)_\d+_(day|week|month|quarter|year)s?(_from_now)?/)
      last_next, count, klass = method_name.to_s.split('_')
      klass = klass.singularize

      case last_next
      when 'last'
        from = count.to_i.send(klass).ago.send("beginning_of_#{klass}")
        to = env_time.now
        to -= 1.send(klass) unless method_name.match?(/from_now$/)
        to = to.send("end_of_#{klass}")
      when 'next'
        from = env_time.now
        from += 1.send(klass) unless method_name.match?(/from_now$/)
        from = from.send("beginning_of_#{klass}")
        to = count.to_i.send(klass).from_now.send("end_of_#{klass}")
      end
      self.new(from..to)
    end

    def respond_to_missing?(method_name, include_private = false)
      method_name.match?(/(last|next)_\d+_(day|week|month|quarter|year)s?(_from_now)?/) || super
    end
  end
end

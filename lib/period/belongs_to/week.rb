module Period
  module BelongsTo
    # @author Lucas Billaudot <billau_l@modulotech.fr>
    # @note when include this module provide access to the week of the
    # FreePeriod
    module Week
      def week
        Period::Week.new(iso_date)
      end
    end
  end
end

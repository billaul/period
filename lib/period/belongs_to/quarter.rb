module Period
  module BelongsTo
    # @author Lucas Billaudot <billau_l@modulotech.fr>
    # @note when include this module provide access to the quarter of the
    # FreePeriod
    module Quarter
      def quarter
        Period::Quarter.new(iso_date)
      end
    end
  end
end

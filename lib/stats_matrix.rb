module StatsMatrix

  def self.included(base)
    base.send(:extend, ClassMethods)
  end


  module ClassMethods

    # Generates a matrix from current scope with
    #   stats names as it's root indexes,
    #   months number as 1st level indexes and
    #   values in a 3rd level.
    #
    # @example @school.school_monthly_stats.where(year: 2013).to_matrix
    # @return [Hash]
    def to_matrix
      Matrixer.new(self).to_matrix
    end
  end

end

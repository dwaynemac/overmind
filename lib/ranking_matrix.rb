class RankingMatrix
  
  attr_accessor :matrix

  def initialize(monthly_stats)
    
    # {School 1: [SchoolMonthlyStat 1, SchoolMonthlyStat 2, ...], School 2: [SchoolMonthlyStat 3, ...], ... , School n: [SchoolMon...]}
    @matrix = monthly_stats.group_by(&:school)
    
    # {
    #   School 1: {stat_name 1: SchoolMonthlyStat, stat_name 2: SchoolMonthlyStat, ...}, 
    #   School 2: {stat_name 1: SchoolMonthlyStat, stat_name 2: SchoolMonthlyStat, ...},
    #   ...,
    #   School n: {stat_name 1: SchoolMonthlyStat, stat_name 2: SchoolMonthlyStat, ...}
    # }
    @matrix.each do |school, stats_array|
      hash_of_stats = stats_array.group_by(&:name);
      hash_of_stats.each do |stat_name, stat_inside_array|
        hash_of_stats[stat_name] = stat_inside_array.first
      end
      @matrix[school] = hash_of_stats
    end
  
  end

end

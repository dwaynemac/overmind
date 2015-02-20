class TeacherRankingMatrix
  
  attr_accessor :matrix

  def initialize(monthly_stats)
    
    # {Teacher 1: [TeacherMonthlyStat 1, TeacherMonthlyStat 2, ...], Teacher 2: [TeacherMonthlyStat 3, ...], ... , Teacher n: [TeacherMon...]}
    @matrix = monthly_stats.group_by(&:teacher)
    
    # {
    #   Teacher 1: {stat_name 1: TeacherMonthlyStat, stat_name 2: TeacherMonthlyStat, ...}, 
    #   Teacher 2: {stat_name 1: TeacherMonthlyStat, stat_name 2: TeacherMonthlyStat, ...},
    #   ...,
    #   Teacher n: {stat_name 1: TeacherMonthlyStat, stat_name 2: TeacherMonthlyStat, ...}
    # }
    @matrix.each do |teacher, stats_array|
      hash_of_stats = stats_array.group_by(&:name);
      hash_of_stats.each do |stat_name, stat_inside_array|
        hash_of_stats[stat_name] = stat_inside_array.first
      end
      @matrix[teacher] = hash_of_stats
    end
  
  end

end

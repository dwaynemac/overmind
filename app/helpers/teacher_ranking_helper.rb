module TeacherRankingHelper
  def teacher_is_currently_in_team?(teacher)
    usernames = @school.account.users.map(&:username)
    u = PadmaUser.find teacher.try(:username)
    u && u.username.in?(usernames)
  end

  def non_zero_stats?(stats)
    stats && ( stats.sum(&:value) > 0 )
  end

  def any_diff?(acums,teachers_ranking)
    !teachers_ranking.column_names.select do |name|
      !MonthlyStat.is_a_rate?(name) && ((acums[name] || 0) - (teachers_ranking.school_stats[@school.id]["month"][name.to_s].try(:value) || 0) != 0)
    end.empty?
  end
end

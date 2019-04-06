module TeacherRankingHelper
  def teacher_is_currently_in_team?(teacher)
    usernames = @school.account.users.map(&:username)
    u = PadmaUser.find teacher.try(:username)
    u && u.username.in?(usernames)
  end

  def non_zero_stats?(stats)
    stats && ( stats.sum(&:value) > 0 )
  end
end

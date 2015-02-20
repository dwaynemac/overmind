module RankingsHelper

  def school_selected?(school_id, ranking)
    school_id.in?(ranking.school_ids)
  end

  def federation_selected?(fed_id, ranking)
    fed_id.in?(ranking.federation_ids)
  end

  def column_name_selected?(name, ranking)
    name.in?(ranking.column_names)
  end
end

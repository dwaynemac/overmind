module RankingsHelper

  def federation_selected?(fed_id, ranking)
    fed_id.in?(ranking.federation_ids)
  end

  def column_name_selected?(name, ranking)
    name.in?(ranking.column_names)
  end
end

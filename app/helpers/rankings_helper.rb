module RankingsHelper

  def federation_selected?(fed_id, ranking)
    fed_id.in?(ranking.federation_ids)
  end
end

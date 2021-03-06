require 'rails_helper'

describe LocalStat do
  describe ".has_special_reduction?" do
    it "returns true for :dropout_rate" do
      expect(LocalStat.has_special_reduction?(:dropout_rate)).to be_truthy
    end
    it "returns false for :dropouts" do
      expect(LocalStat.has_special_reduction?(:dropouts)).to be_falsey
    end
  end
  
  describe ".dependant_on" do
    it "returns local_stat_names dependent on given stat_name" do
      expect(LocalStat.dependant_on(:students).sort).to eq [
        :yogin_students_rate,
        :aspirante_students_rate,
        :chela_students_rate,
        :dropout_rate,
        :male_students_rate,
        :sadhaka_students_rate
      ].sort
    end
  end
end

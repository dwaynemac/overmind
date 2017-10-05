require 'spec_helper'

describe LocalStat do
  describe ".has_special_reduction?" do
    it "returns true for :dropout_rate" do
      expect(LocalStat.has_special_reduction?(:dropout_rate)).to be_true
    end
    it "returns false for :dropouts" do
      expect(LocalStat.has_special_reduction?(:dropouts)).to be_false
    end
  end
end

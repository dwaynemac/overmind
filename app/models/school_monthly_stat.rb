class SchoolMonthlyStat < MonthlyStat
  default_scope where(teacher_id: nil)
  attr_protected :teacher_id

  validate :teacher_id_should_be_nil

  private

  def teacher_id_should_be_nil
    unless teacher_id.nil?
      errors.add :teacher_id, 'should be nil'
    end
  end
end

class TeacherMonthlyStat < MonthlyStat
  belongs_to :teacher
  validates_uniqueness_of :name, scope: [:school_id, :teacher_id, :ref_date]
end

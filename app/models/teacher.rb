class Teacher < ActiveRecord::Base
  attr_accessible :full_name, :username

  has_and_belongs_to_many :schools

  has_many :monthly_stats, dependent: :destroy

  validates_uniqueness_of :username, allow_nil: true, allow_blank: true

  # Will find or create teacher from padma_username and full_name.
  #
  # Some updating will be applied to teacher to avoid duplication.
  # If school not linked, will be linked.
  # If full_name given but missing in record, will be updated
  # If username given but missing in record, will be updated
  #
  # @param padma_username [String]
  # @param full_name [String]
  # @param school [School]
  # @return [Teacher]
  def self.smart_find(padma_username,full_name,school=nil)
    t = nil
    unless padma_username.blank?
      t = Teacher.find_by_username(padma_username)
    end
    if t
      if t.full_name.blank? && !full_name.blank?
        t.update_attribute(:full_name, full_name)
      end
    else
      t = Teacher.find_by_full_name(full_name)
      if t && t.username.blank? && !padma_username.blank?
        t.update_attribute(:username, padma_username)
      end
    end
    unless t
      t = Teacher.create!(username: padma_username, full_name: full_name)
    end

    if school
      unless t.schools.include?(school)
        t.schools << school
        t.save
      end
    end

    t
  end
end

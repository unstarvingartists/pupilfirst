class Mentor < ActiveRecord::Base
  extend Forwardable

  MAX_SKILL_COUNT = 3

  AVAILABILITY_DAYS_EVERYDAY = 'everyday'
  AVAILABILITY_DAYS_WEEKDAYS = 'weekdays'
  AVAILABILITY_DAYS_WEEKENDS = 'weekends'

  def self.valid_days_available
    [AVAILABILITY_DAYS_EVERYDAY, AVAILABILITY_DAYS_WEEKDAYS, AVAILABILITY_DAYS_WEEKENDS]
  end

  AVAILABILITY_TIME_ALL_DAY = 'all_day'
  AVAILABILITY_TIME_MORNING = 'morning'
  AVAILABILITY_TIME_MIDDAY = 'midday'
  AVAILABILITY_TIME_AFTERNOON = 'afternoon'
  AVAILABILITY_TIME_EVENING = 'evening'

  def self.valid_time_available
    [AVAILABILITY_TIME_ALL_DAY, AVAILABILITY_TIME_MORNING, AVAILABILITY_TIME_MIDDAY, AVAILABILITY_TIME_AFTERNOON, AVAILABILITY_TIME_EVENING]
  end

  belongs_to :user
  accepts_nested_attributes_for :user
  has_many :skills, class_name: 'MentorSkill', dependent: :destroy
  has_many :mentor_meetings

  validates_presence_of :user
  validates_presence_of :company
  validates_length_of :company, maximum: 255
  validates_associated :user
  validates_presence_of :availability

  validate :skill_count_must_be_less_than_max

  scope :verified_mentors, -> { where 'verified_at IS NOT NULL' }

  def skill_count_must_be_less_than_max
    if self.skills.count > MAX_SKILL_COUNT
      self.errors.add(:skills, "Can't list more than 3 skills")
    end
  end

  serialize :availability, JSON

  def display_name
    user.email || user.fullname
  end

  def_delegator :user, :fullname, :name

  def to_s
    display_name
  end

  def days_available
    nil
  end

  def time_available
    nil
  end

  def days_available=(value)
    return if value.blank?
    self.availability = {} unless self.availability
    self.availability[:days] = convert_availability_days_to_dates(value)
  end

  def time_available=(value)
    return if value.blank?
    self.availability = {} unless self.availability
    self.availability[:time] = convert_availability_time_to_timing(value)
  end

  def add_skill(skill_id, expertise)
    skill = Category.mentor_skill_category.where(id: skill_id).first
    MentorSkill.create(mentor: self, skill: skill, expertise: expertise)
  end

  def verified?
    self.verified_at.present?
  end

  def self.listed_mentors(exclude: nil)
    list = verified_mentors
    exclude ? list.where.not(user_id: exclude.id) : list
  end

  private

  def convert_availability_days_to_dates(value)
    case value
      when AVAILABILITY_DAYS_EVERYDAY
        Date::DAYNAMES
      when AVAILABILITY_DAYS_WEEKDAYS
        Date::DAYNAMES[1..5]
      when AVAILABILITY_DAYS_WEEKENDS
        Date::DAYNAMES - Date::DAYNAMES[1..5]
      else
        Date::DAYNAMES
    end
  end

  def convert_availability_time_to_timing(value)
    case value
      when AVAILABILITY_TIME_ALL_DAY
        { after: 8, before: 20 }
      when AVAILABILITY_TIME_MORNING
        { after: 8, before: 11 }
      when AVAILABILITY_TIME_MIDDAY
        { after: 11, before: 14 }
      when AVAILABILITY_TIME_AFTERNOON
        { after: 14, before: 17 }
      when AVAILABILITY_TIME_EVENING
        { after: 17, before: 20 }
      else
        { after: 8, before: 20 }
    end
  end
end

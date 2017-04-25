class FounderPolicy < ApplicationPolicy
  def founder_profile?
    record.startup.present? && !record.level_zero?
  end

  def edit?
    founder_profile?
  end

  def update?
    founder_profile?
  end
end

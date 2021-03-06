class InterfacePermission < ApplicationRecord
  #---Associations----
  belongs_to :user
  belongs_to :user_group
  belongs_to :joule_module

  #---Validations---
  validate :user_xor_group

  def user_xor_group
    unless user.blank? ^ user_group.blank?
      errors.add(:base, "specify a user or group not both")
    end
  end

  def target_name
    if self.user_id?
      if self.user.name.empty?
        return self.user.email
      else
        return self.user.name
      end
    elsif self.user_group_id?
      return self.user_group.name
    else
      return "[no target set]"
    end
  end

  def target_type
    if self.user_id?
      return 'user'
    elsif self.user_group_id?
      return 'group'
    else
      return 'unknown'
    end
  end

  def self.json_keys
    [:id, :joule_module_id, :role, :priority]
  end

end

class MachineScopePolicy<ApplicationPolicy
  def update?
    user.av? || user.system?
    true
  end
end
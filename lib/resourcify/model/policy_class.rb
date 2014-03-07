module Model
  module PolicyClass
    def policy_class
      _p = "#{self.name}Policy" and _p.constantize and return _p
    rescue
      "ApiPolicy"
    end
  end
end
class String
  SINGULARS = {
    'pomodori' => 'pomodoro',
    'breaks' => 'break'
  }

  def singularize
    SINGULARS[self] || self
  end

  def pluralize
    SINGULARS.rassoc(self).first rescue self
  end
end

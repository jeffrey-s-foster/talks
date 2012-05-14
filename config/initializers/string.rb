class String
  def sanitize
    Sanitize.clean(self, Sanitize::Config::RELAXED).html_safe
  end
end

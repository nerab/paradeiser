# stand-in for 'action_view/helpers/text_helper'
def pluralize(count, singular, plural = nil)
  word = if (count == 1 || count =~ /^1(\.0+)?$/)
    singular
  else
    plural || singular.pluralize
  end

  "#{count || 0} #{word}"
end

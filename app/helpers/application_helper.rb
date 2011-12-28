module ApplicationHelper

  def join_with_and(a)
    return "" if a.length == 0
    return a[0] if a.length == 1
    return "#{a[0]} and #{a[1]}" if a.length == 2
    return "#{a[0..-2].join ","}, and #{a[-1]}"
  end
end

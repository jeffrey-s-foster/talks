module ApplicationHelper

  def join_with_and(a, m)
    return "" if a.length == 0
    return a[0].send(m) if a.length == 1
    return "#{a[0].send(m)} and #{a[1].send(m)}" if a.length == 2
    return "#{a[0..-2].map { |x| x.send(m) }.join ","}, and #{a[-1].send(m)}"
  end
end

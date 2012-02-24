module TalksHelper

  def render_speaker(talk)
    if talk.speaker.empty?
      @out = "No speaker yet"
    else
      @out = talk.speaker
    end
    unless talk.speaker_affiliation.empty?
      @out += " - #{talk.speaker_affiliation}"
    end
    unless talk.speaker_url.empty?
      @out = link_to @out, talk.speaker_url
    end
    return @out.html_safe
  end

  def render_venue(talk)
    return "<i>No venue yet</i>".html_safe unless (talk.room || talk.building)

    if talk.building && (not talk.building.name.empty?)
      @out = "#{talk.room} #{talk.building.name} (#{talk.building.abbrv})"
    elsif talk.building
      @out = "#{talk.room} #{talk.building.abbrv}"
    else
      @out = talk.room
    end
    if talk.building && talk.building.url && (not talk.building.url.empty?)
      @out = link_to @out, talk.building.url
    end
    return @out.html_safe
  end

  def render_time(talk)
    if talk.start_time && talk.end_time
      @out = (talk.start_time.strftime "%A, %B %-d, %Y, ") + (talk.start_time.strftime("%l:%M").lstrip)
      if ((talk.start_time.hour < 12) == (talk.end_time.hour < 12)) # both am or both pm
        @out += "-" + (talk.end_time.strftime("%l:%M %P").lstrip)
      else
        @out += (talk.start_time.strftime " %P-") + (talk.end_time.strftime("%l:%M %P").lstrip)
      end
    else
      @out = "(Time not yet available)"
    end
    return @out.html_safe
  end

  def render_lists(talk)
    return (talk.lists
              .sort { |a,b| a.name <=> b.name }
              .map { |l| link_to l.name, list_url(l) }
              .join "&nbsp;&sdot;&nbsp;").html_safe
  end

  def render_array_of_lists(lists)
    return (lists
              .sort { |a,b| a.name <=> b.name }
              .map { |l| link_to l.name, list_url(l) }
              .join "&nbsp;&sdot;&nbsp;").html_safe
  end

  # returns hash map h such that
  # h[:now] - time when everything was computed
  # h[:past] - old talks
  # h[:today] - today's talks
  # h[:later_this_week][wday] - talks on wday of this week (wdays start at 0)
  # h[:next_week][wday] - talks of wday of next week
  # h[:beyond] - talks after next week
  def organize_talks(talks)
    h = Hash.new
    h[:past] = []
    h[:today] = []
    h[:later_this_week] = []
    (0..6).each { |wday| h[:later_this_week][wday] = [] }
    h[:next_week] = []
    (0..6).each { |wday| h[:next_week][wday] = [] }
    h[:beyond] = []

    h[:now] = Time.now

    the_past = (h[:now] - 1.day).end_of_day
    today = h[:now].beginning_of_day..h[:now].end_of_day
    later_this_week = (h[:now].beginning_of_day + 1.day)..((h[:now] + 1.day).end_of_week - 1.day)
    next_week = ((h[:now] + 1.day).beginning_of_week + 6.day)..((h[:now] + 1.day).end_of_week + 6.day)
    beyond = (h[:now] + 1.day).beginning_of_week + 13.day

    talks.each do |t|
      if t.start_time <= the_past
        h[:past] << t
      elsif today.cover? t.start_time
        h[:today] << t
      elsif later_this_week.cover? t.start_time
        h[:later_this_week][t.start_time.wday] << t
      elsif next_week.cover? t.start_time
        h[:next_week][t.start_time.wday] << t
      else
        h[:beyond] << t
      end
    end

    h[:past].sort! { |a,b| a.start_time <=> b.start_time }
    h[:today].sort! { |a,b| a.start_time <=> b.start_time }
    h[:later_this_week].each { |ts| ts.sort! { |a,b| a.start_time <=> b.start_time } }
    h[:next_week].each { |ts| ts.sort! { |a,b| a.start_time <=> b.start_time } }
    h[:beyond].sort! { |a,b| a.start_time <=> b.start_time }

    return h
  end

  def format_day(time)
    time.strftime("%A, %B %-d, %Y")
  end
  
end

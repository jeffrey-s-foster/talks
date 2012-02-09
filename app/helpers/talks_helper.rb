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
  
end

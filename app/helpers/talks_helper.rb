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
    return @out
  end

  def render_venue(talk)
    return "<i>No venue yet</i>" unless (talk.room || talk.building)

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
    return @out
  end

end

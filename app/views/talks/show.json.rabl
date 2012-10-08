object @talk
node :title do |t| t.extended_title end
attribute :speaker
attribute :speaker_affiliation
attribute :speaker_url
attribute :start_time
attribute :end_time
attribute :abstract
attribute :bio
attribute :room
node :building do |t|
  if t.building
    t.building.name
  else
    ""
  end
end
node :building_abbrv do |t|
  if t.building
    t.building.abbrv
  else
    ""
  end
end
node :building_url do |t|
  if t.building && t.building.url
    t.building.url
  else
    ""
  end
end
# sanitization?

atom_feed :language => 'en-US' do |feed|
  feed.title @title
  feed.updated Time.now

  @talks.each do |t|
    feed.entry(t) do |entry|
      entry.url talk_url(t)
      entry.title t.title
      entry.author t.speaker
      content = ""
      unless t.abstract.empty?
        content = t.abstract
      else  
        content = "(No abstract yet)"
      end
      unless t.bio.empty?
        content << "Bio: " << t.bio
      end
      entry.content content, :type => 'html'
      # the strftime is needed to work with Google Reader.
#      entry.updated(t.updated_at.strftime("%Y-%m-%dT%H:%M:%SZ")) 
#      entry.author item.user.handle
    end
  end
end

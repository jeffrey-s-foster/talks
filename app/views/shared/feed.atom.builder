atom_feed :language => 'en-US' do |feed|
  feed.title @title
  feed.updated Time.now

  @talks.each do |t|
    feed.entry(t) do |entry|
      entry.url talk_url(t)
      entry.title t.title
      if t.abstract
        entry.content t.abstract, :type => 'html'
      else  
        entry.content "(No abstract yet)", :type => 'text'
      end
      # the strftime is needed to work with Google Reader.
#      entry.updated(t.updated_at.strftime("%Y-%m-%dT%H:%M:%SZ")) 
#      entry.author item.user.handle
    end
  end
end

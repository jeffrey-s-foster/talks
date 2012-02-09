atom_feed :language => 'en-US' do |feed|
  feed.title @title
  feed.updated Time.now

  @talks.each do |t|
    feed.entry(t) do |entry|
      entry.url talk_url(t)
      entry.title t.title
#      unless t.speaker_affiliation.empty?
#        entry.author "#{t.speaker} - #{t.speaker_affiliation}"
#      else
#	entry.author t.speaker
#      end
      content = render_speaker(t) + "<br>".html_safe
      content += render_venue(t) + "<br>".html_safe
      content += render_time(t) + "<br><br>".html_safe
      unless t.abstract.empty?
        content += "<b>Abstract:</b> ".html_safe + t.abstract.html_safe
      else  
        content = "(No abstract yet)"
      end
      unless t.bio.empty?
        content += "<br><b>Bio:</b> ".html_safe + t.bio.html_safe
      end
      entry.content content, :type => 'html'
      # the strftime is needed to work with Google Reader.
#      entry.updated(t.updated_at.strftime("%Y-%m-%dT%H:%M:%SZ")) 
#      entry.author item.user.handle
    end
  end
end

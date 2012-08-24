atom_feed :language => 'en-US' do |feed|
  feed.title @title
  feed.updated Time.now

  @talks.each do |t|
    feed.entry(t) do |entry|
      entry.url talk_url(t)
      entry.title t.extended_title
      content = render_speaker(t) + "<br>".sanitize
      content += render_venue(t) + "<br>".sanitize
      content += render_time(t) + "<br><br>".sanitize
      unless t.abstract.empty?
        content += "<b>Abstract:</b> ".sanitize + t.abstract.sanitize
      else  
        content = "(No abstract yet)"
      end
      unless t.bio.empty?
        content += "<br><b>Bio:</b> ".sanitize + t.bio.sanitize
      end
      unless t.lists.empty?
        content += "<br>This talk is part of the following lists: ".sanitize + render_lists(t)
      end
      content += "<br>".sanitize
      entry.content content, :type => 'html'
      # the strftime is needed to work with Google Reader.
#      entry.updated(t.updated_at.strftime("%Y-%m-%dT%H:%M:%SZ")) 
#      entry.author item.user.handle
    end
  end
end

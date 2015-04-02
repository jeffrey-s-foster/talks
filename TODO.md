* Fix strings, methods in talk.rb/enum kind

== TODO list

* LDAP support for UMCP Directory IDs.  Using these is one less
  barrier to adoption, since people already have a directory ID.

  Also see:

  * {UMD CAS FAQ}[http://login.umd.edu/developer.html]
  * {devise_cas_authenticatable}[https://github.com/nbudin/devise_cas_authenticatable]

* Support for tags.  The idea would be able to create a "smart" list
  based on tags indicated by the user.  For example, all talks that
  have tag Foo but not tag Bar.  This list is automatically updated
  whenever new talks are put in the system.

* More efficient queries in functions added to models/list.rb,
  models/user.rb, and models/talk.rb

* rss/ical feeds - only include past n talks, e.g., past 1 year

* restrict "all" talks to some time period (1-2 years?)

* watch implementation
  * Send email (only) to new list subscribers if talk is cross-posted to a new list
  * Send email on cancellation
  * Indicate in email update whether you are subscribed to the talk or not

* disable (really) users from cancelling accounts? or enable it fully

* what happens to posted talks when a user is deleted?

* icon for poster?

* what happens if talk cross-posted by another user, then orig user
  tries to edit the talk?

* Also, when I changed my password, it behaved oddly.  It immediately
  said I was not authorized to access the page I was on, because, I
  think, it kicked me off of the site.  I had to log in again, and now
  things seem to be OK.

* Have an option for people to subscribe not only to talks but also to
  Deptl scheduling (meetings, picnics, and maybe even spring break
  dates, end of classes, last day to submit grades, etc).

* link to it on the dept home page

* It'd be nice to have a way to get a list of all talks in the coming
  week e-mailed to me on Sunday (regardless of my subscriptions). This
  way I can discover new talks/lists that would be interesting without
  remembering to check the talks page each week.

* The "Watch" button changes to "Unsubscribe" when you click on it,
  not "Unwatch".

* Support email from list organizer to all subscribers.

* One anomaly I've noticed in the interface for entering talk data is
  the deletion of carriage returns in abstracts / bios.  One the one
  hand, this is useful when e.g. one is cutting and pasting from an
  e-mail message that includes (emacs-inserted) hard carriage returns
  at the ends of lines.  On the other, it also removes paragraph
  boundaries, leading to awkward-sounding phrasing.  How about this as
  an alternative: one or fewer CRs -> 0 CR.  >= 2 CRs -> 2 CRs?

* Note when can post a talk to a list?

* mobile web site

* no email on talk cancellation?

* If at some point you feel inspired to create something similar (or
  even have the very same facility extended) for deptl events more
  generally (meetings, picnics, etc) that would be even better.

* registration email should come from talk organizer, rather than talks@cs.

--

* comma after room number

* Room/building flip

* add licensing

* When receiving an email announcement for a talk, it would be nice to
  also see *why* one is getting the announcement (e.g., what group the
  talk is associated with). Otherwise it can be difficult, for
  example, to distinguish a department-wide speaker (e.g., faculty
  candidate) from someone speaking in the privacy seminar.

* Clean up this week emails to organize by day of the week

* Better error message when bad email address is put into registration information.

* Double-check logic for owner of list being able to edit talk:

Sent mail to  (15ms)
Completed 500 Internal Server Error in 36ms

Net::SMTPSyntaxError (501 5.1.3 Bad recipient address syntax):
  app/controllers/talks_controller.rb:188:in `external_register'

* Fix config/initializers/secret_token.rb to not appear in github at
  all, in case it misleads someone.

* Fix redirect to always go to the right page (e.g., registration).

* Some way to privately mark hiring talks (or similar) so that mark is
  only visible locally.

* Ability to archive old lists

* Email reminders - send one reminder per talk, rather than a digest

* Plain text email option

* Fixed delayed jobs stuff so it actually works

* Feature to mark certain rooms in buildings as special and then use
their names, like

 When an event is scheduled for CSIC 1115, it should be listed as Horvitz Lecture Hall (CSIC 1115).
 When an event is scheduled for CSIC 3117, it should be listed as Dante Consulting Classroom (CSIC 3117)
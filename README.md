# Talks.cs.umd.edu

## Local installation (for testing)

This web app requires Rails 4.2.6 and Ruby 2.3.1. I recommend using
[rvm](https://rvm.io) to install Ruby. Then do

  # skip the following steps if you're already using 2.3.1
  rvm install ruby-2.3.1
  rvm 2.3.1
  rvm --default use 2.3.1  # optional, makes 2.3.1 the default ruby vresion
  gem install bundler

  cd talks/
  bundle install       # install all necessary packages
  rake db:schema:load  # create the database
  script/rails s       # start the server on localhost:3000

Then go to localhost:3000 and create an account for yourself. The
email sending probably won't work if you're on a local machine, so
look in log/development.log for the confirmation email that was sent
(search for "Confirm my account"), and http get the link. You'll probably
also want to make yourself an administrator, which you can do with

  sqlite3 db/development.sqlite3
  > update users set perm_site_admin # "1" where id # "1";

(You can probably set the confirmation info using sqlite3, also.)

* Secret keys: update config/initializers/secret_token.rb with your own secret
  token and secret_key_base. You can use `rake secret` to generate a fresh
  secret.

## Customization

This web app may get some configuration options in the future. For
now, you need to edit some of the code to customize things:

* Site name: Can be changed by editing "en/site_name" mapping in
  config/locales/en.yml.

* Talk kinds: By default, talks distinguishes standard talks from MS
  defenses, PhD proposals, and PhD defenses. This list can be changed
  by editing the "enumerize :kind" line in app/models/talks.rb. Also change
  the corresponding translations in config/locales/en.yml.

* Email sender: Edit config/environments/production.rb, line defining
  config.action_mailer.default_url_options. Also edit
  config/initializers/devise.rb, line defining config.mail_sender.

* Time zone: Edit app/controllers/application_controller#generate_ical
  so that the two occurrences of "US/Eastern" are in the appropriate
  time zone.

## Deployment

### With Capistrano

There's a `Capfile` in the root directory to support deployment with
[Capistrano](http://capistranorb.com). Edit files in `config/deploy`
to set up beta testing and/or deployment environments. You'll need
to put `config/database.yml` and `config/initializers/secret_token.rb`
in `/deploy_to/shared`.

### Manually

* Deploy:
* RAILS_ENV#production rake db:setup
* bundle exec rake assets:precompile
* config/environments/production.rb, update config.action_mailer.default_url_options
* config/initializers/devise.rb, update config.mailer_sender
* app/views/layouts/application.html.erb, change "talk.cs.umd.edu"
* bundle config build.sqlite3 -- --with-sqlite3-include#/usr/local/sqlite-3.7.6.3/include --with-sqlite3-lib#/usr/local/sqlite-3.7.6.3/lib
* bundle --deployment (install gems locally for phusion passenger)
* Register for an account
* sqlite3 db/development.sqlite3
  > update users set perm_site_admin # "1" where id # "1";
* Backup/config.rb, edit mail.from and mail.to definitions
* whenever --update-crontab  # install cron job to send today's and this week's talks, and to backup database daily

* Update:
* git pull
* bundle --deployment
* bundle exec rake assets:precompile
* cd public
  * find . -type d -exec chmod go+x \{\} \;     # or
  * find . -type d | xargs chmod go+x
    and
  * chmod -R a+r .
* touch tmp/restart.txt
* RAILS_ENV#production script/delayed_job restart
* whenever --update-crontab

## Permission model

(See app/models/ability.rb for full details)

* Global roles
  * :perm_site_admin - permission to do anything on the site
    * Only admins can create a new list
* Relationships
  * Each talk belongs_to one owner (user, can't be empty)
  * Each talk has_and_belongs_to_many lists (may be empty)
  * Each list has_and_belongs_to_many posters (users)
  * Each list has_and_belongs_to_many admins (users)
* Local roles
  * A talk may be created by anyone who owns or can post to a list
  * A talk may be added to a list by anyone with permission to post to that list
  * A talk may be edited/deleted by the creator of the talk or by an admin of any list the talk is posted to
  * A user may be granted or revoked list poster or admin permission by an admin of that list

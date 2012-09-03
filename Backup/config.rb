# encoding: utf-8

##
# Backup Generated: talks_backup
# Once configured, you can run the backup with the following command:
#
# $ backup perform -t talks_backup [-c <path_to_configuration_file>]
#
database_yml = File.expand_path('../../config/database.yml', __FILE__)
RAILS_ENV = "production"

require "yaml"
config = YAML.load_file(database_yml)

Backup::Model.new(:talks_backup, 'Backup talks db') do
  ##
  # Split [Splitter]
  #
  # Split the backup file in to chunks of 250 megabytes
  # if the backup file size exceeds 250 megabytes
  #
  split_into_chunks_of 250

  ##
  # MySQL [Database]
  #
  database MySQL do |db|
    # To dump all databases, set `db.name = :all` (or leave blank)
    db.name               = config[RAILS_ENV]["database"]
    db.username           = config[RAILS_ENV]["username"]
    db.password           = config[RAILS_ENV]["password"]
    db.host               = config[RAILS_ENV]["host"]
    db.port               = config[RAILS_ENV]["port"]
    db.socket             = "/tmp/mysql.sock"
    db.skip_tables        = []
#    db.additional_options = ["--quick", "--single-transaction"]
    # Optional: Use to set the location of this utility
    #   if it cannot be found by name in your $PATH
    # db.mysqldump_utility = "/opt/local/bin/mysqldump"
  end

  ##
  # Local (Copy) [Storage]
  #
  store_with Local do |local|
    local.path       = File.expand_path("../../backups/", __FILE__)
    local.keep       = 7
  end

  ##
  # Gzip [Compressor]
  #
  compress_with Gzip

  ##
  # Mail [Notifier]
  #
  # The default delivery method for Mail Notifiers is 'SMTP'.
  # See the Wiki for other delivery options.
  # https://github.com/meskyanichi/backup/wiki/Notifiers
  #
  notify_by Mail do |mail|
    mail.on_success           = true
    mail.on_warning           = true
    mail.on_failure           = true

    mail.delivery_method      = :sendmail
    mail.from                 = "talks@cs.umd.edu"
    mail.to                   = "jfoster@cs.umd.edu"
  end

end

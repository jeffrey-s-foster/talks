class Subscription < ActiveRecord::Base
  belongs_to :subscribable, :polymorphic => true
  belongs_to :user

  symbolize :kind, :in => [:kind_watcher, :kind_subscriber], :scopes => true, :methods => true
end

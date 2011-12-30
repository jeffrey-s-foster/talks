class Subscription < ActiveRecord::Base
  belongs_to :subscribable, :polymorphic => true
  belongs_to :user

  symbolize :kind, :in => [:kind_watch, :kind_full], :scopes => true, :methods => true
end

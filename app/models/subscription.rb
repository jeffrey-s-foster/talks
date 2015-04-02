class Subscription < ActiveRecord::Base
  belongs_to :subscribable, :polymorphic => true
  belongs_to :user

  enumerize :kind, in: [:kind_watcher, :kind_subscriber]
end

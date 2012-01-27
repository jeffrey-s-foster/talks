class Ability
  include CanCan::Ability

  def initialize(user)
    can :edit, user if user
    user ||= User.new # guest user (not logged in)

    if user.perm_create_talk || user.perm_site_admin
      can :create, Talk
    end

    can :edit, Talk, :owner_id => user.id

    can :edit, List do |l|
      l.owner? user
    end

    can :add_talk, List do |l|
      (l.owner? user) || (l.poster? user)
    end

    if user.perm_site_admin
      can :site_admin, :all
      can :edit, :all
      can :edit_name, :all
      can :edit_owner, :all
      can :create, :all
      can :destroy, :all
      can :add_talk, :all
      can :edit_buildings, :all
    end

    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end

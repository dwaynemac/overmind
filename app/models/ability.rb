class Ability
  include CanCan::Ability

  def initialize(user)
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

    user ||= User.new

    cannot :manage, :all

    case user.role
      when 'admin'
        can :manage, :all
        can :sync, School
      when 'council'
        can :read, Federation
        can :read, School
        can :read, MonthlyStat
      else
        can :read_only_one, Federation
        can :read, Federation, id: user.federation_id
        can :read, School, federation_id: user.federation_id
        can :read, MonthlyStat, school: { federation_id: user.federation_id }
    end
  end
end

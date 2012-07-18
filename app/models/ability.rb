class Ability
  include CanCan::Ability

  def initialize(user)
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

    # scope to federation
    [School].each do |klass|
      can :manage, klass, :federation_id => user.federation_id
    end

    can [:read,:update], Federation, :id => user.federation_id
    cannot [:create,:destroy], Federation
    can :manage, Observation, :observed => { :federation_id => user.federation_id }
    can :manage, GeneralEvaluation, :evaluated => { :federation_id => user.federation_id }
    can [:read,:update], User, :id => user.id

    if user.auditor?
      can :read, School
      cannot :read, Person
      cannot :manage, Observation
      cannot :manage, GeneralEvaluation
      can :read, Federation
    end

    if user.admin?
      can :manage, :all
      can :cross_federation, :all
    end
  end
end

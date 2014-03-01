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
    cannot :sync, School
    cannot :see_global, MonthlyStat
    cannot :read, Ranking

    if user.padma_enabled?
      # Users have these permitions on top of those specific to their role.
      can [:sync,:sync_year,:read,:see_detail], School, account_name: user.enabled_accounts.map(&:name)
      accessible_schools = School.accessible_by(self)
      if accessible_schools.count == 1
        can :read_only_one, School
      end
      accessible_federations = accessible_schools.map(&:federation_id)
      can :read, Federation, id: accessible_federations
      if accessible_federations.count == 1
        can :read_only_one, Federation
      end
      can :manage, MonthlyStat, school: {account_name: user.enabled_accounts.map(&:name) }
      cannot :see_global, MonthlyStat # previous can :manage grants :see_global
      can :read, Ranking
    end

    case user.role
      when 'admin'
        can :manage, :all
        can :read, Ranking
        can :sync, School
        can :create, SyncRequest
        can :see_global, MonthlyStat
      when 'data_entry'
        # user.user explained: first user is local user, second user ir padma_user
        accessible_account_names = user.user.padma_accounts.map(&:name)
        can [:read], School, account_name: accessible_account_names
        can :read, MonthlyStat, school: { account_name: accessible_account_names }
        can [:create, :update, :destroy], MonthlyStat, service: '', school: {account_name: accessible_account_names }
      when 'council'
        can :read, Federation
        can :read, School
        can :read, MonthlyStat
        can :see_global, MonthlyStat
        can :read, Ranking
      when 'president'
        can :read_only_one, Federation
        can :read, Federation, id: user.federation_id
        can :read, School, federation_id: user.federation_id
        can :read, MonthlyStat, school: { federation_id: user.federation_id }
        can :read, Ranking
    end
  end
end

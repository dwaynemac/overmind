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

    @user = user || User.new

    block_all_permitions
    user_with_enabled_padma_accounts_permitions
    role_specific_permitions

  end

  def alpha?
    @user.current_account.try(:tester_level) == 'alpha'
  end

  def beta?
    tl = @user.current_account.try(:tester_level)
    tl == 'alpha' || tl == 'beta'
  end

  ##
  # Warning! This uses accessible_by. Shouldn't be used in Ability intialization.
  #
  def schools
    @schools ||= School.accessible_by(self)
  end

  def federations
    @federations ||= Federation.accessible_by(self)
  end

  private

  def block_all_permitions
    cannot :manage, :all
    cannot :sync, School
    cannot :see_global, MonthlyStat
    cannot :read, Ranking
    cannot :read, TeacherRanking
    cannot :read, :reports
  end

  def user_with_enabled_padma_accounts_permitions
    if @user.padma_enabled?
 
      self.merge GeneralAbility.new(@user)

      can [:sync,:sync_year,:read,:see_detail], School, account_name: enabled_account_names
      # can read teachers of my enabled accounts
      can :read, Teacher, id: School.where(account_name: enabled_account_names).map{|s| s.teachers.map(&:id) }.flatten

      can [:create,:update], SyncRequest
      can :read, Federation, id: user_federation_ids
      can :manage, MonthlyStat, school: {account_name: enabled_account_names }
      can :read, Ranking
      can :read, TeacherRanking
      can :read, :reports
    end
  end

  def role_specific_permitions
    case @user.role
      when 'admin'
        can [:read,:history], Ranking
        can :read, TeacherRanking
        can :sync, School
        can [:create,:update], SyncRequest
        can :see_global, MonthlyStat
        can :manage, :all
      when 'data_entry'
        can [:read], School, account_name: linked_account_names
        can :read, MonthlyStat, school: { account_name: linked_account_names }
        can [:create, :update, :destroy], MonthlyStat, service: '', school: {account_name: linked_account_names }
      when 'council'
        can :read, Federation
        can :detail, Federation
        can :read, School
        can :read, MonthlyStat
        can :see_global, MonthlyStat
        can [:read,:history], Ranking
        can :read, TeacherRanking
        can [:create, :update, :destroy], MonthlyStat, service: '', school: {account_name: linked_account_names }
      when 'president'
        can :read_only_one, Federation
        can :read, Federation, id: @user.federation_id
        can :detail, Federation
        can :read, School, federation_id: @user.federation_id
        can :read, MonthlyStat, school: { federation_id: @user.federation_id }
        can [:read,:history], Ranking
        can :read, TeacherRanking
    end
  end

  # account's that user has access to in padma-accounts and are enabled
  def enabled_account_names
    @enabled_account_names ||= @user.enabled_accounts.map(&:name)
  end

  # account's that user has access to in padma-accounts, enabled or not.
  def linked_account_names
    # user.user explained: first user is local user, second user ir padma_user
    @linked_account_names ||= @user.user.padma_accounts.map(&:name)
  end

  # schools corresponding to enabled accounts in padma
  def user_schools
    @user_schools ||= School.where(account_name: enabled_account_names)
  end

  def user_federation_ids
    @user_federation_ids ||= user_schools.map(&:federation_id)
  end
end

class SchoolsSynchronizer
  
  def self.start
    # accounts-ws doesn't actually paginate so we have
    # all accounts here.
    accounts = PadmaAccount.paginate
    if accounts.nil?
      Rails.logger.warn "couldn't run SchoolsSynchronizer, connection to accounts-ws failed."
      return
    end

    accounts.each do |account|

      school = School.find_by_account_name(account.name)
      tried_to_find_by_nucleo_id = false
      if school.nil?
        school = School.find_by_nucleo_id(account.nucleo_id)
        tried_to_find_by_nucleo_id = true
      end

      if school.nil?
        School.create name: get_full_name(account),
                      nucleo_id: account.nucleo_id,
                      account_name: account.name,
                      federation_id: get_federation_id(account), 
                      migrated_kshema_to_padma_at: account.migrated_to_padma_on
      else
        if tried_to_find_by_nucleo_id
          if school.account_name.blank?
            school.update_attribute(:account_name, account.name)
          else
            Rails.logger.warn "School(##{school.name}-#{school.id}) has account_name for one account but nucleo_id for another"
          end
        end
        school.update_attributes(name: get_full_name(account),
                                 federation_id: get_federation_id(account)) if school.name.blank?
      end
    end
    
    School.all.each{|s| s.nucleo_enabled? } # cache nucleo_enabled on attribute: cached_nucleo_enabledh
  end

  private
  
  def self.get_federation_id (account)
    federation = Federation.find_by_nucleo_id(account.federation_nucleo_id)
    federation_id = federation.nil? ? nil : federation.id
  end

  def self.get_full_name (account)
    account.full_name.blank? ? account.name : account.full_name
  end
end

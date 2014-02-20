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
          school.update_attribute(:account_name, account.name)
        end
        school.update_attribute(:name, get_full_name(account))
      end
    end
  end

  private
  
  def self.get_federation_id (account)
    federation = Federation.find_by_nucleo_id(account.federation_nucleo_id)
    federation_id = federation.nil? ? nil : federation.id
  end

  def self.get_full_name (account)
    account.full_name.nil? ? account.name : account.full_name
  end
end

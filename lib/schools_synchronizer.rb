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
      if school.nil?
        School.create name: get_full_name(account),
                      account_name: account.name,
                      federation_id: get_federation_id(account), 
                      migrated_kshema_to_padma_at: account.migrated_to_padma_on
      else
        school.update_attributes(name: get_full_name(account),
                                 federation_id: get_federation_id(account)) if school.name.blank?
      end
    end
    
    School.all.each{|s| s.padma_enabled? } # cache padma_enabled on attribute: cached_padma_enabled
  end

  private
  
  def self.get_federation_id (account)
    return nil if account.federation_nucleo_id.nil?
    federation = Federation.find_by_nucleo_id(account.federation_nucleo_id)
    federation.nil? ? nil : federation.id
  end

  def self.get_full_name (account)
    account.full_name.blank? ? account.name : account.full_name
  end
end

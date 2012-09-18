# this module assumes base class has aa account_name attribute.
module BelongsToAccount

  def self.included(base)
    base.send(:validate, :padma_account_setted_correctly)
  end

  attr_accessor :padma_account
  ##
  # Returns associated account.
  #
  # account is stored in instance variable padma_account. This allows for it to be setted in a Mass-Load.
  #
  # @param options [Hash]
  # @option options [TrueClass] force_service_call - forces call to accounts-ws
  # @return [PadmaAccount]
  def account(options={})
    if self.padma_account.nil? || options[:force_service_call]
      self.padma_account = PadmaAccount.find(account_name)
    end
    ret = padma_account
    ret
  end

  private

  # If padma_account is setted with a PadmaAccount that doesn't match
  # account_id an exception will be raised
  # @raises 'This is the wrong account!'
  # @raises 'This is not a account!'
  def padma_account_setted_correctly
    return if self.padma_account.nil?
    unless padma_account.is_a?(PadmaAccount)
      raise 'This is not a account!'
    end
    if padma_account.name != self.account_name
      if self.account_name.nil?
        # if they differ because account_id is nil we set it here
        self.account_name = self.padma_account.name
      else
        raise 'This is the wrong account!'
      end
    end
  end
end
# Client for Nucleo Api
class RemoteSchool < LogicalModel

  self.hydra = HYDRA
  self.use_ssl = (Rails.env=="production")

  self.use_api_key = true
  self.api_key_name = 'api_key'
  self.api_key = (Rails.env=="production")? 'swasthya' : 'secured'

  self.host  = NUCLEO_HOST
  self.resource_path = "/schools"

  self.attribute_keys = [
      :id_unidade,
      :uni_federacao,
      :uni_nome,
      :uni_status
  ]

  alias_attribute :name, :uni_nome
  alias_attribute :id, :id_unidade
  alias_attribute :federation_id, :uni_federacao

  # belongs_to federation
  def federation
    RemoteFederation.find(self.uni_federacao)
  end

end
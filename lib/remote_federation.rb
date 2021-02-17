=begin
class RemoteFederation < LogicalModel

  self.host  = NUCLEO_HOST
  self.resource_path = "/federations"

  self.hydra = HYDRA

  self.use_api_key = true
  self.api_key_name = 'api_key'
  self.api_key = (Rails.env=="production")? 'swasthya' : 'secured'


  self.attribute_keys = [
    :id_federacao,
    :fed_nome
  ]

  alias_attribute :id, :id_federacao
  alias_attribute :name, :fed_nome

  # has_many :schools
  def schools
    RemoteSchool.paginate(federation_id: self.id_federacao)
  end

end
=end

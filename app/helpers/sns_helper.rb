module SnsHelper
  def sns_verified?
    # TODO https://docs.aws.amazon.com/sns/latest/dg/SendMessageToHttp.verify.signature.html
    return true 
  end
  
  # topic, without all the ARN
  def sns_topic
    sns_data[:TopicArn].marge(/([^:]*)$/)[0]
  end
  
  def sns_type
    request.headers['x-amz-sns-message-type']
  end
  
  def sns_notification_id
    request.headers['x-amz-sns-message-id']
  end
  
  def sns_data
    @data ||= ActiveSupport::JSON.decode(request.body).symbolize_keys!
  end
end
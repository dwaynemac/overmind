class MessageDoorController < ApplicationController
  include SnsHelper

  skip_before_filter :mock_login
  skip_before_filter :authenticate_user!
  skip_before_filter :pre_check_access
  skip_before_filter :set_locale

  before_filter :decode_data, only: [:catch]

  def sns
    case sns_type
    when 'SubscriptionConfirmation'
      # confirm subscription to Topic
      render json: Typhoeus.get(sns_data[:SubscribeURL]).body, status: 200
    when 'Notification'
      if sns_verified?
        unless sns_duplicate_submission?
        
          @key_name = sns_topic
          @data = sns_message
          set_ref_dates(sns_topic)
          load_school
          
          if @data.present? && @school.present? && !@ref_dates.empty?
            queue_sync_requests
            
            sns_set_as_received!
            render json: "received", status: 200
          else
            render json: "data insuficient", status: 400
          end
        else
          render json: 'duplicate', status: 200
        end
      else
        render json: 'unverified', status: 403
      end
    else
      render json: 'WTF', status: 400
    end
  end

  ##
  #
  # Valid Key Names: subcription_change, trial_lesson, birthday 
  #
  # data MUST include :account_name key EXCEPT for Global Key Names.
  #
  # @argument key_name [String]
  # @argument data [String] JSON encoded
  # @argument secret_key [String]
  def catch
    if valid_secret_key?
      @key_name = params[:key_name]
      set_ref_dates(params[:key_name])
      load_school
      if @data.present? && @school.present? && !@ref_dates.empty?
        queue_sync_requests
        render json: "received", status: 200
      else
        render json: "data insuficient", status: 400
      end
    else
      Rails.logger.info "expected #{ENV['messaging_secret']} but got #{params['secret_key']}"
      render json: "wrong secret_key", status: 401
    end
  end

  private
  
  def queue_sync_requests
    @ref_dates.each do |ref_date|
      SyncRequest.create(school_id: @school.id,
                         year: ref_date.year,
                         month: ref_date.month,
                         filter_by_event: event_filter_name(@key_name),
                         priority: calculate_priority(ref_date))
    end
  end

  def valid_secret_key?
    (params['secret_key'] == ENV['messaging_secret'])
  end

  def decode_data
    @data = ActiveSupport::JSON.decode(params[:data]).symbolize_keys!
  end

  def set_ref_dates(key_name)
    return if @data.nil?
    @ref_dates = []

    case key_name
    when 'subscription_change', 'destroyed_subscription_change'
      @ref_dates << @data[:changed_at].to_date if @data[:changed_at]
    when 'updated_subscription_change'
      @ref_dates << @data[:changed_at].to_date if @data[:changed_at]
      @ref_dates << @data[:changed_at_was].to_date if @data[:changed_at_was]
    when 'communication', 'destroyed_communication'
      @ref_dates << @data[:communicated_at].to_date if @data[:communicated_at]
    when 'updated_communication'
      @ref_dates << @data[:communicated_at].to_date if @data[:communicated_at]
      @ref_dates << @data[:communicated_at_was].to_date if @data[:communicated_at_was]
    end
  end

  def event_filter_name(key_name)
    efn = ""

    case key_name
    when /communication/
      efn << 'communication'
      efn << ":#{@data[:media]}" if @data[:media]
      efn << ":#{@data[:media_was]}" if @data[:media_was]
    end

    efn
  end

  def load_school
    return if @data.nil?
    
    account_name = @data[:account_name]
    if account_name
      @school = School.find_by_account_name(account_name)
    end
  end

  def calculate_priority(ref_date)
    (ref_date < Date.today.beginning_of_month)? 4 : 12
  end

end

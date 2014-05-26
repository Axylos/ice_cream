class Status < ActiveRecord::Base
  validates :body, :twitter_status_id, :twitter_user_id, presence: true 
  
  def self.fetch_by_twitter_user_id!(twitter_user_id)
    
    return_statuses = []
    statuses = TwitterSession.get("statuses/user_timeline", 
      { :user_id => twitter_user_id })
    
    JSON.parse(statuses).each do |status|
      params = self.parse_json(status)
      new_status = Status.new(params)
      return_statuses << new_status
    end
    old_status_ids = Status.pluck(:twitter_status_id)
    new_statuses = return_statuses.keep_if do |status| 
      !old_status_ids.include? status.twitter_status_id 
    end
    new_statuses.each(&:save!)
  end
  
  def self.parse_json(twitter_params)
    params = {}
    params[:body] = twitter_params["text"]
    params[:twitter_status_id] = twitter_params["id_str"]
    params[:twitter_user_id] = twitter_params["user"]["id_str"]
    
    params
  end
end
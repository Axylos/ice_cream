class Status < ActiveRecord::Base
  validates :body, :twitter_status_id, :twitter_user_id, presence: true 
  
  def self.fetch_by_twitter_user_id!(twitter_user_id)
    return_statuses = []
    statuses = TwitterSession.get("statuses/user_timeline", 
      { :user_id => twitter_user_id })
     
     return_statuses = prettify_json(statuses)

    old_status_ids = Status.pluck(:twitter_status_id)
    new_statuses = return_statuses.keep_if do |status| 
      !old_status_ids.include? status.twitter_status_id 
    end
    
    new_statuses.each(&:save!)
  end
  
  def self.prettify_json(statuses)
    JSON.parse(statuses).map do |status|
      params = self.parse_json(status)
      new_status = Status.new(params)
    end
  end
  
  def self.parse_json(twitter_params)
    params = {}
    params[:body] = twitter_params["text"]
    params[:twitter_status_id] = twitter_params["id_str"]
    params[:twitter_user_id] = twitter_params["user"]["id_str"]
    
    params
  end
  
  def self.post(body=nil)
    new_post = TwitterSession.prompt
    self.prettify_json(new_post)
  end
  
  def internet_connection?
    begin
      true if open("http://ww.google.com/")
    rescue
      false
    end
  end
  
  def load_by_twitter_user_id(id)
    Status.where(twitter_user_id)
  end
  
  def self.get_by_twitter_user_id(id)
    if internet_connection?
      self.fetch_by_twitter_user_id(id)
    else
      load_by_twitter_user_id(id)
    end
  end
end
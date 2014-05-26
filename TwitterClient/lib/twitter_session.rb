class TwitterSession
  
  TOKEN_FILE = "access_token.yaml"
  
  CONSUMER_KEY = "8TvFey4oXzqgACgNmYi2uTqF1"
  CONSUMER_SECRET = "nEIfhT1l74aZYEHP7q8MLe2Lqh6n2uFwkTAmZbd3hwxKHyl8ns"

  CONSUMER = OAuth::Consumer.new(
    CONSUMER_KEY, CONSUMER_SECRET, :site => "https://twitter.com")

  def self.get_access_token
  
    request_token = CONSUMER.get_request_token
    authorize_url = request_token.authorize_url

    Launchy.open(authorize_url)

    puts "Login, and type verification code"
    oauth_verifier = gets.chomp
    access_token = request_token.get_access_token(
      :oauth_verifier => oauth_verifier
    )
  
  end

  def self.get_token
    if File.exist?(TOKEN_FILE)
      File.open(TOKEN_FILE) { |f| YAML.load f }
    else
      access_token = get_access_token
      File.open(TOKEN_FILE, "w") { |f| YAML.dump(access_token, f) }
    
      access_token
    end
  end
  
  def self.path_to_url(path, query_path = nil)
   url = Addressable::URI.new(
      scheme: "https",
      host: "api.twitter.com",
      path: "1.1/#{path}.json",
      query_values: query_path,
    ).to_s
  end
  
  def self.get(path, query_values)
    
    token = get_token
    url = path_to_url(path, query_values)
    
    response = token
                  .get(url)
                  .body

    response
  end
  
  def self.post(path, req_params)
    
    token = get_token
    url = path_to_url(path, req_params)
    
    response = token
                  .post(url)
                  .body
    response
  end
end

  

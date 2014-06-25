require 'koala'

def facebook_posts(page_name)
  posts = @graph.get_connections(page_name, 'tagged')
  formatted_posts(posts[0..9])
end

def graph_client(token, secret)
  Koala::Facebook::API.new(token, secret)
end

def formatted_posts(posts)
  posts.each_with_object([]) do |post, arr|
    arr << {
      name: post['from']['name'],
      body: post['message'] == "" ? " -" : post['message'],
      avatar: post['picture'] || post['icon']
    }
  end
end

def page_info
  info = @graph.get_object('Gazelle.com?', {}, {:use_ssl => true})
  {
    likes: info['likes'],
    checkins: info['checkins'],
    talking_about: info['talking_about_count']
  }
end

page_name = 'YOUR_PAGE_NAME' #graph.facebook.com/YOUR_PAGE_NAME

SCHEDULER.every '1m', :first_in => 0 do
  @graph = Koala::Facebook::API.new('YOUR_OAUTH_TOKEN', 'YOUR_APP_SECRET')
  send_event('facebook_posts', {page_info: page_info(page_name), comments: facebook_posts(page_name)})
end

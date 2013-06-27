Factory.define(:"site/client", :class => Site::Client) do |c|
  c.sequence(:name) { |n| "Site client #{ n }" }
  c.url { 'https://test.com' }
  c.callback_url { 'https://test.com/callback' }
  c.author { Factory(:user).actor }
end

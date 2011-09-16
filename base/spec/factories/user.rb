Factory.define :user do |u|
  u.sequence(:name) { |n| "User #{ n }" }
  u.sequence(:email) { |n| "user#{ n }@example.com" }
  u.password "testing"
  u.password_confirmation "testing"
end

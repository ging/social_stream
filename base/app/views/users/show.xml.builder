xml.instruct!
xml.user do
  xml.uid @user.id
  xml.name @user.name
  xml.slug @user.slug
  if user_signed_in?
    xml.email @user.email
  end
  xml.userSince @user.created_at
  xml.birthday @user.profile.birthday
  xml.organization @user.profile.organization
  xml.city @user.profile.city
  xml.country @user.profile.country
  xml.website @user.profile.website
end

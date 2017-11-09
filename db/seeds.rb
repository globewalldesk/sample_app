User.create!(name: "Example User",
             email: "example@railstutorial.org",
             password:              "Password9",
             password_confirmation: "Password9",
             admin: true,
             activated: true,
             activated_at: Time.zone.now)

99.times do |n|
  name = Faker::LordOfTheRings.character.split[0] << " " << Faker::Name.last_name
  redo unless name.length < 50
  redo unless name.split.length == 2
  email = "example-#{n+1}@railstutorial.org"
  password = "Password9"
  User.create!(name: name,
               email: email,
               password: password,
               password_confirmation: "Password9",
               activated: true,
               activated_at: Time.zone.now)
  end

users = User.order(:created_at).take(6)
50.times do
  content = Faker::Lorem.sentence(5)
  users.each { |user| user.microposts.create!(content: content) }
end

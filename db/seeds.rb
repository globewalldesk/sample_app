User.create!(name: "Example User",
             email: "example@railstutorial.org",
             password:              "Password9",
             password_confirmation: "Password9",
             admin: true)

99.times do |n|
  name = Faker::LordOfTheRings.character.split[0] << " " << Faker::Name.last_name
  redo unless name.length < 50
  redo unless name.split.length == 2
  email = "example-#{n+1}@railstutorial.org"
  password = "Password9"
  User.create!(name: name,
               email: email,
               password: password,
               password_confirmation: "Password9")
end
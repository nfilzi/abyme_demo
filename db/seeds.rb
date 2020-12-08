puts "Cleaning up DB.."
Task.destroy_all
User.destroy_all

puts "Creating users.."

User.create!([
  { email: 'bearinmind@abyme-gem.com', username: 'bearinmind', password: 'secret' },
  { email: 'nfilzi@abyme-gem.com',     username: 'nfilzi',     password: 'secret' },
  { email: 'cveneziani@abyme-gem.com', username: 'cveneziani', password: 'secret' },
])

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
users = User.create([{name: "Gustavo"},{name: "Mariana"}])
accounts = Account.create([{amount: 1000.0, lock: false, user: users.first}, {amount: 200.0, lock: false, user: users.last}])
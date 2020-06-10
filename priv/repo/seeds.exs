# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Jungsoft.Repo.insert!(%Jungsoft.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

#alias Jungsoft.Exchages.{Fund, Token, User}
#
#Jungsoft.Repo.insert!(%Fund{
#  name: "fund 1",
#  description: "sem criatividade",
#  value: 10,
#  tokens: [
#    %Token{
#      current_owner: %User{
#        name: "jotaro",
#        email: "dio@hotmail.com",
#        password_hash: Argon2.add_hash("test")[:password_hash]
#      }
#    }
#  ]
#})

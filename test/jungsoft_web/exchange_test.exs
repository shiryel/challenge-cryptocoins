defmodule JungsoftWeb.Schema.ExchangeTest do
  use JungsoftWeb.ConnCase, async: true

  alias Jungsoft.Exchages

  describe "session" do
    @query """
    mutation ($email: String!, $password: String!) {
      login(email:$email, password:$password) {
        token
        user { name }
      }
    }
    """
    @user %{email: "dio@hotmail.com", password: "42", name: "jotaro"}

    test "creating an user session" do
      {:ok, user} = Exchages.create_user(@user)

      response =
        post(build_conn(), "/api", %{
          query: @query,
          variables: %{"email" => @user.email, "password" => @user.password}
        })

      assert %{
               "data" => %{
                 "login" => %{
                   "token" => token,
                   "user" => user_data
                 }
               }
             } = json_response(response, 200)

      assert %{"name" => user.name} == user_data

      assert {:ok, %{id: user.id}} ==
               JungsoftWeb.Authentication.verify(token)
    end
  end

  describe "fund" do
    @admin_user %{email: "admin@hotmail.com", password: "42", name: "jotaro", role: "admin"}

    @client_user %{email: "dio@hotmail.com", password: "42", name: "jotaro"}

    @login """
    mutation ($email: String!, $password: String!) {
      login(email:$email, password:$password) {
        token
        user { name }
      }
    }
    """

    @create_fund """
    mutation {
      me {
        createFund(name: "fund 10", value: 20, tokenAmount: 50) {
          description
          name
          value
        }
      }
    }
    """

    @invest """
    mutation {
      me {
        invest(fundName: "fund 10", tokenAmount: 1) 
      }
    }
    """

    @refund """
    mutation {
      me {
        refund(fundName: "fund 10", tokenAmount: 1) 
      }
    }
    """

    @update_fund """
    mutation {
      me {
        updateFund(fundName: "fund 10", value: 300) {
          description
          name
          value
        } 
      }
    }
    """

    @profit """
    {
      me {
        getUserProfit
      }
    }
    """

    test "login as admin and make operations" do
      {:ok, _user} = Exchages.create_user(@admin_user)

      #########
      # LOGIN #
      #########
      response =
        post(build_conn(), "/api", %{
          query: @login,
          variables: %{"email" => @admin_user.email, "password" => @admin_user.password}
        })

      assert %{
               "data" => %{
                 "login" => %{
                   "token" => token
                 }
               }
             } = json_response(response, 200)

      conn =
        build_conn()
        |> Plug.Conn.put_req_header("authorization", "Bearer #{token}")

      ###############
      # CREATE FUND #
      ###############

      response =
        post(conn, "/api", %{
          query: @create_fund
        })

      assert %{
               "data" => %{
                 "me" => %{
                   "createFund" => %{
                     "description" => "",
                     "name" => "fund 10",
                     "value" => "20"
                   }
                 }
               }
             } = json_response(response, 200)

      ##########
      # INVEST #
      ##########

      response =
        post(conn, "/api", %{
          query: @invest
        })

      assert %{
               "data" => %{
                 "me" => %{"invest" => "-20"}
               }
             } = json_response(response, 200)

      ##########
      # REFUND #
      ##########

      response =
        post(conn, "/api", %{
          query: @refund
        })

      assert %{
               "data" => %{
                 "me" => %{"refund" => "0"}
               }
             } = json_response(response, 200)

      ##########
      # PROFIT #
      ##########

      response =
        post(conn, "/api", %{
          query: @profit
        })

      assert %{
               "data" => %{
                 "me" => %{"getUserProfit" => "0"}
               }
             } = json_response(response, 200)

      ##########
      # UPDATE #
      ##########

      response =
        post(conn, "/api", %{
          query: @update_fund
        })

      assert %{
               "data" => %{
                 "me" => %{
                   "updateFund" => %{
                     "description" => "",
                     "name" => "fund 10",
                     "value" => "300"
                   }
                 }
               }
             } = json_response(response, 200)

      ##########
      # INVEST #
      ##########

      response =
        post(conn, "/api", %{
          query: @invest
        })

      assert %{
               "data" => %{
                 "me" => %{"invest" => "-300"}
               }
             } = json_response(response, 200)

      ##########
      # INVEST #
      ##########

      response =
        post(conn, "/api", %{
          query: @invest
        })

      assert %{
               "data" => %{
                 "me" => %{"invest" => "-600"}
               }
             } = json_response(response, 200)

      ##########
      # REFUND #
      ##########

      response =
        post(conn, "/api", %{
          query: @refund
        })

      assert %{
               "data" => %{
                 "me" => %{"refund" => "-300"}
               }
             } = json_response(response, 200)

      ###################
      # LOGIN AS CLIENT #
      ###################
      {:ok, _user} = Exchages.create_user(@client_user)

      response =
        post(build_conn(), "/api", %{
          query: @login,
          variables: %{"email" => @client_user.email, "password" => @client_user.password}
        })

      assert %{
               "data" => %{
                 "login" => %{
                   "token" => token
                 }
               }
             } = json_response(response, 200)

      conn =
        build_conn()
        |> Plug.Conn.put_req_header("authorization", "Bearer #{token}")

      ##########
      # UPDATE #
      ##########
      # MUST BE UNAUTHORIZED

      response =
        post(conn, "/api", %{
          query: @update_fund
        })

      assert %{
               "data" => %{"me" => %{"updateFund" => nil}},
               "errors" => [
                 %{
                   "locations" => [%{"column" => 5, "line" => 3}],
                   "message" => "invalid_or_unauthorized",
                   "path" => ["me", "updateFund"]
                 }
               ]
             } = json_response(response, 200)

      ##########
      # INVEST #
      ##########

      response =
        post(conn, "/api", %{
          query: @invest
        })

      assert %{
               "data" => %{
                 "me" => %{"invest" => "-300"}
               }
             } = json_response(response, 200)

      ##########
      # REFUND #
      ##########

      response =
        post(conn, "/api", %{
          query: @refund
        })

      assert %{
               "data" => %{
                 "me" => %{"refund" => "0"}
               }
             } = json_response(response, 200)

      ##########
      # PROFIT #
      ##########

      response =
        post(conn, "/api", %{
          query: @profit
        })

      assert %{
               "data" => %{
                 "me" => %{"getUserProfit" => "0"}
               }
             } = json_response(response, 200)

    end

    test "login as client cannot create funds" do
      {:ok, _user} = Exchages.create_user(@client_user)

      #########
      # LOGIN #
      #########
      response =
        post(build_conn(), "/api", %{
          query: @login,
          variables: %{"email" => @client_user.email, "password" => @client_user.password}
        })

      assert %{
               "data" => %{
                 "login" => %{
                   "token" => token
                 }
               }
             } = json_response(response, 200)

      conn =
        build_conn()
        |> Plug.Conn.put_req_header("authorization", "Bearer #{token}")

      ###############
      # CREATE FUND #
      ###############
      # MUST BE UNAUTHORIZED

      response =
        post(conn, "/api", %{
          query: @create_fund
        })

      assert %{
               "data" => %{"me" => %{"createFund" => nil}},
               "errors" => [
                 %{
                   "locations" => [%{"column" => 5, "line" => 3}],
                   "message" => "invalid_or_unauthorized",
                   "path" => ["me", "createFund"]
                 }
               ]
             } = json_response(response, 200)
    end
  end
end

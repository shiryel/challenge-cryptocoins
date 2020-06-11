# Jungsoft
![Elixir CI](https://github.com/shiryel/jungsoft_test/workflows/Elixir%20CI/badge.svg)

To start the server:
  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server`

GraphQL API on: [`localhost:4000/api`](http://localhost:4000/api)

## Assumptions
- Only loged users can make operations (get, list, invest, refund) on Funds
- Only admin users can create and update the Funds
- A Fund is created with a amount of tokens, these tokens will have a owner and can be registred on a historic of transactions to see the user profit later
- If the exchanger dont have owned tokens on a Fund, then the user cannot invest in this Fund, dont subtracting nothing from the user (the default is that all tokens when created is owned by the exchanger)
- If the user dont have owned tokens on a Fund, then the user cannot refund in this Fund, dont adding nothing to the user
- A new admin cannot be created from the API (use the `login(email: "admin@hotmail.com", password: "admin")` from the seeds)

## Notes
- Dont load the seeds.exs on the test ENV, this will broke the tests
- A web doc can be generated with `mix docs`

## Examples

### Login
Login as admin:
```
mutation {
  login(email: "admin@hotmail.com", password: "admin") {
    token
  } 
}
```

Login as normal client
```
mutation {
  login(email: "dio@hotmail.com", password: "test") {
    token
  } 
}
```
Insert the token on the HTTP Header Authorization
Ex: `Authorization` `Bearer SFMyNTY.g2gDdAAAAAFkAAJpZG0AAAAkZTA4YzQzY2UtOWEzZC00NWUzLWE3NDEtYjNhNGIyNzQxYmJibgYA-qa7oHIBYgABUYA.lDLsr-jWc2BftBNGnB-BTazsR15tqqwGOvEi_Fex40g`

### Fund
List:
```
{
  me {
    listFunds {
      description
      name
      value
    }
  } 
}
```

Get:
```
{
  me {
    getFund(name: "fund 1") {
      description
      name
      value
    }
  } 
}
```

Create (only as admin):
```
mutation {
  me {
    createFund(name: "fund 4", value: 20, tokenAmount: 5) {
      description
      name
      value
    }
  }
}
```

Update (only as admin):
```
mutation {
  me {
    updateFund(fundName: "fund 1", value: 30) {
      description
      name
      value
    } 
  }
}
```

Invest:
```
mutation {
  me {
    invest(fundName: "fund 1", tokenAmount: 1) 
  }
}
```

Refund:
```
mutation {
  me {
    refund(fundName: "fund 1", tokenAmount: 1) 
  }
}
```

Get profit:
```
{
  me {
    getUserProfit
  }
}
```

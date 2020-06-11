[
  main: "readme",
  extras: [
    "README.md"
  ],
  groups_for_modules: [
    Authentication: [
      JungsoftWeb.Authentication,
      JungsoftWeb.Context
    ],
    GraphQL: [
      JungsoftWeb.Schema,
      Jungsoft.Resolver,
    ],
    Database: [
      Jungsoft.Repo,
      Jungsoft.Exchages,
      Jungsoft.Exchages.Fund,
      Jungsoft.Exchages.Historic,
      Jungsoft.Exchages.Token,
      Jungsoft.Exchages.User,
    ],
    Phoenix: [
      Jungsoft,
      JungsoftWeb,
      JungsoftWeb.Endpoint,
      JungsoftWeb.Router,
      JungsoftWeb.Router.Helpers,
      JungsoftWeb.Gettext,
      JungsoftWeb.ErrorView,
      JungsoftWeb.ErrorHelpers
    ],
  ]
]

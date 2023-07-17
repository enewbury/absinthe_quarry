# Used by "mix format"
locals_without_parens = [
  association: 2,
  association: 3,
  root_field: 3
]

[
  import_deps: [:absinthe, :ecto, :ecto_sql],
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  locals_without_parens: locals_without_parens,
  export: [
    locals_without_parens: locals_without_parens
  ]
]

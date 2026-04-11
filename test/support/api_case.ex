defmodule ExDisco.ApiCase do
  @moduledoc false

  use ExUnit.CaseTemplate

  using options do
    quote do
      use ExUnit.Case, unquote(options)
      import ExDisco.ApiCase, only: [configure_ex_disco: 1]

      setup {Req.Test, :set_req_test_from_context}
      setup {Req.Test, :verify_on_exit!}
      setup :configure_ex_disco
    end
  end

  def configure_ex_disco(%{module: module}) do
    Application.put_env(:ex_disco, ExDisco,
      user_agent: "ex_disco/0.1.0",
      req_options: [plug: {Req.Test, module}]
    )

    on_exit(fn -> Application.delete_env(:ex_disco, ExDisco) end)

    :ok
  end
end

defmodule ExDisco.Releases.Community do
  @moduledoc """
  Community data for a release — collection stats, average rating, and status.
  """

  defstruct [:have, :want, :status, :data_quality, :rating_average, :rating_count, :submitter]

  @type t :: %__MODULE__{
          have: non_neg_integer() | nil,
          want: non_neg_integer() | nil,
          status: String.t() | nil,
          data_quality: String.t() | nil,
          rating_average: float() | nil,
          rating_count: non_neg_integer() | nil,
          submitter: String.t() | nil
        }

  @spec from_api(map() | nil) :: t() | nil
  def from_api(nil), do: nil

  def from_api(data) do
    rating = data["rating"] || %{}

    %__MODULE__{
      have: data["have"],
      want: data["want"],
      status: data["status"],
      data_quality: data["data_quality"],
      rating_average: rating["average"],
      rating_count: rating["count"],
      submitter: get_in(data, ["submitter", "username"])
    }
  end
end
